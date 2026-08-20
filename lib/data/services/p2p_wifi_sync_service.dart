import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:sreerajp_todo/core/utils/date_utils.dart';
import 'package:sreerajp_todo/core/utils/unicode_utils.dart';
import 'package:sreerajp_todo/data/dao/recurrence_rule_dao.dart';
import 'package:sreerajp_todo/data/dao/spaced_repetition_dao.dart';
import 'package:sreerajp_todo/data/dao/time_segment_dao.dart';
import 'package:sreerajp_todo/data/dao/todo_dao.dart';
import 'package:sreerajp_todo/data/models/recurrence_rule_entity.dart';
import 'package:sreerajp_todo/data/models/spaced_repetition_item_entity.dart';
import 'package:sreerajp_todo/data/models/time_segment_entity.dart';
import 'package:sreerajp_todo/data/models/todo_entity.dart';
import 'package:sreerajp_todo/data/services/p2p_wifi_sync_crypto.dart';
import 'package:sreerajp_todo/domain/entities/p2p_sync_payload.dart';
import 'package:sreerajp_todo/domain/entities/p2p_sync_scope.dart';

enum P2pHostStatus {
  stopped,
  listening,
  peerConnected,
  syncing,
  completed,
  error,
}

/// Serverless Local P2P Wi-Fi Sync Engine for device-to-device synchronization over local TCP sockets.
class P2pWifiSyncService {
  P2pWifiSyncService(
    this._todoDao,
    this._timeSegmentDao,
    this._recurrenceRuleDao,
    this._spacedRepetitionDao,
  );

  final TodoDao _todoDao;
  final TimeSegmentDao _timeSegmentDao;
  final RecurrenceRuleDao _recurrenceRuleDao;
  final SpacedRepetitionDao _spacedRepetitionDao;

  ServerSocket? _serverSocket;
  Timer? _idleTimer;
  P2pHostStatus _hostStatus = P2pHostStatus.stopped;
  String _hostIp = '';
  int _hostPort = 0;
  String _pairingPin = '';
  Uint8List _salt = Uint8List(0);
  Uint8List? _sessionKey;

  P2pHostStatus get hostStatus => _hostStatus;
  String get hostIp => _hostIp;
  int get hostPort => _hostPort;
  String get pairingPin => _pairingPin;
  Uint8List get salt => _salt;

  /// Retrieves list of non-loopback IPv4 addresses available on local Wi-Fi / hotspot.
  static Future<List<String>> getLocalIpAddresses() async {
    final ips = <String>[];
    try {
      final interfaces = await NetworkInterface.list(
        type: InternetAddressType.IPv4,
        includeLinkLocal: false,
      );
      for (final interface in interfaces) {
        for (final addr in interface.addresses) {
          if (!addr.isLoopback) {
            ips.add(addr.address);
          }
        }
      }
    } catch (_) {}

    if (ips.isEmpty) {
      ips.add('127.0.0.1');
    }
    return ips;
  }

  /// Generates pairing QR code / deep link string: `wifi_sync://<ip>:<port>?pin=<pin>&salt=<salt_hex>`
  String getPairingQrPayload() {
    final saltHex = _salt
        .map((b) => b.toRadixString(16).padLeft(2, '0'))
        .join();
    return 'wifi_sync://$_hostIp:$_hostPort?pin=$_pairingPin&salt=$saltHex';
  }

  /// Starts Host TCP Server on a random local port, listening for peer connections.
  Future<void> startHostServer({
    String? pin,
    P2pSyncScope scope = const P2pSyncScope.full(),
  }) async {
    await stopHostServer();

    final ips = await getLocalIpAddresses();
    _hostIp = ips.first;
    _pairingPin = pin ?? P2pWifiSyncCrypto.generatePairingPin();
    _salt = P2pWifiSyncCrypto.generateSalt(16);
    _sessionKey = P2pWifiSyncCrypto.deriveSessionKey(
      pin: _pairingPin,
      salt: _salt,
    );

    _serverSocket = await ServerSocket.bind(InternetAddress.anyIPv4, 0);
    _hostPort = _serverSocket!.port;
    _hostStatus = P2pHostStatus.listening;

    // 120s Host Idle Auto-stop
    _idleTimer?.cancel();
    _idleTimer = Timer(P2pSyncBounds.hostIdleTimeout, () {
      stopHostServer();
    });

    _serverSocket!.listen(
      (socket) => _handleHostConnection(socket, scope),
      onError: (error) {
        _hostStatus = P2pHostStatus.error;
      },
      onDone: () {
        _hostStatus = P2pHostStatus.stopped;
      },
    );
  }

