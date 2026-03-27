import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sreerajp_todo/application/providers.dart';
import 'package:sreerajp_todo/core/constants/app_routes.dart';
import 'package:sreerajp_todo/core/constants/app_strings.dart';
import 'package:sreerajp_todo/core/utils/date_utils.dart';
import 'package:sreerajp_todo/core/utils/rrule_display_utils.dart';
import 'package:sreerajp_todo/data/models/recurrence_rule_entity.dart';
import 'package:sreerajp_todo/presentation/shared/widgets/app_empty_state.dart';
import 'package:sreerajp_todo/presentation/shared/widgets/app_error_state.dart';
import 'package:sreerajp_todo/presentation/shared/widgets/confirm_dialog.dart';

class RecurringTasksScreen extends ConsumerWidget {
  const RecurringTasksScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final rulesAsync = ref.watch(recurrenceRulesProvider);

    return Scaffold(
      appBar: AppBar(title: const Text(AppStrings.recurringTasks)),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push(AppRoutes.recurringNew),
        tooltip: AppStrings.newRecurrence,
        child: const Icon(Icons.add),
      ),
      body: rulesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => AppErrorState(
          message: AppStrings.errors.retryableGeneric,
          onRetry: () => ref.invalidate(recurrenceRulesProvider),
        ),
        data: (rules) => rules.isEmpty
            ? AppEmptyState(
                icon: Icons.repeat,
                title: AppStrings.noRecurrenceRules,
                message: AppStrings.noRecurringTasksDetailed,
                actionLabel: AppStrings.newRecurrence,
                onAction: () => context.push(AppRoutes.recurringNew),
              )
            : ListView.builder(
                padding: const EdgeInsets.only(bottom: 88),
                itemCount: rules.length,
                itemBuilder: (context, index) {
                  final rule = rules[index];
                  return _RuleTile(rule: rule);
                },
              ),
      ),
    );
  }
}

class _RuleTile extends ConsumerWidget {
  const _RuleTile({required this.rule});

  final RecurrenceRuleEntity rule;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final description = describeRrule(rule.rrule);
    final endDateText = rule.endDate != null
        ? formatDateFromIso(rule.endDate!)
        : AppStrings.noEndDate;

    return Dismissible(
      key: ValueKey(rule.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        color: theme.colorScheme.error,
        child: Icon(Icons.delete, color: theme.colorScheme.onError),
      ),
      confirmDismiss: (_) async {
        return showConfirmDialog(
          context,
          title: AppStrings.deleteRecurrenceRule,
          content: AppStrings.deleteRecurrenceRuleBody,
        );
      },
      onDismissed: (_) {
        ref.read(recurrenceRulesProvider.notifier).deleteRule(rule.id);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text(AppStrings.recurrenceRuleDeleted)),
        );
      },
      child: Card(
        child: ListTile(
          onTap: () => context.push(AppRoutes.recurringEditPath(rule.id)),
          leading: Icon(
            Icons.repeat,
            color: rule.active
                ? theme.colorScheme.primary
                : theme.colorScheme.onSurface.withValues(alpha: 0.4),
          ),
          title: Text(
            rule.title,
            style: theme.textTheme.titleSmall?.copyWith(
              color: rule.active
                  ? null
                  : theme.colorScheme.onSurface.withValues(alpha: 0.5),
            ),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(description),
              Text(
                '${formatDateFromIso(rule.startDate)} - $endDateText',
                style: theme.textTheme.bodySmall,
              ),
            ],
          ),
          trailing: Switch(
            value: rule.active,
            onChanged: (_) {
              ref.read(recurrenceRulesProvider.notifier).toggleActive(rule.id);
            },
          ),
          isThreeLine: true,
        ),
      ),
    );
  }
}
