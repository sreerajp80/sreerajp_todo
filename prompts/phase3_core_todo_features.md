# Phase 3 — Core ToDo Features

## Objective
Build full CRUD for ToDo items: daily list screen, create/edit screen, autocomplete, status changes with undo, multi-select bulk operations, cross-day search, drag-to-reorder, and day lock enforcement.

## Pre-Requisites
- Phase 1 & 2 complete (project scaffolded, DB layer with all DAOs, models, and repositories working with passing tests).
- Read `CLAUDE.md` — non-negotiable rules, architecture, naming conventions.

## Architecture Reminder
```
Widget → Provider/Notifier → UseCase (multi-step) → Repository → DAO → sqflite
Widget → Provider/Notifier → Repository → DAO → sqflite  (simple CRUD)
```
- Widgets never import DAOs directly.
- Widgets consume only Riverpod providers from `lib/application/providers.dart`.
- All user-visible strings in `lib/core/constants/app_strings.dart`.
- No hardcoded strings in widget files.
- Use `context.go()` / `context.push()` / `context.pop()` from `go_router` — never `Navigator.push()`.

---

## Tasks

### 1. Daily ToDo List Screen (`/day/:date`) — `lib/presentation/screens/daily_list/`

#### `daily_list_screen.dart`
- **Header**: formatted date (via `intl` `DateFormat`), left/right arrow buttons for previous/next day, a "Today" button that jumps to today's date.
- **Calendar picker**: `table_calendar` mini-calendar accessible via a calendar icon in the app bar for date jumping.
- **Search icon** in the app bar → navigates to `/search`.
- **Recurring tasks icon** in app bar overflow menu → navigates to `/recurring`.
- **Backup icon** in app bar overflow menu → navigates to `/backup`.
- **Statistics icon** in app bar overflow menu → navigates to `/statistics`.
- **Todo list**: `ListView.builder` (lazy rendering) showing todos ordered by `sort_order`.
- **Each list tile** (`todo_list_tile.dart`) shows:
  - Title (with optional 🔁 icon if `recurrenceRuleId` is set)
  - Status badge (colour-coded: green=completed, red=dropped, amber=ported, grey=pending)
  - Total time spent (HH:MM:SS)
  - Start/stop button (hidden for completed/dropped, disabled for past dates)
  - Overflow menu: Edit, Delete, Port, Copy
  - "Copied from YYYY-MM-DD" subtitle if `sourceDate` is set
  - "→ YYYY-MM-DD" badge if status = ported
- **Lock indicator**: past-date items show a padlock icon; all interactive controls disabled.
- **FAB**: "Add new todo" — disabled (hidden) for past dates.
- **Drag-to-reorder**: `ReorderableListView.builder` — updates `sort_order` for all affected rows in a single transaction.

#### Multi-Select Mode
- **Trigger**: long-press on a list tile enters multi-select mode.
- **App bar transforms** to show:
  - "X selected" count
  - "Complete All" action button
  - "Mark Dropped" action button (with confirmation dialog)
  - "Copy" button → navigates to `/copy` with pre-selected items
- Bulk port is excluded (each port requires a unique target date).
- All bulk status changes wrapped in a **single DB transaction**.
- A single **undo SnackBar** reverts the entire batch.

### 2. Create `DailyTodoNotifier` (`lib/application/daily_todo_notifier.dart`)

A `StateNotifier` exposed via `StateNotifierProvider.family<DailyTodoNotifier, DailyTodoState, String>` where the family parameter is the date string.

#### State class (`DailyTodoState`):
```dart
@freezed
class DailyTodoState with _$DailyTodoState {
  const factory DailyTodoState({
    @Default([]) List<TodoEntity> todos,
    @Default(false) bool isLoading,
    String? error,
    @Default([]) List<UndoEntry> undoStack,
    @Default({}) Set<String> selectedIds,  // multi-select
    @Default(false) bool isMultiSelectMode,
  }) = _DailyTodoState;
}
```

#### UndoEntry:
```dart
@freezed
class UndoEntry with _$UndoEntry {
  const factory UndoEntry({
    required String todoId,
    required TodoStatus oldStatus,
    required TodoStatus newStatus,
    String? copiedTodoId,  // for port undo — delete the copy
    required DateTime timestamp,
  }) = _UndoEntry;
}
```

