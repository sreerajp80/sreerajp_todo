import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sreerajp_todo/application/providers.dart';
import 'package:sreerajp_todo/core/constants/app_constants.dart';
import 'package:sreerajp_todo/core/constants/app_routes.dart';
import 'package:sreerajp_todo/core/errors/error_message_mapper.dart';
import 'package:sreerajp_todo/core/extensions/localization_extensions.dart';
import 'package:sreerajp_todo/core/utils/date_utils.dart';
import 'package:sreerajp_todo/core/utils/unicode_utils.dart';
import 'package:sreerajp_todo/data/models/todo_entity.dart';
import 'package:sreerajp_todo/data/models/todo_status.dart';
import 'package:sreerajp_todo/presentation/shared/widgets/adaptive_directionality.dart';
import 'package:sreerajp_todo/presentation/shared/widgets/app_empty_state.dart';
import 'package:sreerajp_todo/presentation/shared/widgets/app_error_state.dart';
import 'package:sreerajp_todo/presentation/shared/widgets/status_badge.dart';

class SearchResultsScreen extends ConsumerStatefulWidget {
  const SearchResultsScreen({super.key, this.query});

  final String? query;

  @override
  ConsumerState<SearchResultsScreen> createState() =>
      _SearchResultsScreenState();
}

class _SearchResultsScreenState extends ConsumerState<SearchResultsScreen> {
  late final TextEditingController _searchController;
  Timer? _debounce;
  String _currentQuery = '';

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController(text: widget.query ?? '');
    _currentQuery = nfcNormalize(widget.query ?? '');
  }

  @override
  void dispose() {
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onSearchChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(
      const Duration(milliseconds: kAutocompleteDebounceMills),
      () {
        final normalized = nfcNormalize(value.trim());
        if (normalized != _currentQuery) {
          setState(() => _currentQuery = normalized);
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: AdaptiveDirectionality(
          text: _searchController.text,
          child: TextField(
            controller: _searchController,
            autofocus: widget.query == null || widget.query!.isEmpty,
            decoration: InputDecoration(
              hintText: context.l10n.searchHint,
              border: InputBorder.none,
              prefixIcon: const Icon(Icons.search),
            ),
            onChanged: _onSearchChanged,
          ),
        ),
        actions: [
          if (_searchController.text.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.clear),
              tooltip: context.l10n.clearSearch,
              onPressed: () {
                _searchController.clear();
                setState(() => _currentQuery = '');
              },
            ),
        ],
      ),
      body: _currentQuery.isEmpty
          ? AppEmptyState(
              icon: Icons.search,
              title: context.l10n.searchTasksTitle,
              message: context.l10n.searchTasksMessage,
            )
          : _buildResults(),
    );
  }

  Widget _buildResults() {
    final results = ref.watch(searchResultsProvider(_currentQuery));

    return results.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => AppErrorState(
        message: mapErrorToMessage(context.l10n, error),
        onRetry: () => ref.invalidate(searchResultsProvider(_currentQuery)),
      ),
      data: (todos) {
        if (todos.isEmpty) {
          return AppEmptyState(
            icon: Icons.search_off,
            title: context.l10n.noSearchResults,
            message: context.l10n.noSearchResultsForQuery(_currentQuery),
          );
        }

        final grouped = _groupByDate(todos);
        final dates = grouped.keys.toList()..sort((a, b) => b.compareTo(a));

        return ListView.builder(
          itemCount: dates.length,
          itemBuilder: (context, index) {
            final date = dates[index];
            final dateTodos = grouped[date]!;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: Text(
                    formatDateFromIso(date),
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                ...dateTodos.map(
                  (todo) => ListTile(
                    title: Text(todo.title),
                    subtitle: todo.description != null
                        ? Text(
                            todo.description!,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          )
                        : null,
                    trailing: StatusBadge(
                      label: _statusLabel(context, todo.status),
                      status: todo.status,
                    ),
                    onTap: () => context.go(AppRoutes.dailyListPath(todo.date)),
                  ),
                ),
                if (index < dates.length - 1) const Divider(),
              ],
            );
          },
        );
      },
    );
  }

  Map<String, List<TodoEntity>> _groupByDate(List<TodoEntity> todos) {
    final grouped = <String, List<TodoEntity>>{};
    for (final todo in todos) {
      grouped.putIfAbsent(todo.date, () => []).add(todo);
    }
    return grouped;
  }

  String _statusLabel(BuildContext context, TodoStatus status) {
    return switch (status) {
      TodoStatus.pending => context.l10n.statusPending,
      TodoStatus.working => context.l10n.statusWorking,
      TodoStatus.completed => context.l10n.statusCompleted,
      TodoStatus.dropped => context.l10n.statusDropped,
      TodoStatus.ported => context.l10n.statusPorted,
    };
  }
}
