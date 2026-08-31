# Change Log: Three Todo UX Enhancements

**Date:** 2026-08-31
**Plan:** plans/20260831_063400_three_ux_enhancements.md

## Changes Made

1. **Editable Time Segments (Feature 1):**
   - Added `updateTimes(String segId, DateTime newStart, DateTime newEnd)` in `lib/data/dao/time_segment_dao.dart` to update start and end times, recompute duration, and reindex search data.
   - Added `updateSegmentTimes` method in `lib/domain/repositories/time_segment_repository.dart` and implemented in `lib/data/repositories/time_segment_repository_impl.dart` with day-lock, terminal status, running segment, start-before-end, and segment overlap validations, plus history event logging.
   - Added `updateSegmentTimes` method to `lib/application/time_tracking_notifier.dart`.
   - Made start/end times in `_SegmentTile` (`lib/presentation/screens/time_segments/time_segments_screen.dart`) tappable for valid segments, opening a time picker to update the segment times.

2. **Tap Todo to View Segments (Feature 2):**
   - Changed normal mode tap behavior on `TodoListTile` (`lib/presentation/screens/daily_list/widgets/todo_list_tile.dart`) from `onEdit` to `onViewSegments` so tapping any todo navigates to its time segments screen. If no segments exist, the empty state ("No time segments recorded") is displayed.

3. **Swipe-Right Actions & Move in Popup Menu (Feature 3):**
   - Implemented `_SwipeRevealWrapper` in `lib/presentation/screens/daily_list/widgets/todo_list_tile.dart` using a slide animation to reveal Edit, Copy, Move, and Delete action buttons when dragging a todo card to the right.
   - Added `onMove` callback to `TodoListTile` and added the **Move** action to the tile's popup menu (⋮).
   - Connected `onMove` in `lib/presentation/screens/daily_list/daily_list_screen.dart` to open a date picker dialog (`_showMoveDatePicker`) and call `moveTodo`, with snackbar confirmation and undo support.

4. **Localization & Tests:**
   - Added l10n strings in `lib/l10n/app_en.arb` and `lib/l10n/app_ml.arb`, and regenerated localization files.
   - Added unit tests for `updateTimes` in `test/data/time_segment_dao_test.dart`.
   - Updated test mocks and widget test assertions in `test/presentation/todo_list_tile_test.dart`.

## Verification
- `flutter analyze` completed with 0 warnings.
- `flutter test` ran all 627 tests successfully with 0 failures.
- `dart format` applied across all code files.
