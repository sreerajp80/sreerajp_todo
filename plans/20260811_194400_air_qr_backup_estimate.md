# Implementation Plan - AirQR Backup Payload Size & Transfer Time Indicator

**Status:** Proposed

## Overview
Add payload size calculation, estimated transfer time indicator, and a practical recommendation banner to `AirQrShareDialog` when sharing Full App Backups or Tasks via AirQR optical streams.

## Issue
When users initiate a Full App Backup or task stream via AirQR, there is currently no visual indication of the total payload size, estimated scan duration, or whether an Encrypted File Backup (.zip) would be more practical for large databases.

## Proposed Changes

### Presentation Layer

#### [MODIFY] [air_qr_share_dialog.dart](file:///l:/Android/sreerajp_todo/lib/presentation/widgets/air_qr_share_dialog.dart)
- Calculate total payload size in KB and minimum required scan duration based on total block count and target FPS.
- For Full App Backups (`widget.backupMap != null`):
  - Display an **Info Banner** for small/medium backups (< 300 KB) showing estimated transfer time (e.g., `~45 seconds`).
  - Display a **Warning Banner** for large backups (≥ 300 KB) informing the user of the estimated scan duration (e.g., `~3.5 minutes`) and recommending Encrypted File Backup (.zip) for faster transfer if preferred.
- Dynamically update estimated time when the user changes target FPS chip selection (5, 10, 15, 20, 25 FPS).

## Verification Plan

### Automated Tests
- Run `flutter analyze` to ensure 0 static analysis errors.
- Run `flutter test` to ensure existing tests pass cleanly.

### Manual Verification
- Launch `AirQrShareDialog` with a small payload (tasks) and verify info banner displays estimated duration.
- Launch `AirQrShareDialog` with a full backup map and verify dynamic time calculation updates when changing target FPS.
