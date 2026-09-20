import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sreerajp_todo/application/providers.dart';
import 'package:sreerajp_todo/core/platform/speech_channel.dart';
import 'package:sreerajp_todo/core/voice/voice_parse_result.dart';
import 'package:sreerajp_todo/domain/repositories/todo_repository.dart';
import 'package:sreerajp_todo/l10n/app_localizations.dart';
import 'package:sreerajp_todo/presentation/screens/daily_list/widgets/voice_command_sheet.dart';

import '../helpers/test_l10n.dart';

class MockTodoRepository extends Mock implements TodoRepository {}

class FakeTodoEntity extends Fake implements TodoEntity {}

class _FakeSpeechChannel extends SpeechChannel {
  _FakeSpeechChannel({this.reason}) : super(isSupported: true);

  final SpeechUnavailableReason? reason;

  @override
  Future<SpeechUnavailableReason?> check() async => reason;

  @override
  Future<bool> requestPermission() async => true;

  @override
  Future<void> start(String localeTag) async {}

  @override
  Future<void> stop() async {}

  @override
  Stream<SpeechEvent> get events => const Stream.empty();
}

late SharedPreferences testPrefs;

Widget _wrap(
  Widget child, {
  SpeechUnavailableReason? reason,
  TodoRepository? repo,
}) {
  final mockRepo = repo ?? MockTodoRepository();
  if (repo == null) {
    when(
      () => mockRepo.titleExistsOnDate(
        any(),
        any(),
        excludeId: any(named: 'excludeId'),
      ),
    ).thenAnswer((_) async => false);
    when(() => mockRepo.createTodo(any())).thenAnswer((_) async {});
    when(() => mockRepo.getTodosByDate(any())).thenAnswer((_) async => []);
  }

  return ProviderScope(
    overrides: [
      speechChannelProvider.overrideWithValue(
        _FakeSpeechChannel(reason: reason),
      ),
      todoRepositoryProvider.overrideWithValue(mockRepo),
      sharedPreferencesProvider.overrideWithValue(testPrefs),
    ],
    child: MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(body: child),
    ),
  );
}

