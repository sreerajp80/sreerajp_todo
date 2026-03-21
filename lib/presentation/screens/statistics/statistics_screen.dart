import 'package:flutter/material.dart';
import 'package:sreerajp_todo/core/constants/app_strings.dart';

class StatisticsScreen extends StatelessWidget {
  const StatisticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text(AppStrings.statistics)),
      body: const Center(child: Text(AppStrings.statistics)),
    );
  }
}
