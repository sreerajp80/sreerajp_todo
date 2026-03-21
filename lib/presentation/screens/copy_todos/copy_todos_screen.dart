import 'package:flutter/material.dart';
import 'package:sreerajp_todo/core/constants/app_strings.dart';

class CopyTodosScreen extends StatelessWidget {
  const CopyTodosScreen({super.key, this.fromDate});

  final String? fromDate;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text(AppStrings.copyTodos)),
      body: const Center(child: Text(AppStrings.copyTodos)),
    );
  }
}
