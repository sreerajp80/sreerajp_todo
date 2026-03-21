# Phase 6 — Statistics Screen

## Objective
Build a dashboard with two tabs (Daily Overview, Per-Item Overview) showing productivity insights via charts and paginated data tables, computed on-the-fly from SQL aggregate queries.

## Pre-Requisites
- Phases 1–5B complete (all data, CRUD, time tracking, copy/port, backup).
- `StatisticsQueryService` created in Phase 2 with aggregate query methods.
- `fl_chart` package installed.
- Read `CLAUDE.md` — statistics rules, dropped ≠ completed in stats, pagination, no compute/isolate.
- Read `docs/architecture.md` — data flow (§6), provider types (§5), performance constraints (§14).
- Read `docs/flutter_project_engineering_standard.md` — UI/UX baseline (§6 — screen states: loading, empty, success, error), testing standard (§9), coding standards (§8), Definition of Done (§14).

## Key Design Decisions
- Stats computed **on-the-fly** via SQL — no separate stats table.
- Paginated queries: 20 rows per page with `LIMIT 20 OFFSET ?`.
- 10-second result cache in `StatisticsNotifier` to avoid redundant queries.
- **Dropped time ≠ Completed time** — reported separately:
  - Time on completed tasks → "Productive time"
  - Time on dropped tasks → "Dropped/sunk time"
- No `compute()` or `Isolate.spawn()` — sqflite handles not transferable across isolates.
- If frame jank > 16 ms: open a second read-only DB connection for stats queries.

---

## Tasks

### 1. Statistics Screen (`/statistics`) — `lib/presentation/screens/statistics/`

#### `statistics_screen.dart`
- Two tabs via `TabBar` + `TabBarView`:
  - **Daily Overview** tab
  - **Per-Item Overview** tab
- Accessible from the main navigation rail / app bar overflow menu on daily list.

### 2. Daily Overview Tab

#### Components:

**Date range filter** (at top):
- Segmented control: "Last 7 days", "Last 30 days", "All time", "Custom range".
- Custom range: two date pickers (start date, end date).
- Changing the filter refreshes the chart and table.

**Bar chart** (`widgets/daily_bar_chart.dart`):
- Uses `fl_chart` `BarChart`.
- Grouped bars per day:
  - Green = completed
  - Red = dropped
  - Amber = ported
  - Grey = pending
- X-axis: dates (formatted short, e.g., "Mar 15").
- Y-axis: count of todos.
- Scrollable horizontally if more than 7 days.

**Summary cards row**:
- Total todos (all time within selected range).
- Average completed per day.
- Average time per day (HH:MM:SS format).
- Total productive time (time on completed tasks).
- Total dropped time (time on dropped tasks).

**Data table** (`widgets/daily_stats_table.dart`):
- Columns: Date | Total | Completed | Dropped | Ported | Pending | Total Time
- 20 rows per page with "Previous" / "Next" pagination buttons.
- Current page indicator: "Page 1 of N".
- Tapping a date row navigates to `/day/:date`.

### 3. Per-Item Overview Tab

#### Components:

**Search/filter bar**:
- Text field to search for a specific todo title (Unicode-aware, NFC-normalised query).
- Filters the table and chart below.

**Line chart** (`widgets/per_item_line_chart.dart`):
- Uses `fl_chart` `LineChart`.
- For a selected title: shows time spent (Y-axis, minutes) vs date (X-axis).
- Chart updates when a title is selected from the table or search.
- Empty state: "Select a task to view its time history".

**Data table** (`widgets/per_item_stats_table.dart`):
- Columns: Title | Appearances | Completed | Dropped | Ported | Total Time
- 20 rows per page with pagination.
- Sorted by total time descending (most-tracked items first) — or allow column sorting.
- Tapping a row:
  1. Selects the title for the line chart above.
  2. Optionally drills into a **single-item detail view**: calendar heatmap showing which days that item appeared and its status on each day.

### 4. `StatisticsNotifier` (`lib/application/statistics_notifier.dart`)

Exposed via `statisticsProvider`:
```dart
final statisticsProvider = StateNotifierProvider<StatisticsNotifier, StatisticsState>((ref) {
  return StatisticsNotifier(ref.read(statisticsQueryServiceProvider));
});
```

#### State:
```dart
@freezed
class StatisticsState with _$StatisticsState {
  const factory StatisticsState({
    // Daily overview
    @Default([]) List<DayStats> dailyStats,
    @Default(0) int dailyCurrentPage,
    @Default(0) int dailyTotalPages,
    @Default(DateRange.last7Days) DateRange dateRange,
    DateTime? customStartDate,
    DateTime? customEndDate,

    // Per-item overview
    @Default([]) List<TodoTimeStats> perItemStats,
    @Default(0) int perItemCurrentPage,
    @Default(0) int perItemTotalPages,
    String? selectedTitle,  // for line chart
    @Default([]) List<TodoTimeStats> selectedTitleHistory,  // time series for selected title

    // General
    @Default(false) bool isLoading,
    String? error,
  }) = _StatisticsState;
}
```

