# Change Log - AirQR Backup Size & Duration Estimation

**Plan:** [plans/20260811_194400_air_qr_backup_estimate.md](file:///l:/Android/sreerajp_todo/plans/20260811_194400_air_qr_backup_estimate.md)

## Summary of Changes

### Presentation Layer
- **[air_qr_share_dialog.dart](file:///l:/Android/sreerajp_todo/lib/presentation/widgets/air_qr_share_dialog.dart):**
  - Added payload byte/KB size calculation (`_payloadSizeBytes`, `_payloadSizeKb`).
  - Added dynamic transfer time estimation (`_estimatedTimeLabel`) based on total blocks and target FPS (5, 10, 15, 20, 25 FPS).
  - Added `_buildPayloadEstimateBanner` widget rendering:
    - **Info Banner (< 300 KB):** Displays estimated scan time and payload size for small/medium sync payloads (e.g. `Est. scan time: ~25s (45.2 KB)`).
    - **Warning Banner (≥ 300 KB):** Displays expected scan time for large backups and informs the user that Encrypted File Backup (.zip) is recommended for faster transfer.

## Verification
- Executed `flutter analyze`: **0 issues found**.
- Executed `flutter test`: **262 tests passed successfully**.
