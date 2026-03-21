import 'package:flutter/material.dart';
import 'package:sreerajp_todo/core/constants/app_strings.dart';

class RecurringTasksScreen extends StatelessWidget {
  const RecurringTasksScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text(AppStrings.recurringTasks)),
      body: const Center(child: Text(AppStrings.recurringTasks)),
    );
  }
}