#### Methods:
- `loadDailyStats({int page = 0})` — paginated daily aggregates.
- `loadPerItemStats({int page = 0})` — paginated per-item aggregates.
- `setDateRange(DateRange range, {DateTime? start, DateTime? end})` — updates filter, reloads.
- `selectTitle(String title)` — loads time series for selected title.
- `nextDailyPage()` / `previousDailyPage()` — pagination.
- `nextPerItemPage()` / `previousPerItemPage()` — pagination.
- `refresh()` — called when navigating to stats screen and after data mutations.

#### Caching:
- Cache the last result for 10 seconds.
- If `refresh()` called within 10s of last load, return cached data.
- Cache invalidated by `setDateRange()` or `selectTitle()`.

### 5. `StatisticsQueryService` Enhancements

Extend the query service (created in Phase 2) with additional methods if needed:

```dart
/// Daily stats filtered by date range
Future<List<DayStats>> getCountsPerDay({
  int limit = 20,
  int offset = 0,
  String? startDate,
  String? endDate,
});

/// Total count of days in range (for pagination)
Future<int> getDayCount({String? startDate, String? endDate});

/// Time spent per todo, separated by status (for productive vs dropped time)
Future<List<TodoTimeStats>> getTimePerTodoPerDay({
  int limit = 20,
  int offset = 0,
  String? startDate,
  String? endDate,
});

/// Time series for a specific title across all dates
Future<List<TodoTimeStats>> getTimeSeriesForTitle(String title);

/// Summary statistics for the selected range
Future<SummaryStats> getSummaryStats({String? startDate, String? endDate});
```

#### `SummaryStats` model:
```dart
class SummaryStats {
  final int totalTodos;
  final double avgCompletedPerDay;
  final int avgTimePerDaySeconds;
  final int totalProductiveTimeSeconds;  // time on completed tasks
  final int totalDroppedTimeSeconds;     // time on dropped tasks
}
```

#### SQL for productive vs dropped time:
```sql
-- Productive time (completed tasks)
SELECT COALESCE(SUM(ts.duration_seconds), 0) AS productive_seconds
FROM time_segments ts
JOIN todos t ON ts.todo_id = t.id
WHERE t.status = 'completed'
  AND t.date BETWEEN ? AND ?;

-- Dropped time
SELECT COALESCE(SUM(ts.duration_seconds), 0) AS dropped_seconds
FROM time_segments ts
JOIN todos t ON ts.todo_id = t.id
WHERE t.status = 'dropped'
  AND t.date BETWEEN ? AND ?;
```

### 6. Responsive Layout

- **Mobile** (< 600 dp): single-column layout, charts stacked above tables.
- **Desktop/tablet** (≥ 600 dp): two-column layout where possible (chart left, table right).

### 7. Performance Considerations

- All queries use `LIMIT/OFFSET` — never load all data at once.
- `ListView.builder` for data tables if they scroll.
- 10-second cache prevents redundant queries on tab switches.
- If profiling shows jank: `await Future.delayed(Duration.zero)` between heavy batches.
- Last resort: open a second read-only DB connection for stats queries.
- **Never** use `compute()` or isolates for sqflite queries.

---

## Tests to Write During This Phase

### Unit Tests — `StatisticsQueryService` (extend from Phase 2)
- `getCountsPerDay`: seed data → verify correct counts per day.
- Pagination: page 1 returns first 20, page 2 returns next 20.
- Date range filter: only returns data within range.
- `getSummaryStats`: correct averages, productive vs dropped time separation.
- `getTimeSeriesForTitle`: returns correct time series for a given title.

### Widget Tests — `test/presentation/statistics_screen_test.dart`
- Statistics screen renders without exceptions with mock data.
- Tab switching works (Daily Overview ↔ Per-Item Overview).
- Date range selector updates displayed data.
- Pagination buttons navigate pages correctly.
- Charts render without exceptions (mock `fl_chart` data).

---

## Constraints
- All queries via `StatisticsQueryService` — no direct DB access from widgets.
- Duration displayed as `HH:MM:SS`.
- Counts are plain integers — no percentage unless explicitly derived.
- All strings in `app_strings.dart`.
- No compute/isolate for DB queries.
- Dropped ≠ completed in all statistics.

## Deliverables
- [ ] Daily Overview tab: bar chart + summary cards + paginated table
- [ ] Per-Item Overview tab: line chart + search/filter + paginated table
- [ ] Date range filter (7d, 30d, all, custom) works
- [ ] Productive vs dropped time reported separately
- [ ] Pagination (20 rows/page) with Previous/Next controls
- [ ] 10-second result cache working
- [ ] Responsive layout (mobile vs desktop)
- [ ] Charts render correctly with real data
- [ ] All tests passing
