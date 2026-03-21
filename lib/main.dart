import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:sreerajp_todo/app.dart';
import 'package:sreerajp_todo/application/providers.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }

  final container = ProviderContainer();

  // Ensure the database is initialised before running startup tasks.
  await container.read(databaseServiceProvider).database;

  // Repair orphaned segments before any other startup task.
  await container.read(repairOrphanedSegmentsProvider).call();

  // Generate recurring tasks for [today, today + 7 days].
  await container.read(generateRecurringTasksProvider).call();

  runApp(
    UncontrolledProviderScope(
      container: container,
      child: const TodoApp(),
    ),
  );
}