  /// Stops the Host TCP server.
  Future<void> stopHostServer() async {
    _idleTimer?.cancel();
    _idleTimer = null;
    await _serverSocket?.close();
    _serverSocket = null;
    _hostStatus = P2pHostStatus.stopped;
  }

  Future<void> _handleHostConnection(Socket socket, P2pSyncScope scope) async {
    _idleTimer?.cancel();
    _hostStatus = P2pHostStatus.peerConnected;

    try {
      final completer = Completer<void>();
      final streamSubscription = socket.listen(
        (data) async {
          try {
            final rawMessage = utf8.decode(data);
            final decryptedMessage = P2pWifiSyncCrypto.decryptPayload(
              encryptedPackage: rawMessage,
              sessionKey: _sessionKey!,
            );

            final requestJson =
                jsonDecode(decryptedMessage) as Map<String, dynamic>;
            final command = requestJson['command'] as String?;

            if (command == 'REQUEST_SYNC') {
              _hostStatus = P2pHostStatus.syncing;
              final requestedScopeJson =
                  requestJson['scope'] as Map<String, dynamic>?;
              final activeScope = requestedScopeJson != null
                  ? P2pSyncScope.fromJson(requestedScopeJson)
                  : scope;

              final payload = await buildPayload(scope: activeScope);
              final encryptedPayload = P2pWifiSyncCrypto.encryptPayload(
                plainText: jsonEncode(payload.toJson()),
                sessionKey: _sessionKey!,
              );

              socket.write(encryptedPayload);
              await socket.flush();
              _hostStatus = P2pHostStatus.completed;
            }
          } catch (e) {
            _hostStatus = P2pHostStatus.error;
          } finally {
            await socket.close();
            if (!completer.isCompleted) completer.complete();
          }
        },
        onError: (_) {
          socket.close();
          if (!completer.isCompleted) completer.complete();
        },
        onDone: () {
          if (!completer.isCompleted) completer.complete();
        },
      );

      // 30s handshake timeout cap
      await completer.future.timeout(
        P2pSyncBounds.handshakeTimeout,
        onTimeout: () {
          streamSubscription.cancel();
          socket.close();
        },
      );
    } catch (_) {
      _hostStatus = P2pHostStatus.error;
    }
  }

  /// Connects Peer (Client) to Host TCP Server, requests sync payload, and executes Add-Only Non-Destructive Merge.
  Future<P2pSyncMergeResult> connectAndSyncAsPeer({
    required String hostIp,
    required int hostPort,
    required String pin,
    required Uint8List salt,
    P2pSyncScope scope = const P2pSyncScope.full(),
  }) async {
    final sessionKey = P2pWifiSyncCrypto.deriveSessionKey(pin: pin, salt: salt);
    final socket = await Socket.connect(
      hostIp,
      hostPort,
      timeout: const Duration(seconds: 10),
    );

    try {
      final requestMap = {
        'command': 'REQUEST_SYNC',
        'scope': scope.toJson(),
        'requested_at': DateTime.now().toIso8601String(),
      };

      final encryptedRequest = P2pWifiSyncCrypto.encryptPayload(
        plainText: jsonEncode(requestMap),
        sessionKey: sessionKey,
      );

      socket.write(encryptedRequest);
      await socket.flush();

      final completer = Completer<String>();
      final buffer = StringBuffer();

      final sub = socket.listen(
        (data) {
          buffer.write(utf8.decode(data));
        },
        onError: (err) {
          if (!completer.isCompleted) completer.completeError(err);
        },
        onDone: () {
          if (!completer.isCompleted) completer.complete(buffer.toString());
        },
      );

      final rawResponse = await completer.future.timeout(
        P2pSyncBounds.handshakeTimeout,
        onTimeout: () {
          sub.cancel();
          throw TimeoutException(
            'P2P Sync timed out waiting for host response.',
          );
        },
      );

      final decryptedResponse = P2pWifiSyncCrypto.decryptPayload(
        encryptedPackage: rawResponse,
        sessionKey: sessionKey,
      );

      final payloadJson = jsonDecode(decryptedResponse) as Map<String, dynamic>;
      final payload = P2pSyncPayload.fromJson(payloadJson);

      return await mergeIncomingPayload(payload);
    } finally {
      await socket.close();
    }
  }

