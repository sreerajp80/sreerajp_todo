# Dependencies — SreerajP ToDo

This document provides the complete audited inventory of approved direct local-only dependencies and prohibited package categories for SreerajP ToDo.

Read [AGENTS.md](../AGENTS.md) and [CLAUDE.md](../CLAUDE.md) first before adding or modifying any project dependencies.

---

## 1. Dependency Constraints & Policy

SreerajP ToDo is a **100% offline-first application**. Zero internet connectivity is permitted.
Before adding any package:
1. Confirm the package operates completely offline without network permissions.
2. Audit transitive dependencies for networking, cloud, or telemetry libraries.
3. Obtain explicit confirmation and run the dependency audit command.

---

## 2. Direct Runtime Dependencies

| Package | Purpose | Category |
|---|---|---|
| `flutter_localizations` | Bilingual localization (English & Malayalam) | Internationalization |
| `cupertino_icons` | iOS-style iconography support | UI |
| `sqflite_sqlcipher` | AES-256 encrypted SQLite engine (Mobile) | Database |
| `sqflite_common_ffi` | SQLCipher-enabled SQLite engine (Desktop) | Database |
| `path` | Cross-platform filesystem path manipulation | Utilities |
| `path_provider` | Local app document and sandbox storage directory lookup | Utilities |
| `flutter_riverpod` | Reactive state management and dependency injection | State Management |
| `go_router` | Declarative route navigation and deep linking | Navigation |
| `intl` | Date formatting and string pluralization | Utilities |
| `fl_chart` | Interactive bar and line charts for statistics | Visualization |
| `table_calendar` | Multi-day calendar view for date selection | UI |
| `uuid` | Unique identifier generation for entities and segments | Data |
| `freezed_annotation` | Annotations for immutable domain models | Data Models |
| `json_annotation` | Annotations for JSON serialization | Data Models |
| `unorm_dart` | Unicode NFC string normalization | Core Utilities |
| `file_picker` | Local device backup export and import file picker | Storage / File System |
| `rrule` | RFC 5545 iCalendar recurrence rule processing | Recurrence Engine |
| `shared_preferences` | Persistent key-value storage for app settings & language preferences | Storage / Preferences |
| `qr_flutter` | Animated QR code stream rendering for AirQR optical sync | AirQR Sync / UI |
| `mobile_scanner` | Local camera barcode scanner for AirQR stream reception | AirQR Sync / Camera |

---

## 3. Development & Testing Dependencies

| Package | Purpose |
|---|---|
| `flutter_test` | Unit and widget testing framework |
| `integration_test` | End-to-end integration testing framework |
| `flutter_lints` | Official Flutter static analysis linter rules |
| `build_runner` | Code generation task runner for freezed & json_serializable |
| `freezed` | Code generator for immutable data models |
| `json_serializable` | Code generator for JSON serialization |
| `mocktail` | Null-safe mocking framework for unit testing |
| `flutter_native_splash` | Native splash screen generator |

---

## 4. Prohibited Dependency Categories

The following package types are strictly prohibited in `pubspec.yaml` and transitive dependencies:
- **HTTP / REST Clients:** `http`, `dio`, `retrofit`, `chopper`
- **WebSockets / Network Sockets:** `web_socket_channel`, `socket_io_client`
- **Cloud / BaaS SDKs:** `firebase_core`, `supabase_flutter`, `aws_signature_v4`, `amplify_flutter`
- **Analytics & Telemetry:** `amplitude_flutter`, `mixpanel_flutter`, `segment`
- **Crash Reporting:** `sentry`, `firebase_crashlytics`, `datadog_flutter_plugin`
- **Network Status Checks:** `connectivity_plus`, `internet_connection_checker`
- **Ad Frameworks:** `google_mobile_ads`

---

## 5. Dependency Audit Command

After editing `pubspec.yaml`, execute the following audit command in PowerShell:

```powershell
flutter pub deps --json | Select-String -Pattern "http|socket|firebase|supabase|sentry|crashlytics|analytics"
```

Zero matches from direct project dependencies are required.