void main() {
  setUpAll(() {
    registerFallbackValue(FakeTodoEntity());
  });

  setUp(() async {
    SharedPreferences.setMockInitialValues(const {});
    testPrefs = await SharedPreferences.getInstance();
  });

  final todayIso = DateTime.now().toIso8601String().substring(0, 10);

  testWidgets('the sheet opens with nothing to create yet', (tester) async {
    await tester.pumpWidget(_wrap(VoiceCommandSheet(fallbackDate: todayIso)));
    await tester.pumpAndSettle();

    expect(find.text(testL10n.voiceSheetTitle), findsOneWidget);
    expect(find.text(testL10n.voiceTapToSpeak), findsOneWidget);

    final button = tester.widget<FilledButton>(find.byType(FilledButton));
    expect(button.onPressed, isNull, reason: 'nothing has been said yet');
  });

  testWidgets('a typed English sentence is shown broken into its parts', (
    tester,
  ) async {
    await tester.pumpWidget(_wrap(VoiceCommandSheet(fallbackDate: todayIso)));
    await tester.pumpAndSettle();

    await tester.enterText(
      find.byType(TextField),
      'Call the bank tomorrow at 10 am for 30 minutes',
    );
    await tester.pumpAndSettle();

    expect(find.text(testL10n.voiceUnderstoodHeading), findsOneWidget);
    expect(find.text('Call the bank'), findsOneWidget);
    expect(find.text('10:00'), findsOneWidget);
    expect(find.text('00:30:00'), findsOneWidget);

    final button = tester.widget<FilledButton>(find.byType(FilledButton));
    expect(button.onPressed, isNotNull);
  });

  testWidgets('a typed Malayalam sentence is understood the same way', (
    tester,
  ) async {
    await tester.pumpWidget(_wrap(VoiceCommandSheet(fallbackDate: todayIso)));
    await tester.pumpAndSettle();

    // ഏഴരയ്ക്ക് നടക്കാൻ പോകണം — "go for a walk at half past seven".
    await tester.enterText(find.byType(TextField), 'ഏഴരയ്ക്ക് നടക്കാൻ പോകണം');
    await tester.pumpAndSettle();

    expect(find.text('നടക്കാൻ പോകണം'), findsOneWidget);
    expect(find.text('07:30'), findsOneWidget);
  });

  testWidgets('with no microphone the sheet still takes a typed sentence', (
    tester,
  ) async {
    await tester.pumpWidget(
      _wrap(
        VoiceCommandSheet(fallbackDate: todayIso),
        reason: SpeechUnavailableReason.unsupported,
      ),
    );
    await tester.pumpAndSettle();

    // No microphone button at all, and the reason is spelled out.
    expect(find.text(testL10n.voiceTapToSpeak), findsNothing);
    expect(find.text(testL10n.voiceUnavailableDevice), findsOneWidget);

    await tester.enterText(find.byType(TextField), 'Buy milk');
    await tester.pumpAndSettle();

    expect(find.text('Buy milk'), findsWidgets);
    final button = tester.widget<FilledButton>(find.byType(FilledButton));
    expect(button.onPressed, isNotNull);
  });

  testWidgets('a device with no offline engine refuses to listen', (
    tester,
  ) async {
    await tester.pumpWidget(
      _wrap(
        VoiceCommandSheet(fallbackDate: todayIso),
        reason: SpeechUnavailableReason.noOfflineEngine,
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text(testL10n.voiceUnavailableNoOffline), findsOneWidget);
    expect(find.text(testL10n.voiceTapToSpeak), findsNothing);
  });

  testWidgets(
    'sentence with description shows both title and description chips',
    (tester) async {
      await tester.pumpWidget(_wrap(VoiceCommandSheet(fallbackDate: todayIso)));
      await tester.pumpAndSettle();

      await tester.enterText(
        find.byType(TextField),
        'Buy groceries description milk, eggs and bread',
      );
      await tester.pumpAndSettle();

      expect(find.text(testL10n.voiceUnderstoodHeading), findsOneWidget);
      expect(find.text('Buy groceries'), findsOneWidget);
      expect(
        find.text('${testL10n.voiceDescriptionHeading}: milk, eggs and bread'),
        findsOneWidget,
      );
    },
  );

  testWidgets('tapping create task saves the todo directly into repository', (
    tester,
  ) async {
    final mockRepo = MockTodoRepository();
    registerFallbackValue(FakeTodoEntity());
    when(
      () => mockRepo.titleExistsOnDate(
        any(),
        any(),
        excludeId: any(named: 'excludeId'),
      ),
    ).thenAnswer((_) async => false);
    when(() => mockRepo.createTodo(any())).thenAnswer((_) async {});
    when(() => mockRepo.getTodosByDate(any())).thenAnswer((_) async => []);

    await tester.pumpWidget(
      _wrap(VoiceCommandSheet(fallbackDate: todayIso), repo: mockRepo),
    );
    await tester.pumpAndSettle();

    await tester.enterText(
      find.byType(TextField),
      'Buy groceries description milk and eggs',
    );
    await tester.pumpAndSettle();

    final createButton = find.widgetWithText(
      FilledButton,
      testL10n.voiceCreateTask,
    );
    expect(createButton, findsOneWidget);
    await tester.ensureVisible(createButton);
    await tester.tap(createButton);
    await tester.pumpAndSettle();

    verify(
      () => mockRepo.createTodo(
        any(
          that: isA<TodoEntity>()
              .having((t) => t.title, 'title', 'Buy groceries')
              .having((t) => t.description, 'description', 'milk and eggs'),
        ),
      ),
    ).called(1);
  });

  testWidgets('returnResult: true pops the VoiceParseResult back to caller', (
    tester,
  ) async {
    VoiceParseResult? returnedResult;

    await tester.pumpWidget(
      _wrap(
        Builder(
          builder: (context) => ElevatedButton(
            onPressed: () async {
              returnedResult = await VoiceCommandSheet.show(
                context,
                date: todayIso,
                returnResult: true,
              );
            },
            child: const Text('Open'),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();

    await tester.enterText(
      find.byType(TextField),
      'Meeting note discuss roadmap',
    );
    await tester.pumpAndSettle();

    final createButton = find.widgetWithText(
      FilledButton,
      testL10n.voiceCreateTask,
    );
    await tester.ensureVisible(createButton);
    await tester.tap(createButton);
    await tester.pumpAndSettle();

    expect(returnedResult, isNotNull);
    expect(returnedResult!.title, 'Meeting');
    expect(returnedResult!.description, 'discuss roadmap');
  });
}
