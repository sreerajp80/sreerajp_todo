# Show Task Description on Tap Plan

**Status:** Completed

## Overview
When tapping on a todo card in the daily list, the app navigates to the task details and time segments screen (`TimeSegmentsScreen`). Currently, this screen displays the task title, date, total tracked duration, and time segment history, but does not display the task description. This plan adds the task description to the header of the screen when available, ensuring the user can read the task details upon tapping the card.

## Target Layer
- Presentation Layer (`lib/presentation/screens/time_segments/`)
- Test Suite (`test/presentation/`)

## Files to Change
- `lib/presentation/screens/time_segments/time_segments_screen.dart`
- `test/presentation/time_segments_screen_test.dart`

## Issue
When a user adds a description to a todo task and later taps on the task card from the daily list, the opened screen (`TimeSegmentsScreen`) omits the description. As a result, the user cannot read the details or notes of their task without opening the edit screen.

## Proposed Fix
1. In `lib/presentation/screens/time_segments/time_segments_screen.dart`:
   - In `_buildHeader`, check if `todo.description` is non-null and not empty (`todo.description != null && todo.description!.trim().isNotEmpty`).
   - If present, render the description with proper spacing, wrapped in `AdaptiveDirectionality` for dynamic bidirectional text support (English, Malayalam, RTL/LTR), styled with secondary text color (`colorScheme.onSurfaceVariant`).
2. In `test/presentation/time_segments_screen_test.dart`:
   - Add a widget test verifying that when a task has a description, it is rendered on `TimeSegmentsScreen`.
   - Verify that when description is null or empty, no extra empty widget or error occurs.

## Verification
- Run `flutter analyze` to ensure zero analysis warnings.
- Run `flutter test test/presentation/time_segments_screen_test.dart` to verify unit and widget tests pass.
