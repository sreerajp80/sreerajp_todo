import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:sreerajp_todo/app.dart';
import 'package:sreerajp_todo/application/providers.dart';
import 'package:sreerajp_todo/core/constants/app_routes.dart';
import 'package:sreerajp_todo/core/logging/app_logger.dart';
import 'package:sreerajp_todo/core/utils/date_utils.dart';
import 'package:sreerajp_todo/presentation/shared/widgets/safe_error_fallback.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  _installErrorHandlers();

  if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }

  final prefs = await SharedPreferences.getInstance();

  final container = ProviderContainer(
    overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
  );

  // Apply the saved date and time preferences before anything reads a date.
  // The day-start hour decides what "today" means, so it has to be in place
  // before the startup tasks below run.
  container.read(dateTimeSettingsProvider);

  // Ensure the database is initialised before running startup tasks.
  await container.read(databaseServiceProvider).database;

  // Repair orphaned segments before any other startup task.
  await container.read(repairOrphanedSegmentsProvider).call();

  // Generate recurring tasks for [today, today + 7 days].
  await container.read(generateRecurringTasksProvider).call();

  // Generate spaced repetition tasks for today.
  await container.read(generateSpacedRepetitionTasksProvider).call();

  // Decide the first screen. This runs after the two generators above on
  // purpose: the ritual's settle step shows today's tasks, and today's
  // recurring and mastery-deck tasks only exist once they have run.
  final ritual = container.read(ritualProvider);
  final startAt = ritual.shouldOpenOn(todayAsIso())
      ? AppRoutes.ritual
      : AppRoutes.root;

  runApp(
    UncontrolledProviderScope(
      container: container,
      child: TodoApp(initialLocation: startAt),
    ),
  );
}

/// Global error boundaries (engineering standard §11.1). They only log; the
/// safe release UI comes from [ErrorWidget.builder].
void _installErrorHandlers() {
  // Errors while building, laying out or painting widgets.
  FlutterError.onError = (FlutterErrorDetails details) {
    AppLogger.error(
      'Flutter framework error',
      error: details.exception,
      stackTrace: details.stack,
    );
    if (!kReleaseMode) {
      FlutterError.dumpErrorToConsole(details);
    }
  };

  // Uncaught async errors (futures, timers, platform channels).
  PlatformDispatcher.instance.onError = (Object error, StackTrace stack) {
    AppLogger.error('Uncaught async error', error: error, stackTrace: stack);
    return true;
  };

  // In release, show a neutral box instead of the raw error widget.
  if (kReleaseMode) {
    ErrorWidget.builder = (FlutterErrorDetails details) =>
        const SafeErrorFallback();
  }
}
