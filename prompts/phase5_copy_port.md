# Phase 5 — Copy / Port Features

## Objective
Allow copying one or more ToDo items to another day, and implement the port workflow (move a task forward by marking source as ported and creating a copy on the target date).

## Pre-Requisites
- Phases 1–4 complete (DB layer, CRUD, status changes with undo, time tracking).
- `CopyTodos` and `PortTodo` use-cases defined in Phase 3 — may need refinement.
- Read `CLAUDE.md` — rules on copying, porting, source_date, ported_to.
- Read `docs/architecture.md` — data flow (§6), use-case pattern, navigation (§9).
- Read `docs/flutter_project_engineering_standard.md` — testing standard (§9), UX rules (§6.4 — destructive actions require confirmation or undo), Definition of Done (§14).

## Key Business Rules
- **Copy**: source item status unchanged. New item on target date with `status = pending`, `source_date = original.date`.
- **Port**: source marked `ported` with `ported_to = targetDate`. Copy created on target date. Undo deletes the copy and reverts source status.
- Time segments are **never** copied — fresh tracking on new day.
- Title uniqueness enforced per day — skip items that conflict.
- Copy and port require target date ≥ today (can be today itself for copy; must be ≥ tomorrow for port).

---

## Tasks

### 1. Copy Screen (`/copy`) — `lib/presentation/screens/copy_todos/copy_todos_screen.dart`

A multi-step wizard:

**Entry points:**
- "Copy to another day" in daily list overflow menu.
- "Copy" button in multi-select mode (items pre-selected).
- Query param: `?from=YYYY-MM-DD` (source date).

**Step 1 — Select Items:**
- Display all todos from the source date with checkboxes.
- If items were pre-selected from multi-select mode, show them pre-checked.
- "Select All" / "Deselect All" buttons.

**Step 2 — Pick Target Date:**
- Date picker (using `table_calendar` or `showDatePicker`).
- Target date must be ≥ today.
- For port: target date must be ≥ tomorrow (can't port to same day).

**Step 3 — Preview:**
- Show list of items to be copied with conflict detection.
- Items that already exist on the target date (same title after NFC normalisation) shown with a warning icon and "Already exists — will be skipped".
- Option to deselect individual items.
- Confirm button.

**Result:**
- Returns result via `context.pop<CopyResult>(result)` to the calling screen.
- Result includes: number copied, list of skipped items.
- Show a SnackBar summarising the result.

### 2. `CopyTodos` Use-Case (refine from Phase 3)

`lib/domain/usecases/copy_todos.dart`:

```dart
class CopyResult {
  final List<TodoEntity> copied;
  final List<TodoEntity> skipped;  // due to title conflict
}

class CopyTodos {
  Future<CopyResult> call({
    required List<String> todoIds,
    required String targetDate,
  }) async {
    final copied = <TodoEntity>[];
    final skipped = <TodoEntity>[];

    // All in a single transaction
    await db.transaction((txn) async {
      for (final todoId in todoIds) {
        final source = await todoDao.findById(todoId);
        if (source == null) continue;

        final nfcTitle = nfcNormalize(source.title);
        final exists = await todoDao.existsTitleOnDate(nfcTitle, targetDate);

        if (exists) {
          skipped.add(source);
          continue;
        }

        final copy = TodoEntity(
          id: uuid.v4(),
          date: targetDate,
          title: nfcTitle,
          description: source.description != null ? nfcNormalize(source.description!) : null,
          status: TodoStatus.pending,
          portedTo: null,
          sourceDate: source.date,
          recurrenceRuleId: null,  // don't inherit recurrence
          sortOrder: maxSortOrder + 1,
          createdAt: DateTime.now().toUtc().toIso8601String(),
          updatedAt: DateTime.now().toUtc().toIso8601String(),
        );

        await todoDao.insert(copy);
        copied.add(copy);
      }
    });

    return CopyResult(copied: copied, skipped: skipped);
  }
}
```

### 3. `PortTodo` Use-Case (refine from Phase 3)

`lib/domain/usecases/port_todo.dart`:

1. Validate target date > today (port requires future date).
2. Load source todo.
3. NFC-normalise title → check uniqueness on target date → throw `DuplicateTitleException` if conflict.
4. Close any running time segment on the source todo.
5. Create copy on target date:
   - Fresh UUID, `status = pending`, `source_date = source.date`, `sort_order` = append at end.
6. Update source: `status = ported`, `ported_to = targetDate`.
7. All in a single transaction.
8. Return `UndoEntry` with `copiedTodoId` = the new copy's ID.

**Undo:**
- Delete the copy on the target date.
- Revert source status to `oldStatus`.
- All in a transaction.

### 4. Visual Indicators

#### On the daily list (`todo_list_tile.dart`):
- **Copied/ported items** (`sourceDate != null`): show a subtle subtitle "Copied from YYYY-MM-DD" below the title.
- **Ported items** (`status == ported`): show a badge "→ YYYY-MM-DD" (the `portedTo` date) next to the status badge.

#### Style:
- "Copied from" text: small, grey, italic.
- "→ date" badge: amber colour matching the ported status badge.

### 5. Port from Todo Edit Screen

On the create/edit todo screen:
- When the user selects `Ported` status in the status selector:
  - Show a date picker for target date (must be ≥ tomorrow).
  - Show confirmation dialog: "Port [title] to [date]?"
  - On confirm: call `PortTodo` use-case.
  - Navigate back to daily list.

### 6. Port from List Tile Overflow Menu

On the daily list, each todo's overflow menu has a "Port" option:
- Tapping "Port" → date picker for target date.
- Confirmation dialog.
- Calls `PortTodo` use-case.
- Shows undo SnackBar.

### 7. Copy from List Tile Overflow Menu

"Copy" option in overflow menu:
- Opens the copy wizard (`/copy?from=YYYY-MM-DD`) with this single item pre-selected.
- Or shows a simpler inline flow: just pick target date → confirm → copy.

---

## Tests to Write During This Phase

### Unit Tests — `test/domain/usecases/copy_todos_test.dart`
- Copy 3 todos to target date → all 3 created with correct fields.
- Copy with 1 conflicting title → 2 copied, 1 skipped.
- Copied todos have `sourceDate` set to source's date.
- Copied todos have `status = pending` regardless of source status.
- Time segments NOT copied.
- `recurrenceRuleId` NOT inherited.

### Unit Tests — `test/domain/usecases/port_todo_test.dart`
- Port creates copy on target date + marks source as ported.
- Source's `ported_to` is set to target date.
- Copy's `sourceDate` is set to source's date.
- Undo: copy deleted, source reverts to original status.
- Port with running timer: timer closed before porting.
- Port to same day (today) → rejected (target must be > today).
- Port with title conflict on target date → throws `DuplicateTitleException`.

### Widget Tests
- Copy screen: renders item selection, date picker, preview with conflict warnings.
- Port confirmation dialog: shown before porting, cancel prevents action.

---

## Constraints
- NFC-normalise titles before copy/port.
- All writes in transactions.
- Time segments never copied.
- Undo for port deletes the copy atomically.
- All strings in `app_strings.dart`.
- Use `context.pop<T>()` to return results from copy wizard.

## Deliverables
- [ ] Multi-select copy works with conflict detection
- [ ] Port workflow: marks source as ported + creates copy atomically
- [ ] Undo for port: deletes copy + reverts source
- [ ] Visual badges: "Copied from" subtitle, "→ date" ported badge
- [ ] Copy wizard with select → date pick → preview → confirm flow
- [ ] Port accessible from edit screen and list tile overflow menu
- [ ] All tests passing
