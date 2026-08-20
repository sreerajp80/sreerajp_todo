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
import 'package:sreerajp_todo/data/models/todo_search_result.dart';
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
      data: (results) {
        if (results.isEmpty) {
          return AppEmptyState(
            icon: Icons.search_off,
            title: context.l10n.noSearchResults,
            message: context.l10n.noSearchResultsForQuery(_currentQuery),
          );
        }

        final grouped = _groupByDate(results);
        final dates = grouped.keys.toList()..sort((a, b) => b.compareTo(a));

        return ListView.builder(
          itemCount: dates.length,
          itemBuilder: (context, index) {
            final date = dates[index];
            final dateResults = grouped[date]!;

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
                ...dateResults.map(
                  (result) => ListTile(
                    title: Text(result.todo.title),
                    subtitle: _buildSubtitle(context, result),
                    trailing: StatusBadge(
                      label: _statusLabel(context, result.todo.status),
                      status: result.todo.status,
                    ),
                    onTap: () =>
                        context.go(AppRoutes.dailyListPath(result.todo.date)),
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

  /// Shows the segment note when that is why the row matched, so the user can
  /// see where the hit came from. Otherwise falls back to the description.
  Widget? _buildSubtitle(BuildContext context, TodoSearchResult result) {
    final matchedNote = result.matchedNote;
    if (matchedNote != null && matchedNote.isNotEmpty) {
      return Text(
        context.l10n.matchedInNote(matchedNote),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(color: Theme.of(context).colorScheme.primary),
      );
    }

    final description = result.todo.description;
    if (description == null || description.isEmpty) return null;

    return Text(description, maxLines: 1, overflow: TextOverflow.ellipsis);
  }

  Map<String, List<TodoSearchResult>> _groupByDate(
    List<TodoSearchResult> results,
  ) {
    final grouped = <String, List<TodoSearchResult>>{};
    for (final result in results) {
      grouped.putIfAbsent(result.todo.date, () => []).add(result);
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
