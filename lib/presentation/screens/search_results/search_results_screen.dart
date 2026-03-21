import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sreerajp_todo/application/providers.dart';
import 'package:sreerajp_todo/core/constants/app_constants.dart';
import 'package:sreerajp_todo/core/constants/app_routes.dart';
import 'package:sreerajp_todo/core/constants/app_strings.dart';
import 'package:sreerajp_todo/core/utils/date_utils.dart';
import 'package:sreerajp_todo/core/utils/unicode_utils.dart';
import 'package:sreerajp_todo/data/models/todo_entity.dart';
import 'package:sreerajp_todo/data/models/todo_status.dart';
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
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _searchController,
          autofocus: widget.query == null || widget.query!.isEmpty,
          decoration: const InputDecoration(
            hintText: AppStrings.searchHint,
            border: InputBorder.none,
            prefixIcon: Icon(Icons.search),
          ),
          onChanged: _onSearchChanged,
        ),
        actions: [
          if (_searchController.text.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.clear),
              onPressed: () {
                _searchController.clear();
                setState(() => _currentQuery = '');
              },
            ),
        ],
      ),
      body: _currentQuery.isEmpty
          ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.search,
                    size: 64,
                    color:
                        theme.colorScheme.onSurface.withValues(alpha: 0.3),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    AppStrings.searchHint,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: theme.colorScheme.onSurface
                          .withValues(alpha: 0.5),
                    ),
                  ),
                ],
              ),
            )
          : _buildResults(theme),
    );
  }

  Widget _buildResults(ThemeData theme) {
    final results = ref.watch(searchResultsProvider(_currentQuery));

    return results.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => Center(child: Text(error.toString())),
      data: (todos) {
        if (todos.isEmpty) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.search_off,
                  size: 64,
                  color:
                      theme.colorScheme.onSurface.withValues(alpha: 0.3),
                ),
                const SizedBox(height: 16),
                Text(
                  AppStrings.noSearchResults,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color:
                        theme.colorScheme.onSurface.withValues(alpha: 0.5),
                  ),
                ),
              ],
            ),
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
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Text(
                    formatDateFromIso(date),
                    style: theme.textTheme.titleSmall?.copyWith(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.w600,
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
                      label: _statusLabel(todo.status),
                      color: _statusColor(todo.status, theme.colorScheme),
                    ),
                    onTap: () =>
                        context.go(AppRoutes.dailyListPath(todo.date)),
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
    final map = <String, List<TodoEntity>>{};
    for (final todo in todos) {
      map.putIfAbsent(todo.date, () => []).add(todo);
    }
    return map;
  }

  String _statusLabel(TodoStatus status) {
    return switch (status) {
      TodoStatus.completed => AppStrings.statusCompleted,
      TodoStatus.dropped => AppStrings.statusDropped,
      TodoStatus.ported => AppStrings.statusPorted,
      TodoStatus.pending => AppStrings.statusPending,
    };
  }

  Color _statusColor(TodoStatus status, ColorScheme colorScheme) {
    return switch (status) {
      TodoStatus.completed => const Color(0xFF2E7D32),
      TodoStatus.dropped => const Color(0xFFC62828),
      TodoStatus.ported => const Color(0xFFF9A825),
      TodoStatus.pending => colorScheme.onSurfaceVariant,
    };
  }
}