#### Key methods:
- `loadTodos()` — fetches from repository, sets state
- `createTodo(TodoEntity)` — validates, inserts via repository, refreshes
- `updateTodo(TodoEntity)` — validates, updates via repository, refreshes
- `deleteTodo(String id)` — confirmation handled in UI, deletes via repository
- `markCompleted(String todoId)` — calls `MarkTodoCompleted` use-case
- `markDropped(String todoId)` — calls `MarkTodoDropped` use-case
- `portTodo(String todoId, String targetDate)` — calls `PortTodo` use-case
- `bulkMarkCompleted(Set<String> ids)` — wraps all in transaction via use-case
- `bulkMarkDropped(Set<String> ids)` — wraps all in transaction via use-case
- `undoLastStatusChange()` — pops undo stack, reverts status, deletes port copy if applicable
- `reorder(int oldIndex, int newIndex)` — updates sort orders
- `toggleSelect(String id)` / `clearSelection()` / `selectAll()`
- Undo stack: max 5 entries, clears on day navigation or after 2 minutes of inactivity.

### 3. Create / Edit ToDo Screen (`/todo/new` and `/todo/:id`) — `lib/presentation/screens/create_edit_todo/`

#### `create_edit_todo_screen.dart`
- **Title field**: `TextFormField` with:
  - Unicode support — `textDirection` auto-detected via `detectTextDirection()`.
  - Mandatory validation.
  - Real-time uniqueness check (debounce 300 ms) via `TodoDao.existsTitleOnDate()`.
  - `Autocomplete<String>` widget backed by `autocompleteProvider(prefix)`.
- **Description field**: multiline `TextFormField`, optional, Unicode-aware, auto-detected text direction.
- **Status selector**: segmented control — Pending, Completed, Dropped, Ported.
  - When Ported is selected → date picker for target date (must be ≥ tomorrow).
  - Changing to Dropped or Ported shows **confirmation dialog**.
  - Changing to Completed does NOT require confirmation (most common action).
- **Save button**: NFC-normalise title → uniqueness check → upsert.
- In **edit mode**: pre-populate all fields from the existing todo.
- **Read-only** for past-date todos (all fields disabled, no save button).

#### `widgets/title_autocomplete_field.dart`
- Wraps `Autocomplete<String>` with the debounced provider.
- Shows dropdown of suggestions from `autocompleteProvider(prefix)`.

### 4. Use-Cases (`lib/domain/usecases/`)

#### `MarkTodoCompleted` (`mark_todo_completed.dart`)
1. Find running time segment for this todo → close it (set `end_time = now`, compute `duration_seconds`).
2. Set `todo.status = completed`.
3. Return the `UndoEntry`.

#### `MarkTodoDropped` (`mark_todo_dropped.dart`)
1. Find running time segment → close it.
2. Set `todo.status = dropped`.
3. Return the `UndoEntry`.

#### `PortTodo` (`port_todo.dart`)
1. Validate target date ≥ tomorrow.
2. Check title uniqueness on target date — throw `DuplicateTitleException` if conflict.
3. Create a copy on target date: fresh UUID, `status = pending`, `source_date = original.date`, `ported_to = null`, `sort_order` = append at end.
4. Mark source as `status = ported`, `ported_to = targetDate`.
5. All in a single transaction.
6. Return `UndoEntry` with `copiedTodoId`.

#### `CopyTodos` (`copy_todos.dart`)
1. For each selected todo:
   - Read source entity.
   - Check title uniqueness on target date.
   - If conflict: skip, add to skip list.
   - If no conflict: insert copy with fresh UUID, `status = pending`, `source_date`.
2. All inserts in a single transaction.
3. Return `({List<TodoEntity> copied, List<TodoEntity> skipped})`.

### 5. Autocomplete Provider

In `providers.dart`:
```dart
final autocompleteProvider = FutureProvider.family<List<String>, String>((ref, prefix) {
  final dao = ref.read(todoDaoProvider);
  return dao.getAllDistinctTitles(prefix);
});
```
- Fires on each debounced keystroke (300 ms).
- DAO query: `LIKE ? || '%'` with `LIMIT 20`, backed by `idx_todos_title`.
- No in-memory cache.

### 6. Cross-Day Search Screen (`/search`) — `lib/presentation/screens/search_results/`

#### `search_results_screen.dart`
- Search bar with text field.
- Results from `searchResultsProvider(query)` — a `FutureProvider.family`.
- Results displayed **grouped by date** (date header → list of matching todos under it).
- Tapping a result navigates to `/day/:date`.
- Unicode-aware search (NFC-normalised query).

