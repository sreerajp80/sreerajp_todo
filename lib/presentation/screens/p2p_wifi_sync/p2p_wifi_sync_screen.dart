import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:sreerajp_todo/application/providers.dart';
import 'package:sreerajp_todo/data/services/p2p_wifi_sync_service.dart';
import 'package:sreerajp_todo/domain/entities/p2p_sync_payload.dart';
import 'package:sreerajp_todo/domain/entities/p2p_sync_scope.dart';

class P2pWifiSyncScreen extends ConsumerStatefulWidget {
  const P2pWifiSyncScreen({super.key});

  @override
  ConsumerState<P2pWifiSyncScreen> createState() => _P2pWifiSyncScreenState();
}

class _P2pWifiSyncScreenState extends ConsumerState<P2pWifiSyncScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Host Mode Controls
  P2pSyncScope _hostScope = const P2pSyncScope.full();
  bool _isHostRunning = false;
  String _hostIp = '';
  int _hostPort = 0;
  String _pairingPin = '';
  String _qrPayload = '';

  // Peer Mode Controls
  final _hostIpController = TextEditingController();
  final _hostPortController = TextEditingController();
  final _pinController = TextEditingController();
  final String _saltHex = '';
  P2pSyncScope _peerScope = const P2pSyncScope.full();
  bool _isPeerSyncing = false;
  String _peerStatusMessage = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _initLocalIp();
  }

  Future<void> _initLocalIp() async {
    final ips = await P2pWifiSyncService.getLocalIpAddresses();
    if (mounted && ips.isNotEmpty) {
      setState(() {
        _hostIpController.text = ips.first;
      });
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _hostIpController.dispose();
    _hostPortController.dispose();
    _pinController.dispose();
    super.dispose();
  }

  Future<void> _toggleHostServer() async {
    final syncService = ref.read(p2pWifiSyncServiceProvider);

    if (_isHostRunning) {
      await syncService.stopHostServer();
      setState(() {
        _isHostRunning = false;
      });
    } else {
      await syncService.startHostServer(scope: _hostScope);
      setState(() {
        _isHostRunning = true;
        _hostIp = syncService.hostIp;
        _hostPort = syncService.hostPort;
        _pairingPin = syncService.pairingPin;
        _qrPayload = syncService.getPairingQrPayload();
      });
    }
  }

  Future<void> _startPeerSync() async {
    final hostIp = _hostIpController.text.trim();
    final hostPortStr = _hostPortController.text.trim();
    final pin = _pinController.text.trim();

    if (hostIp.isEmpty || hostPortStr.isEmpty || pin.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter Host IP, Port, and Pairing PIN.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    final port = int.tryParse(hostPortStr);
    if (port == null || port <= 0 || port > 65535) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Invalid port number.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() {
      _isPeerSyncing = true;
      _peerStatusMessage = 'Connecting to host $hostIp:$port...';
    });

    final syncService = ref.read(p2pWifiSyncServiceProvider);

    try {
      Uint8List saltBytes;
      if (_saltHex.isNotEmpty) {
        final List<int> bytes = [];
        for (int i = 0; i < _saltHex.length; i += 2) {
          bytes.add(int.parse(_saltHex.substring(i, i + 2), radix: 16));
        }
        saltBytes = Uint8List.fromList(bytes);
      } else {
        saltBytes = Uint8List(16); // Fallback zero salt
      }

      setState(() {
        _peerStatusMessage = 'Authenticating AES-256 session handshake...';
      });

      final mergeResult = await syncService.connectAndSyncAsPeer(
        hostIp: hostIp,
        hostPort: port,
        pin: pin,
        salt: saltBytes,
        scope: _peerScope,
      );

      setState(() {
        _isPeerSyncing = false;
        _peerStatusMessage = 'Sync completed successfully!';
      });

      if (mounted) {
        _showMergeResultDialog(mergeResult);
      }
    } catch (e) {
      setState(() {
        _isPeerSyncing = false;
        _peerStatusMessage = 'Sync failed: ${e.toString()}';
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('P2P Sync Failed: $e'),
            backgroundColor: Colors.redAccent,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  void _showMergeResultDialog(P2pSyncMergeResult result) {
    showDialog<void>(
      context: context,
      builder: (ctx) {
        final theme = Theme.of(ctx);
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Row(
            children: [
              Icon(Icons.sync_outlined, color: theme.colorScheme.primary),
              const SizedBox(width: 10),
              const Text('Sync Summary'),
            ],
          ),
          content: SingleChildScrollView(
            child: ListBody(
              children: [
                _buildSummaryRow(
                  icon: Icons.task_alt_outlined,
                  title: 'Tasks',
                  added: result.todosAdded,
                  skipped: result.todosSkipped,
                ),
                const Divider(),
                _buildSummaryRow(
                  icon: Icons.timer_outlined,
                  title: 'Time Segments',
                  added: result.segmentsAdded,
                  skipped: result.segmentsSkipped,
                ),
                const Divider(),
                _buildSummaryRow(
                  icon: Icons.repeat_outlined,
                  title: 'Recurrence Rules',
                  added: result.rulesAdded,
                  skipped: result.rulesSkipped,
                ),
                const Divider(),
                _buildSummaryRow(
                  icon: Icons.style_outlined,
                  title: 'Mastery Deck',
                  added: result.masteryAdded,
                  skipped: result.masterySkipped,
                ),
                if (result.dayLockViolations > 0) ...[
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.amber.withAlpha(30),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.lock_clock, color: Colors.amber, size: 20),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            '${result.dayLockViolations} past-day items skipped due to Day-Lock immutability.',
                            style: theme.textTheme.bodySmall?.copyWith(color: Colors.amber.shade900),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildSummaryRow({
    required IconData icon,
    required String title,
    required int added,
    required int skipped,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.blueGrey),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          Text(
            '+$added added',
            style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
          ),
          const SizedBox(width: 8),
          Text(
            '($skipped skipped)',
            style: const TextStyle(color: Colors.grey, fontSize: 12),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Local P2P Wi-Fi Sync'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.wifi_tethering), text: 'Host (Share)'),
            Tab(icon: Icon(Icons.phonelink_ring), text: 'Peer (Receive)'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildHostTab(theme),
          _buildPeerTab(theme),
        ],
      ),
    );
  }

  Widget _buildHostTab(ThemeData theme) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: _isHostRunning
                              ? Colors.green.withAlpha(30)
                              : Colors.grey.withAlpha(30),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          _isHostRunning ? Icons.wifi_tethering : Icons.portable_wifi_off,
                          color: _isHostRunning ? Colors.green : Colors.grey,
                          size: 32,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _isHostRunning ? 'Host Server Active' : 'Host Server Stopped',
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _isHostRunning
                                  ? 'Listening on TCP $_hostIp:$_hostPort'
                                  : 'Tap below to open encrypted TCP socket.',
                              style: theme.textTheme.bodySmall,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  if (_isHostRunning) ...[
                    const SizedBox(height: 20),
                    const Divider(),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Column(
                          children: [
                            const Text('PAIRING PIN', style: TextStyle(fontSize: 10, letterSpacing: 1.2, color: Colors.grey)),
                            const SizedBox(height: 4),
                            SelectableText(
                              _pairingPin,
                              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, letterSpacing: 4),
                            ),
                          ],
                        ),
                        Column(
                          children: [
                            const Text('PORT', style: TextStyle(fontSize: 10, letterSpacing: 1.2, color: Colors.grey)),
                            const SizedBox(height: 4),
                            Text(
                              '$_hostPort',
                              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    if (_qrPayload.isNotEmpty)
                      Center(
                        child: QrImageView(
                          data: _qrPayload,
                          version: QrVersions.auto,
                          size: 180.0,
                          backgroundColor: Colors.white,
                        ),
                      ),
                    const SizedBox(height: 8),
                    IconButton(
                      icon: const Icon(Icons.copy),
                      tooltip: 'Copy Pairing Details',
                      onPressed: () {
                        Clipboard.setData(ClipboardData(text: _qrPayload));
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Pairing payload copied to clipboard!')),
                        );
                      },
                    ),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text('Select Sync Scope', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          _buildScopeSelector(
            scope: _hostScope,
            onChanged: (newScope) {
              setState(() {
                _hostScope = newScope;
              });
            },
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
              backgroundColor: _isHostRunning ? Colors.redAccent : theme.colorScheme.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: _toggleHostServer,
            icon: Icon(_isHostRunning ? Icons.stop_circle_outlined : Icons.play_arrow),
            label: Text(_isHostRunning ? 'Stop Host Server' : 'Start Host Server'),
          ),
        ],
      ),
    );
  }

  Widget _buildPeerTab(ThemeData theme) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Connect to Host Device',
                    style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _hostIpController,
                    decoration: const InputDecoration(
                      labelText: 'Host IP Address',
                      hintText: 'e.g. 192.168.1.105',
                      prefixIcon: Icon(Icons.wifi),
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.datetime,
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _hostPortController,
                          decoration: const InputDecoration(
                            labelText: 'Port',
                            hintText: 'Port',
                            prefixIcon: Icon(Icons.numbers),
                            border: OutlineInputBorder(),
                          ),
                          keyboardType: TextInputType.number,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextField(
                          controller: _pinController,
                          decoration: const InputDecoration(
                            labelText: 'Pairing PIN',
                            hintText: '6-digit PIN',
                            prefixIcon: Icon(Icons.lock_outline),
                            border: OutlineInputBorder(),
                          ),
                          keyboardType: TextInputType.number,
                          maxLength: 6,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text('Requested Sync Scope', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          _buildScopeSelector(
            scope: _peerScope,
            onChanged: (newScope) {
              setState(() {
                _peerScope = newScope;
              });
            },
          ),
          const SizedBox(height: 24),
          if (_isPeerSyncing) ...[
            const Center(child: CircularProgressIndicator()),
            const SizedBox(height: 12),
            Center(child: Text(_peerStatusMessage, style: theme.textTheme.bodyMedium)),
          ] else
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                backgroundColor: theme.colorScheme.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: _startPeerSync,
              icon: const Icon(Icons.sync_outlined),
              label: const Text('Connect & Sync'),
            ),
        ],
      ),
    );
  }

  Widget _buildScopeSelector({
    required P2pSyncScope scope,
    required ValueChanged<P2pSyncScope> onChanged,
  }) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        children: [
          CheckboxListTile(
            title: const Text('Today\'s Tasks'),
            subtitle: const Text('Sync today\'s active task list'),
            value: scope.todaysTasks,
            onChanged: (v) => onChanged(scope.copyWith(todaysTasks: v ?? true)),
          ),
          const Divider(height: 1),
          CheckboxListTile(
            title: const Text('Time Segments'),
            subtitle: const Text('Sync tracked time duration logs'),
            value: scope.timeSegments,
            onChanged: (v) => onChanged(scope.copyWith(timeSegments: v ?? true)),
          ),
          const Divider(height: 1),
          CheckboxListTile(
            title: const Text('Recurrence Rules'),
            subtitle: const Text('Sync iCalendar RRULE task schedules'),
            value: scope.recurrenceRules,
            onChanged: (v) => onChanged(scope.copyWith(recurrenceRules: v ?? true)),
          ),
          const Divider(height: 1),
          CheckboxListTile(
            title: const Text('Mastery Deck'),
            subtitle: const Text('Sync Spaced Repetition mastery items'),
            value: scope.masteryDeck,
            onChanged: (v) => onChanged(scope.copyWith(masteryDeck: v ?? true)),
          ),
        ],
      ),
    );
  }
}
