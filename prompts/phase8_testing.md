# Phase 8 — Testing (Gaps & Integration)

## Objective
Fill unit/widget test coverage gaps, write integration tests, and perform performance profiling. Unit tests for DAOs, repositories, and use-cases should already exist from Phases 2–5B. This phase focuses on integration tests, coverage audits, widget test gaps, and performance benchmarks.

## Pre-Requisites
- Phases 1–7 complete (all features implemented, UI polished).
- Read `CLAUDE.md` — testing rules, 80% coverage target.
- Read `docs/architecture.md` — test layout (§13), critical test areas.
- Read `docs/security.md` — security testing strategy (§12 — encryption, backup round-trip, wrong passphrase, schema validation, offline operation).
- Read `docs/flutter_project_engineering_standard.md` — testing standard (§9 — test levels, test rules, test quality), Definition of Done (§14 — all three profiles: Core Baseline, Production App Extension, Sensitive Data Extension).

## Key Rules
- Minimum unit test coverage: **80%** on `lib/data/` and `lib/domain/`.
- DAO tests use **in-memory SQLite** (`inMemoryDatabasePath`).
- Widget tests mock the repository layer via `mocktail` — never mock DAOs directly in widget tests.
- Integration tests run on Android emulator.
- No `print()` in tests — use `debugPrint()`.

---

## Tasks

### 1. Coverage Audit

Run coverage report:
```powershell
flutter test --coverage
# View report (if lcov available)
# genhtml coverage/lcov.info -o coverage/html
```

Review gaps in existing test suites. The following should already exist:

| Test Suite | What is tested | Written in |
|-----------|---------------|------------|
| `TodoDao` tests | All CRUD, uniqueness, autocomplete, search | Phase 2 |
| `TimeSegmentDao` tests | Start, stop, orphan detection, cascade, manual entry | Phase 2, 4 |
| `RecurrenceRuleDao` tests | CRUD, findActive | Phase 2, 3B |
| `StatisticsQueryService` tests | Aggregates, pagination | Phase 2, 6 |
| `TodoRepository` tests | Day lock, status transitions, port/copy | Phase 3 |
| Use-case tests | MarkCompleted, PortTodo, CopyTodos, StartTimeSegment, RepairOrphanedSegments, GenerateRecurringTasks | Phases 3, 3B, 4 |
| `BackupService` tests | Export, import, schema validation, corruption | Phase 5B |
| Unicode tests | NFC normalisation, direction detection | Phase 2, 7 |

**Fill any gaps** to reach 80% coverage on `lib/data/` and `lib/domain/`.

### 2. Widget Test Gaps

Write widget tests that weren't completed in earlier phases:

#### `test/presentation/statistics_screen_test.dart`
- Screen renders without exceptions with mock data.
- Tab switching between Daily and Per-Item works.
- Date range filter changes displayed data.
- Pagination buttons work.
- Charts render (bar chart, line chart) without exceptions.

#### `test/presentation/backup_screen_test.dart`
- Export and Import buttons render.
- Passphrase dialog appears on Export tap.
- Confirmation dialog appears on Import tap.
- Backup list renders with mock data.
- Delete confirmation dialog appears.

#### `test/presentation/search_results_screen_test.dart`
- Search results grouped by date.
- Tapping a result navigates to `/day/:date`.
- Empty state shown for no results.
- Unicode search query works.

#### `test/presentation/undo_snackbar_test.dart`
- SnackBar appears after status change.
- Tapping Undo reverts the status.
- SnackBar auto-dismisses after 5 seconds.
- Persistent undo button visible when stack non-empty.

### 3. Integration Tests (`integration_test/app_test.dart`)

All integration tests run on Android emulator with `flutter test integration_test/app_test.dart`.

#### Test scenarios:

**Happy Path:**
1. Launch app → lands on today's daily list.
2. Create a new todo with title "Integration Test Task".
3. Start timer → wait 2 seconds → stop timer.
4. Verify time displayed is ~00:00:02.
5. Mark todo as completed.
6. Verify status badge is green/completed.
7. Navigate to statistics → verify the task appears.

**Copy Flow:**
1. Create 3 todos on today's date.
2. Open copy screen → select 2 → pick tomorrow → confirm.
3. Navigate to tomorrow → verify 2 todos exist.
4. Verify `sourceDate` is set correctly.