#### Provider:
```dart
final searchResultsProvider = FutureProvider.family<List<TodoEntity>, String>((ref, query) {
  final dao = ref.read(todoDaoProvider);
  return dao.searchByTitle(query);
});
```

### 7. Day Lock Enforcement

#### Repository layer:
- Every mutating method in `TodoRepositoryImpl` checks `isPastDate(todo.date)`.
- Throws `DayLockedException` unless `bypassLock = true`.
- `bypassLock` exists only for future internal tooling — never exposed to UI.

#### UI layer:
- Past-date detection: `isPastDate(date)` from `date_utils.dart`.
- When viewing a past date:
  - FAB hidden.
  - All list tile controls disabled.
  - Padlock icon shown.
  - Create/edit screen is read-only.
  - Status selector disabled.

### 8. Delete ToDo
- Confirmation dialog before delete.
- Cascades delete of all `time_segments` via DB foreign key.
- Disabled for past dates (button not shown).

### 9. Shared Widgets (`lib/presentation/shared/widgets/`)

#### `status_badge.dart`
Colour-coded badge for todo status:
- Pending → grey
- Completed → green
- Dropped → red
- Ported → amber

#### `confirm_dialog.dart`
Reusable confirmation dialog with title, message, confirm/cancel buttons.

#### `undo_status_snackbar.dart`
- Shows after any terminal status change.
- "Undo" action button.
- 5-second auto-dismiss.

#### `locked_overlay.dart`
Visual overlay/indicator for locked (past-date) items.

### 10. Undo Mechanism

Two undo surfaces:
1. **SnackBar** with "Undo" action — 5-second auto-dismiss. For immediate "oops" recovery.
2. **Persistent undo button (↩)** in the app bar — visible whenever the undo stack is non-empty. Pops and reverts the most recent change.

Undo stack:
- Max 5 entries.
- Clears on day navigation.
- Clears after 2 minutes of inactivity.
- `undoLastStatusChange()`:
  - Reverts status to `oldStatus`.
  - If the change was a port: deletes the copy created on the target date (within a transaction).

---

## Tests to Write During This Phase

### Repository Unit Tests (`test/domain/todo_repository_test.dart`)
- Day lock: mutating a past-date todo throws `DayLockedException`.
- Day lock: `bypassLock = true` allows mutation.
- Status transitions: pending → completed, pending → dropped, pending → ported.
- Title uniqueness: inserting duplicate title on same date throws `DuplicateTitleException`.
- NFC normalisation: composed and decomposed titles treated as the same.

### Use-Case Unit Tests
- `test/domain/usecases/mark_todo_completed_test.dart`: closes open segment + sets status.
- `test/domain/usecases/port_todo_test.dart`: creates copy + marks source + returns undo entry.
- `test/domain/usecases/copy_todos_test.dart`: copies non-conflicting, skips conflicting.

### Widget Tests
- `test/presentation/daily_list_screen_test.dart`:
  - Renders todos for a given date.
  - Shows lock icon for past date.
  - Multi-select mode activates on long press.
  - FAB hidden for past dates.
- `test/presentation/create_edit_screen_test.dart`:
  - Title field is mandatory.
  - Autocomplete suggestions appear.
  - Uniqueness error shown for duplicate title.
  - Read-only for past-date todo.

### Undo Tests
- Mark completed → undo within 5s → status reverts to pending.
- Mark ported → undo → copy deleted, source reverts to pending.
- Bulk mark 3 as completed → single undo → all 3 revert.

---

## Constraints
- All strings in `app_strings.dart`.
- No business logic in widget files — move to Notifier, Use-Case, or Repository.
- NFC-normalise before every DB write.
- Use `go_router` navigation only.
- `ListView.builder` for lazy rendering.
- Status badge colours must have contrast ratio ≥ 4.5:1 in both light and dark themes.

## Deliverables
- [ ] Full CRUD working end-to-end
- [ ] Autocomplete functioning for Unicode titles
- [ ] Cross-day search working with Unicode support
- [ ] Undo SnackBar + persistent undo button for all status changes
- [ ] Multi-select bulk status change with undo
- [ ] Drag-to-reorder within day list
- [ ] Day lock visually and functionally enforced
- [ ] Confirmation dialogs for dropped/ported status changes
- [ ] All tests passing
