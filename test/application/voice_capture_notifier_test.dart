import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:sreerajp_todo/application/voice_capture_notifier.dart';
import 'package:sreerajp_todo/application/voice_capture_state.dart';
import 'package:sreerajp_todo/core/platform/speech_channel.dart';
import 'package:sreerajp_todo/core/voice/voice_parse_result.dart';

/// Stands in for the Android recogniser so the tests never touch a channel.
class _FakeSpeechChannel extends SpeechChannel {
  _FakeSpeechChannel() : super(isSupported: true);

  final _controller = StreamController<SpeechEvent>.broadcast();

  /// Set by a test before `prepare()` to pretend the device cannot listen.
  SpeechUnavailableReason? reason;

  /// Whether the pretend permission dialog says yes.
  bool grantPermission = true;
  bool permissionAsked = false;
  bool started = false;
  bool stopped = false;
  String? startedLocale;

  @override
  Future<SpeechUnavailableReason?> check() async => reason;

  @override
  Future<bool> requestPermission() async {
    permissionAsked = true;
    if (grantPermission) reason = null;
    return grantPermission;
  }

  @override
  Future<void> start(String localeTag) async {
    started = true;
    startedLocale = localeTag;
  }

  @override
  Future<void> stop() async {
    stopped = true;
  }

  @override
  Stream<SpeechEvent> get events => _controller.stream;

  void emit(SpeechEvent event) => _controller.add(event);

  Future<void> close() => _controller.close();
}

void main() {
  late _FakeSpeechChannel channel;
  late VoiceCaptureNotifier notifier;

  DateTime today() => DateTime(2026, 8, 19);

  setUp(() {
    channel = _FakeSpeechChannel();
    notifier = VoiceCaptureNotifier(channel: channel, today: today);
  });

  tearDown(() async {
    notifier.dispose();
    await channel.close();
  });

  group('opening the sheet', () {
    test('a ready channel leaves the microphone on offer', () async {
      await notifier.prepare();

      expect(notifier.state.canListen, isTrue);
      expect(notifier.state.stage, VoiceCaptureStage.idle);
    });

    test('an unusable channel says so instead of failing', () async {
      channel.reason = SpeechUnavailableReason.unsupported;

      await notifier.prepare();

      expect(notifier.state.canListen, isFalse);
      expect(notifier.state.unavailable, SpeechUnavailableReason.unsupported);
    });
  });

  group('typing', () {
    test('words are read as they are typed', () {
      notifier.setText('Call the bank tomorrow for 30 minutes');

      final result = notifier.state.result!;
      expect(result.title, 'Call the bank');
      expect(result.date, '2026-08-20');
      expect(result.targetSeconds, 30 * 60);
      expect(notifier.state.canCreate, isTrue);
      expect(notifier.state.stage, VoiceCaptureStage.ready);
    });

    test('emptying the box clears the reading', () {
      notifier.setText('Buy milk');
      notifier.setText('   ');

      expect(notifier.state.result, isNull);
      expect(notifier.state.canCreate, isFalse);
      expect(notifier.state.stage, VoiceCaptureStage.idle);
    });
  });

  group('listening', () {
    test('a ready channel is started in the language asked for', () async {
      await notifier.prepare();
      await notifier.startListening('ml-IN');

      expect(channel.started, isTrue);
      expect(channel.startedLocale, 'ml-IN');
      expect(notifier.state.stage, VoiceCaptureStage.listening);
    });

    test('an unusable channel is never started', () async {
      channel.reason = SpeechUnavailableReason.noOfflineEngine;
      await notifier.prepare();

      await notifier.startListening('en-IN');

      expect(channel.started, isFalse);
      expect(notifier.state.stage, VoiceCaptureStage.idle);
    });

    test('a missing permission is asked for, then listening starts', () async {
      channel
        ..reason = SpeechUnavailableReason.missingPermission
        ..grantPermission = true;
      await notifier.prepare();

      await notifier.startListening('en-IN');

      expect(channel.permissionAsked, isTrue);
      expect(channel.started, isTrue);
      expect(notifier.state.canListen, isTrue);
    });

    test('a refused permission stops there and says why', () async {
      channel
        ..reason = SpeechUnavailableReason.missingPermission
        ..grantPermission = false;
      await notifier.prepare();

      await notifier.startListening('en-IN');

      expect(channel.started, isFalse);
      expect(notifier.state.error, SpeechErrorCode.permissionDenied);
    });

    test('stopping closes the microphone', () async {
      await notifier.prepare();
      await notifier.startListening('en-IN');
      await notifier.stopListening();

      expect(channel.stopped, isTrue);
      expect(notifier.state.stage, VoiceCaptureStage.idle);
    });
  });

  group('what comes back from the recogniser', () {
    setUp(() async {
      await notifier.prepare();
      await notifier.startListening('en-IN');
    });

    test('partial words are shown but not read yet', () async {
      channel.emit(
        const SpeechEvent(type: SpeechEventType.partial, text: 'Call the'),
      );
      await Future<void>.delayed(Duration.zero);

      expect(notifier.state.text, 'Call the');
      expect(notifier.state.result, isNull);
      expect(notifier.state.stage, VoiceCaptureStage.listening);
    });

    test('the finished sentence is read', () async {
      channel.emit(
        const SpeechEvent(
          type: SpeechEventType.result,
          text: 'Gym tomorrow for 45 minutes',
        ),
      );
      await Future<void>.delayed(Duration.zero);

      expect(notifier.state.stage, VoiceCaptureStage.ready);
      expect(notifier.state.result?.title, 'Gym');
      expect(notifier.state.result?.targetSeconds, 45 * 60);
      expect(notifier.state.result?.matched, contains(VoiceField.date));
    });

    test('an error is kept so the sheet can explain it', () async {
      channel.emit(
        const SpeechEvent(
          type: SpeechEventType.error,
          error: SpeechErrorCode.noOfflineLanguage,
        ),
      );
      await Future<void>.delayed(Duration.zero);

      expect(notifier.state.error, SpeechErrorCode.noOfflineLanguage);
      expect(notifier.state.stage, VoiceCaptureStage.idle);
    });
  });

  test('resetting keeps what was learned about the device', () async {
    channel.reason = SpeechUnavailableReason.noRecogniser;
    await notifier.prepare();
    notifier.setText('Buy milk');

    notifier.reset();

    expect(notifier.state.text, '');
    expect(notifier.state.result, isNull);
    expect(notifier.state.unavailable, SpeechUnavailableReason.noRecogniser);
  });
}