  /// Constructs a P2pSyncPayload based on the requested sync scope.
  Future<P2pSyncPayload> buildPayload({
    required P2pSyncScope scope,
    String? targetDate,
  }) async {
    final today = targetDate ?? todayAsIso();

    final todos = <TodoEntity>[];
    final timeSegments = <TimeSegmentEntity>[];
    final recurrenceRules = <RecurrenceRuleEntity>[];
    final masteryItems = <SpacedRepetitionItemEntity>[];

    if (scope.todaysTasks) {
      final fetchedTodos = await _todoDao.findByDate(today);
      todos.addAll(fetchedTodos);
    }

    if (scope.timeSegments && todos.isNotEmpty) {
      for (final todo in todos) {
        final segments = await _timeSegmentDao.findByTodoId(todo.id);
        timeSegments.addAll(segments);
      }
    }

    if (scope.recurrenceRules) {
      final rules = await _recurrenceRuleDao.findAll();
      recurrenceRules.addAll(rules);
    }

    if (scope.masteryDeck) {
      final items = await _spacedRepetitionDao.findAll();
      masteryItems.addAll(items);
    }

    return P2pSyncPayload(
      date: today,
      exportedAt: DateTime.now().toIso8601String(),
      scope: scope,
      todos: todos,
      timeSegments: timeSegments,
      recurrenceRules: recurrenceRules,
      masteryItems: masteryItems,
    );
  }

  /// Executes Add-Only Non-Destructive Merge of incoming records based on natural primary keys (`date` + NFC-normalized `title`).
  Future<P2pSyncMergeResult> mergeIncomingPayload(
    P2pSyncPayload payload,
  ) async {
    int todosAdded = 0;
    int todosSkipped = 0;
    int segmentsAdded = 0;
    int segmentsSkipped = 0;
    int rulesAdded = 0;
    int rulesSkipped = 0;
    int masteryAdded = 0;
    int masterySkipped = 0;
    int dayLockViolations = 0;

    final today = todayAsIso();

    // 1. Merge Tasks (Add-Only based on Date + NFC-Normalized Title)
    for (final incomingTodo in payload.todos) {
      final nfcTitle = nfcNormalize(incomingTodo.title);
      final sanitizedTodo = incomingTodo.copyWith(title: nfcTitle);

      // Past-Day Day-Lock invariant check
      final isPastDay = sanitizedTodo.date.compareTo(today) < 0;

      final existingForDate = await _todoDao.findByDate(sanitizedTodo.date);
      final alreadyExists = existingForDate.any(
        (t) => nfcNormalize(t.title) == nfcTitle,
      );

      if (alreadyExists) {
        todosSkipped++;
        if (isPastDay) dayLockViolations++;
        continue;
      }

      // Past-day new task insertion is permitted read-only as long as historical record is untouched
      await _todoDao.insert(sanitizedTodo);
      todosAdded++;
    }

    // 2. Merge Time Segments
    for (final segment in payload.timeSegments) {
      final existingSegments = await _timeSegmentDao.findByTodoId(
        segment.todoId,
      );
      final alreadyExists = existingSegments.any((s) => s.id == segment.id);
      if (alreadyExists) {
        segmentsSkipped++;
        continue;
      }

      // Verify task existence for foreign key integrity
      final parentTodo = await _todoDao.findById(segment.todoId);
      if (parentTodo != null) {
        await _timeSegmentDao.insert(segment);
        segmentsAdded++;
      } else {
        segmentsSkipped++;
      }
    }

    // 3. Merge Recurrence Rules
    for (final rule in payload.recurrenceRules) {
      final existingRules = await _recurrenceRuleDao.findAll();
      final duplicateRule = existingRules.any(
        (r) =>
            nfcNormalize(r.title) == nfcNormalize(rule.title) &&
            r.rrule == rule.rrule,
      );

      if (duplicateRule) {
        rulesSkipped++;
        continue;
      }

      await _recurrenceRuleDao.insert(rule);
      rulesAdded++;
    }

    // 4. Merge Mastery Deck Items
    for (final mastery in payload.masteryItems) {
      final existingMastery = await _spacedRepetitionDao.findAll();
      final duplicateMastery = existingMastery.any(
        (m) => nfcNormalize(m.title) == nfcNormalize(mastery.title),
      );

      if (duplicateMastery) {
        masterySkipped++;
        continue;
      }

      await _spacedRepetitionDao.insert(mastery);
      masteryAdded++;
    }

    return P2pSyncMergeResult(
      todosAdded: todosAdded,
      todosSkipped: todosSkipped,
      segmentsAdded: segmentsAdded,
      segmentsSkipped: segmentsSkipped,
      rulesAdded: rulesAdded,
      rulesSkipped: rulesSkipped,
      masteryAdded: masteryAdded,
      masterySkipped: masterySkipped,
      dayLockViolations: dayLockViolations,
    );
  }
}
