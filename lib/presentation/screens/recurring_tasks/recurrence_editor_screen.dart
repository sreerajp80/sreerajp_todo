import 'package:flutter/material.dart';
import 'package:sreerajp_todo/core/constants/app_strings.dart';

class RecurrenceEditorScreen extends StatelessWidget {
  const RecurrenceEditorScreen({super.key, this.ruleId});

  final String? ruleId;

  bool get isEditing => ruleId != null;

  @override
  Widget build(BuildContext context) {
    final title = isEditing
        ? AppStrings.editRecurrence
        : AppStrings.newRecurrence;
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(child: Text(title)),
    );
  }
}
