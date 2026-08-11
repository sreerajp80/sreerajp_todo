# Change Log: Added Backup, Restore, Export, Import, AirQR Sync, and Serverless P2P Sync Specifications

**Date:** 2026-08-10  
**Plan Reference:** [plans/20260810_203139_add_backup_restore_sync_specs.md](file:///l:/Android/sreerajp_todo/plans/20260810_203139_add_backup_restore_sync_specs.md)

## Summary of Changes
Updated `docs/unique_features_and_improvements.md` to add detailed, comprehensive feature specifications for **Backup, Restore, Multi-Format Ingestion/Export, AirQR Optical Sync, Serverless P2P Wi-Fi Sync, and Local Server/Desktop Sync**, detailing how `SreerajP ToDo` adapts these capabilities from `sms-sentry`, `SreerajP_Authenticator`, `SreerajPContactSphere`, `SreerajP_TextApp`, `sreeraj_qr_reader`, and `vault-files`.

### Detailed New Feature Specifications Added to Section 3:
1. **3.11 Passphrase-Encrypted Backup & Automated Health Restore System:**
   - AES-256-GCM / Argon2 key derivation, schema V6 validation, atomic database replacements, and automated backup health logging (adapted from `SreerajP_Journal_Vault`, `SreerajP_Authenticator`, `vault-files`).
2. **3.12 Multi-Format Data Ingestion & Export Engine (Markdown, CSV, JSON, PDF):**
   - Multi-format ingestion (`- [ ]` checklist parsing) and structured export of tasks, time segments, subtasks, and RRULE schedules via SAF scoped storage (adapted from `SreerajP_TextApp`, `SreerajPContactSphere`, `SreerajP_PDFApp`).
3. **3.13 AirQR Optical Air-Gapped Animated QR Code Sync:**
   - Camera-based animated QR code stream data transfer (LT Fountain codes) for transferring task lists and timecard payloads between air-gapped devices without Wi-Fi or Bluetooth (adapted from `sreeraj_qr_reader`, `SreerajP_Authenticator`, `SreerajPContactSphere`, `SreerajP_TextApp`).
4. **3.14 Serverless Encrypted Local P2P Wi-Fi Sync Engine:**
   - Direct TCP socket synchronization between devices on local Wi-Fi with AES-256-GCM authenticated encryption, PBKDF2 pairing keys, and add-only/selective merge policies (adapted from `sms-sentry`, `SreerajP_Authenticator`, `SreerajPContactSphere`, `SreerajP_TextApp`).
5. **3.15 Local Self-Hosted Desktop & Local Server Sync Adapter:**
   - 100% offline, local-network sync adapter enabling Windows desktop and Android instances of `SreerajP ToDo` to pair and sync across local subnets with vector clock conflict resolution (adapted from `SreerajPContactSphere` and `SreerajP_TextApp`).

### Preserved User Additions:
- Retained the user's manual addition of **Spaced Repetition Task Mastery Deck ✅ [Implemented]** in Sections 3.5 and 6.

## Verification
- Verified [docs/unique_features_and_improvements.md](file:///l:/Android/sreerajp_todo/docs/unique_features_and_improvements.md) contents and links. All 18 apps and all 15 detailed feature specifications are present.
