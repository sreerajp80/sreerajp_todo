# Security

Use this document when the repository handles secrets, protected personal data, health data, financial data, private files, or any local encrypted store.

If the app is not security-sensitive, keep this file short and document that decision explicitly.

## 1. Security Scope

- App: `<app name>`
- Data sensitivity level: `low`, `moderate`, or `high`
- Engineering standard profiles in force:
  - `Core Baseline`
  - `Sensitive Data Extension` if applicable
- Platforms in scope:
  - `Android`
  - `iOS`
  - `<other>`

## 2. Security Objectives

- `<objective 1>`
- `<objective 2>`
- `<objective 3>`

Example objectives:

- Protect locally stored secrets from casual extraction.
- Prevent accidental disclosure through logs, backups, screenshots, or exports.
- Preserve recoverability and migration without weakening encryption.

## 3. Threat Model Summary

Document the threats the product is designed to address and the ones it explicitly does not address.

### In Scope Threats

- `<lost or stolen device>`
- `<casual local access>`
- `<accidental plaintext export>`
- `<log leakage>`

### Out Of Scope Threats

- `<fully compromised/rooted device>`
- `<physical hardware attacks>`
- `<attacks requiring OS compromise>`

## 4. Sensitive Data Inventory

| Data Type | Example | Where It Exists | Protection Required |
|-----------|---------|-----------------|---------------------|
| `<secret>` | `<example>` | `<memory/db/export>` | `<control>` |
| `<token>` | `<example>` | `<memory/storage>` | `<control>` |
| `<user data>` | `<example>` | `<storage/logs?>` | `<control>` |

## 5. Storage Model

### At Rest

- Primary local storage: `<sqflite/files/etc.>`
- Secure key storage: `<flutter_secure_storage/keychain/keystore/etc.>`
- Backup behavior: `<disabled/restricted/encrypted/plaintext not allowed>`

### In Memory

- Sensitive values are kept in memory: `<briefly / cached / long-lived>`
- Memory clearing strategy: `<lock/background/manual clear>`

### In Transit

- Network use: `<none / https api / internal network>`
- Transport protections: `<tls/pinning/none>`

## 6. Cryptography Design

Document only the design, not the secrets.

- Encryption algorithm: `<AES-256-GCM/etc.>`
- Key derivation: `<PBKDF2/Argon2/etc.>`
- Nonce or IV strategy: `<random per record>`
- Format versioning: `<how versioning works>`
- Legacy format support: `<yes/no and why>`

### Rules

- Keys, IVs, salts, and passwords must never be hardcoded.
- Randomness must use cryptographically secure generation.
- Encrypted formats should be versioned.

## 7. Authentication And Access Control

- App-lock strategy: `<none / biometric / pin / password / device credential>`
- Fallback behavior: `<behavior>`
- Session-expiry rule: `<rule>`
- Background lock rule: `<rule>`
- Protected-route strategy: `<where enforced>`

## 8. Logging And Telemetry Policy

### Never Log

- Secrets
- Tokens
- Recovery codes
- Decrypted payloads
- Sensitive personal data unless explicitly approved

### Allowed Diagnostic Context

- Operation name
- Screen or flow name
- Error category
- Non-sensitive identifiers where justified

### Logging Controls

- Logger implementation: `<logger>`
- Verbose logging gate: `<flavor/config flag>`
- Redaction strategy: `<strategy>`

## 9. Platform Security Controls

### Android

- `android:allowBackup`: `<true/false and why>`
- `android:fullBackupContent`: `<value>`
- Screenshot protection: `<enabled/disabled and why>`
- Root or tamper detection: `<if any>`

### iOS

- Sensitive-screen capture policy: `<policy>`
- Keychain usage: `<usage>`
- Required privacy descriptions: `<permissions used>`

## 10. Permissions

| Permission | Why It Is Needed | Requested When | Denial Handling |
|------------|------------------|----------------|-----------------|
| `<permission>` | `<reason>` | `<point of use>` | `<behavior>` |
| `<permission>` | `<reason>` | `<point of use>` | `<behavior>` |

## 11. Backup, Import, Export, And Recovery

- Backup supported: `<yes/no>`
- Backup format: `<encrypted/plaintext/both>`
- Import supported: `<yes/no>`
- Recovery flow: `<description>`
- Plaintext export policy: `<disallowed / allowed with confirmation>`

### Validation Requirements

- Import parsing must reject malformed data safely.
- Recovery flows must be tested like authentication flows.
- Export UX must clearly communicate sensitivity.

## 12. Security Testing Strategy

| Area | Test Type | Notes |
|------|-----------|-------|
| Crypto format | Unit | `<notes>` |
| Secret storage | Unit or integration | `<notes>` |
| Lock or auth flow | Widget or integration | `<notes>` |
| Backup and recovery | Integration or focused unit tests | `<notes>` |

### Required Test Vectors Or Regression Areas

- `<deterministic vector set>`
- `<migration path>`
- `<failure mode>`

## 13. Incident Response Notes

Document how the team should respond if a security issue is found.

- Triage owner: `<owner>`
- Severity model: `<brief model>`
- Immediate containment actions:
  - `<action 1>`
  - `<action 2>`
- User communication trigger: `<when users must be notified>`
- Patch release process reference: `docs/release_process.md`

## 14. Open Risks And Future Hardening

- Risk: `<risk>`
  Hardening option: `<option>`
- Risk: `<risk>`
  Hardening option: `<option>`

## 15. Security Review Checklist

- [ ] Threat model reviewed.
- [ ] Sensitive data inventory updated.
- [ ] Logging policy reviewed.
- [ ] Storage and backup behavior reviewed.
- [ ] Permission usage reviewed.
- [ ] Recovery, import, export, and migration paths reviewed.
- [ ] Tests cover the highest-risk failure modes.
