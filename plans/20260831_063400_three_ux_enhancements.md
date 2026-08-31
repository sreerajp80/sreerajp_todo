# Plan: Three Todo UX Enhancements

**Status:** Approved

## Issue
Three UX improvements requested:
1. Users cannot edit the start/end time of existing time segments
2. Tapping a todo opens the edit screen instead of showing time segments
3. No swipe-to-reveal actions on todo tiles; no Move option in the popup menu

## Fix

### Feature 1 — Edit segment times
- Add `updateTimes()` to `TimeSegmentDao`
- Add `updateSegmentTimes()` to `TimeSegmentRepository` interface and implementation
- Add `updateSegmentTimes()` to `TimeTrackingNotifier`
- Make start/end time labels tappable in `_SegmentTile` (time_segments_screen.dart)
- Add l10n strings

### Feature 2 — Tap todo to show segments
- Change `tileTap` from `onEdit` to `onViewSegments` in `TodoListTile`

### Feature 3 — Swipe-right action buttons + Move in popup
- Add `onMove` callback to `TodoListTile`
- Add Move to popup menu
- Build custom swipe-right animation with Edit/Delete/Copy/Move buttons
- Wire `onMove` in `DailyListScreen` with date picker
- Add l10n strings

## Files to change
- `lib/data/dao/time_segment_dao.dart`
- `lib/domain/repositories/time_segment_repository.dart`
- `lib/data/repositories/time_segment_repository_impl.dart`
- `lib/application/time_tracking_notifier.dart`
- `lib/presentation/screens/time_segments/time_segments_screen.dart`
- `lib/presentation/screens/daily_list/widgets/todo_list_tile.dart`
- `lib/presentation/screens/daily_list/daily_list_screen.dart`
- `lib/l10n/app_en.arb`
- `lib/l10n/app_ml.arb`
