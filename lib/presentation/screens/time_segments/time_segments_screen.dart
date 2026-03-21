import 'package:flutter/material.dart';
import 'package:sreerajp_todo/core/constants/app_strings.dart';

class TimeSegmentsScreen extends StatelessWidget {
  const TimeSegmentsScreen({super.key, required this.todoId});

  final String todoId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text(AppStrings.timeSegments)),
      body: Center(child: Text('${AppStrings.timeSegments} for $todoId')),
    );
  }
}
