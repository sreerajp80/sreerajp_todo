# Plan: Add Comprehensive Backup, Restore, Export, Import, QR Sync, and Serverless P2P Sync Specifications

**Status:** Awaiting Approval

## Target File
- `docs/unique_features_and_improvements.md`

## Issue / User Query
The user asked: *"Some of the apps implement backup/restore/export/import/QR sync/ SYnc using server etc.. Why you completely skipped this?"*
The user wants these critical capabilities (Backup/Restore, Export/Import, QR Sync, Serverless P2P Sync, and Local Server Sync) fully detailed as main feature specifications in `docs/unique_features_and_improvements.md`, explaining how `SreerajP ToDo` adapts and leverages the production-tested engines from `sms-sentry`, `SreerajP_Authenticator`, `SreerajPContactSphere`, `SreerajP_TextApp`, `sreeraj_qr_reader`, and `vault-files`.

## Proposed Changes

Update `docs/unique_features_and_improvements.md` to add dedicated, detailed feature specifications for:

1. **Passphrase-Encrypted Backup & Automated Health Restore System:**
   - AES-256-GCM / Argon2 key derivation, schema migration verification, and automated backup health logging (adapted from `SreerajP_Journal_Vault`, `SreerajP_Authenticator`, `vault-files`).

2. **Multi-Format Ingestion & Export Engine (Markdown, CSV, JSON, PDF):**
   - Multi-format ingestion and export of tasks, time segments, subtask checklists, and recurrence rules with SAF scoped storage (adapted from `SreerajP_TextApp`, `SreerajPContactSphere`, `SreerajP_PDFApp`).

3. **AirQR Optical Air-Gapped Animated QR Code Sync:**
   - Transferring task lists and timecard payloads via animated QR code streams (Fountain codes) between devices without Wi-Fi or Bluetooth (adapted from `sreeraj_qr_reader`, `SreerajP_Authenticator`, `SreerajPContactSphere`, `SreerajP_TextApp`).

4. **Serverless Encrypted Local P2P Wi-Fi Sync Engine:**
   - Direct TCP socket synchronization between devices on local Wi-Fi with AES-256-GCM encryption, PBKDF2 pairing keys, and add-only/selective merge policies (adapted from `sms-sentry`, `SreerajP_Authenticator`, `SreerajPContactSphere`, `SreerajP_TextApp`).

5. **Local Self-Hosted Server / Desktop Sync Adapter:**
   - 100% offline, local-network serverless sync endpoint enabling Windows desktop and Android instances of `SreerajP ToDo` to pair and sync across local subnets without third-party cloud infrastructure (adapted from `SreerajPContactSphere` and `SreerajP_TextApp`).

Also preserve the user's manual addition of **Spaced Repetition Task Mastery Deck ✅ [Implemented]** (Migration V6, `spaced_repetition_items` table, SM-2 algorithm, `/mastery-deck` screen).

## Verification Plan
1. Check `docs/unique_features_and_improvements.md` to ensure all 18 apps, all 10 unique productivity features, and all 5 detailed sync/backup/export/import specifications are present and formatted cleanly.