**Day Lock:**
1. Navigate to yesterday's date.
2. Verify FAB is hidden.
3. Verify all list tile controls are disabled.
4. Verify padlock icon shown.
5. Attempt to create a todo for yesterday (programmatically) → verify `DayLockedException`.

**Unicode Round-Trip:**
1. Create todo with Arabic title "المهمة العربية".
2. Navigate away and back.
3. Verify title displayed correctly.
4. Verify RTL text direction.
5. Create another todo with title "日本語タスク".
6. Verify CJK renders correctly.
7. Search for "المهمة" → verify result found.

**Offline Enforcement:**
1. Disable all network interfaces on the test device.
2. Launch the app.
3. Create, edit, view todos.
4. View statistics.
5. Verify zero errors or network-related warnings.
6. Verify app functions normally with no network.

**Undo Status Change:**
1. Create a todo → mark as completed.
2. Tap Undo within 5 seconds.
3. Verify status reverted to pending.
4. Mark as ported to tomorrow.
5. Tap Undo → verify copy deleted and source reverted.

**Backup Round-Trip:**
1. Create 3 todos with different statuses.
2. Export backup with passphrase "testpass123".
3. Delete all todos (or import a blank DB).
4. Import the backup with passphrase "testpass123".
5. Verify all 3 todos restored with correct statuses.

**Manual Time Entry:**
1. Create a todo.
2. Navigate to segments screen.
3. Add a manual segment (09:00 – 10:30).
4. Verify duration = 01:30:00.
5. Verify "M" badge displayed.
6. Add overlapping segment (09:30 – 11:00) → verify rejected.

**Bulk Status Change:**
1. Create 3 todos.
2. Long-press → enter multi-select → select all 3.
3. Tap "Complete All".
4. Verify all 3 are completed.
5. Tap Undo → verify all 3 reverted to pending.

**Recurring Tasks:**
1. Create a daily recurrence rule with title "Daily Standup".
2. Restart the app (or trigger generation).
3. Verify todo "Daily Standup" exists on today + next 7 days.
4. Edit the generated todo's title on today → verify future days unaffected.
5. Delete the generated todo on tomorrow → restart → verify it's regenerated.

### 4. Performance Profiling

Use Flutter DevTools to profile:

#### Daily list with 100+ todos:
```powershell
# Seed the database with 100+ todos for a single day, then profile
flutter run --profile -d <device>
```
- Open Flutter DevTools → Performance tab.
- Scroll the list rapidly.
- **Target**: no frame jank > 16 ms.

#### Statistics screen with 1,000+ rows:
- Seed database with 1,000+ todos across many days.
- Navigate to statistics screen.
- **Target**: initial load < 500 ms, pagination < 100 ms.

#### Autocomplete with 5,000+ distinct titles:
- Seed database with 5,000+ distinct titles.
- Type in the title field rapidly.
- **Target**: < 100 ms response per keystroke.

#### Document results:
Record profiling results in a table:
| Scenario | Metric | Target | Actual | Pass? |
|----------|--------|--------|--------|-------|
| 100 todos scroll | Max frame time | < 16 ms | — | — |
| 1000 rows stats load | Initial load | < 500 ms | — | — |
| 1000 rows pagination | Page load | < 100 ms | — | — |
| 5000 titles autocomplete | Response time | < 100 ms | — | — |

---

## Test Commands

```powershell
# Run all unit + widget tests
flutter test

# Run with coverage
flutter test --coverage

# Run a single test file
flutter test test/data/todo_dao_test.dart

# Run integration tests (emulator must be running)
flutter test integration_test/app_test.dart

# Profile mode
flutter run --profile -d <device-id>
```

---

## Constraints
- 80% coverage on `lib/data/` and `lib/domain/`.
- No `print()` in tests.
- Widget tests mock repositories via `mocktail`, not DAOs.
- DAO tests use in-memory SQLite.
- No compute/isolate for DB queries.

## Deliverables
- [ ] `flutter test` passes all unit and widget tests
- [ ] Integration test suite passes on Android emulator
- [ ] Coverage ≥ 80% on `lib/data/` and `lib/domain/`
- [ ] All integration test scenarios pass
- [ ] Performance benchmarks documented and within thresholds
- [ ] No frame jank > 16 ms on daily list with 100+ items
- [ ] Autocomplete < 100 ms with 5,000+ titles
