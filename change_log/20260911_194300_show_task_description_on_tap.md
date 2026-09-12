# Change Log: Show Task Description When Tapping A Todo Card

**Date:** 2026-09-11
**Plan Reference:** [plans/20260911_194100_show_task_description_on_tap.md](plans/20260911_194100_show_task_description_on_tap.md)

## Summary of Changes

1. **Task Description Display in TimeSegmentsScreen (`_buildHeader`)**:
   - When tapping a todo card on the daily list, the app opens `TimeSegmentsScreen`.
   - Updated `_buildHeader` in `lib/presentation/screens/time_segments/time_segments_screen.dart` to check if `todo.description` is non-null and not empty.
   - When present, rendered the description under the task title and date wrapped in `AdaptiveDirectionality` for dynamic bidirectional text direction (English and Malayalam), styled with `colorScheme.onSurfaceVariant`.

2. **Widget Tests**:
   - Added tests in `test/presentation/time_segments_screen_test.dart` to verify:
     - The task description is rendered on screen when present.
     - The description is cleanly omitted without extra spacing or empty widgets when null or empty.

3. **Verification**:
   - Ran `dart format lib/ test/`.
   - Ran `flutter analyze`: 0 issues found.
   - Ran `flutter test test/presentation/time_segments_screen_test.dart`: 4/4 tests passed.
   - Ran `flutter test`: 669/669 tests passed.

---

## Files Changed

### Presentation Layer
- `lib/presentation/screens/time_segments/time_segments_screen.dart`: Added task description display to the screen header.

### Tests
- `test/presentation/time_segments_screen_test.dart`: Added widget tests for task description rendering.

---

## Verification

- `flutter analyze`: Completed with 0 issues found.
- `flutter test`: 669/669 tests passed.
