# AGENTS.md — SreerajP ToDo

This file is read by AI agents and LLM coding assistants (Gemini, Antigravity, Cursor, Windsurf, Codex, etc.) at the start of every session in this repository.
Read it before making any change. See the docs table below for full detail.

---

## Project identity

| Field | Value |
|-------|-------|
| App name | SreerajP ToDo |
| Type | Personal offline-first daily ToDo and time-tracker |
| Platform(s) | Android (minSdk 21, targetSdk 34) + Windows desktop (v1.0 active); iOS, Linux, macOS (future) |
| Package / org id | `in.sreerajp` |
| Flutter SDK | 3.44.8 stable |
| Dart SDK | 3.12.2 |
| State management | Riverpod (`flutter_riverpod`) |
| Navigation | `go_router` |
| Database | SQLite via `sqflite_sqlcipher` (mobile, AES-256 encrypted) + `sqflite_common_ffi` with SQLCipher (desktop) |
| Orientation | Both portrait and landscape supported |
| Connectivity | **Fully offline — zero internet access required or permitted** |

---

## Read these docs before working

| Document | Read when |
|----------|-----------|
| [docs/architecture.md](docs/architecture.md) | Changing structure, screens, state, services, models, repositories |
| [docs/security.md](docs/security.md) | Touching permissions, logging, storage, crypto, manifest, backup encryption |
| [docs/release_process.md](docs/release_process.md) | Building a release, versioning, release checklist, signing |
| [docs/flutter_build_flavors_guide.md](docs/flutter_build_flavors_guide.md) | Build config, signing, flavors, Gradle, ProGuard |
| [docs/flutter_project_engineering_standard.md](docs/flutter_project_engineering_standard.md) | Any code change — layers, naming, testing, DoD |
| [docs/workflow_rules.md](docs/workflow_rules.md) | Planning changes, approval gates, logging changes |
| [docs/dependencies.md](docs/dependencies.md) | Audited dependency inventory, prohibited package categories |
| [docs/project_structure.md](docs/project_structure.md) | Directory tree layout and layer responsibilities |
| [docs/features.md](docs/features.md) | Complete feature specification and UX requirements |
| [docs/GUIDELINES_MANIFEST.md](docs/GUIDELINES_MANIFEST.md) | The shared Flutter guidelines index |

---

## Hard rules (must follow — these override convenience)

1. **Fully Offline:** Zero network packages, zero cloud SDKs, zero analytics/crash reporting. `AndroidManifest.xml` must not contain `INTERNET` or network permissions. Runtime assets must be bundled (`AssetImage`, `Image.asset()`, `Image.file()`). Never use `NetworkImage`.
2. **Unicode First:** NFC-normalize every string written to the database with `unicodeUtils.nfcNormalize(value)`. Use `unicodeUtils.detectTextDirection(value)` for dynamic text direction. Title uniqueness is enforced after NFC normalization.
3. **Day Lock:** Any `TodoEntity` dated before today is read-only. Repository methods must enforce this and throw `DayLockedException`.
4. **Terminal Status Lock:** `completed` and `dropped` todos cannot accept new time segments. Any open segment must be stopped when a todo becomes terminal. Repository throws `CompletedLockException`. UI hides start/stop controls for terminal todos.
5. **One Open Segment Per Todo:** At most one open `TimeSegmentEntity` (`end_time IS NULL`) per `todo_id`. Repository throws `SegmentAlreadyRunningException` if violated.
6. **Title Uniqueness Per Day:** No two todos on the same date may share an NFC-normalized title. Enforced in SQLite, repository checks, and UI validation. Repository throws `DuplicateTitleException`.
7. **No Direct DB Access From Widgets:** Widgets consume Riverpod providers from `lib/application/providers.dart` only. Never call DAOs directly.
8. **Immutable Models:** All domain entities and data models use `@freezed`. Never mutate in place; use `copyWith()`. Never edit generated `*.freezed.dart` or `*.g.dart` files manually.
9. **Measurements & Metric Formatting:** Display durations as `HH:MM:SS` via `lib/core/utils/duration_utils.dart`. Use logical pixels (dp) only. Use metric terminology in comments and documentation.
10. **Centralized User Strings:** All user-visible strings and error messages live in `lib/core/constants/app_strings.dart`. SQL strings belong in DAO classes only.

---

## Architecture rules

- **Layer layout:** 5-layer architecture under `lib/`: Presentation (`lib/presentation/`), Application (`lib/application/`), Domain (`lib/domain/`), Data (`lib/data/`), Core (`lib/core/`).
- **Layer boundaries:**
  - `core/` is pure Dart with zero Flutter framework imports.
  - `domain/` depends on `core/` only and never imports `sqflite` or data classes.
  - `data/` implements domain repository interfaces and encapsulates DAOs, migrations, and storage.
  - `presentation/` never imports `data/` directly.
- **Dependency direction:** `presentation → application → domain/usecases → domain/repositories ← data`.
- **State Management:** Use `StateNotifierProvider` for mutable screen state, `FutureProvider` for async reads, `FutureProvider.family` for parameterized queries, and `StreamProvider` only for the live timer. Declare providers in `lib/application/providers.dart`. Root `ProviderScope` lives in `main.dart`.
- **Navigation:** Define routes in `lib/app.dart`, route paths in `lib/core/constants/app_routes.dart`. Use `go_router` exclusively (`context.go()`, `context.push()`, `context.pop()`). `/` resolves to today's daily list.
- **Database:** `DatabaseService` singleton exposed via Riverpod. Storage path resolved via `path_provider`. AES-256 encrypted SQLite (`sqflite_sqlcipher` on mobile, SQLCipher FFI on desktop). Enable `PRAGMA journal_mode=WAL; PRAGMA foreign_keys=ON;`.

---

## Build & run commands

```powershell
# Install dependencies
flutter pub get

# Daily development (dev flavor)
flutter run --flavor dev

# Desktop development (Windows)
flutter run -d windows

# Static code analysis (must be 0 issues)
flutter analyze

# Run unit and widget tests
flutter test

# Format all Dart code
dart format lib/ test/ integration_test/

# Code generation for freezed and json_serializable
dart run build_runner build --delete-conflicting-outputs

# Production release APK (prod flavor, split per ABI)
flutter build apk --flavor prod --release --split-per-abi

# Production Play Store app bundle
flutter build appbundle --flavor prod --release

# Windows desktop release build
flutter build windows --release

# Dependency offline compliance audit
flutter pub deps --json | Select-String -Pattern "http|socket|firebase|supabase|sentry|crashlytics|analytics"
```

---

## Build flavors

| Flavor | App ID | Display name | Signing |
|--------|--------|--------------|---------|
| dev | `in.sreerajp.dev` | SreerajP ToDo Dev | Debug keystore (automatic) |
| prod | `in.sreerajp` | SreerajP ToDo | Release keystore (`L:\Android\key.properties`) |

---

## Signing / keystore

- Keystore configuration file: `L:\Android\key.properties` (stored outside project root, never committed).
- `.gitignore` MUST include: `key.properties`, `*.jks`, `*.keystore`, `build/symbols/`.

---

## Security rules

- Never log secrets, keys, passwords, or decrypted user data.
- 100% offline operational guarantee — zero network permissions in `AndroidManifest.xml`.
- `android:allowBackup="false"` must remain set in `AndroidManifest.xml`.
- Dual-key encryption design: live SQLite database encrypted with device-derived key; backup export files encrypted with user passphrase (AES-256 ZIP encryption).

---

## Code style / naming

- Files `snake_case.dart`; classes `PascalCase`; variables/methods `camelCase`; providers `camelCase` + `Provider` suffix.
- Routes: `kebab-case` with `:param` (e.g. `/day/:date`).
- Imports: Use `package:sreerajp_todo/...` package imports; prefer `const` constructors, `final` locals, single quotes.
- Run `dart format` and ensure `flutter analyze` has zero warnings before committing.

---

## Testing rules

- Coverage target: at least **80%** on `lib/data/` and `lib/domain/`.
- Tests are written alongside features in each development phase.
- DAO tests use an **in-memory SQLite** database (`inMemoryDatabasePath`).
- Widget tests mock the repository layer via `mocktail` — never mock DAOs directly.
- Integration tests live in `integration_test/app_test.dart`.
- Every new DAO method must have a unit test added in the same change.
- Do not use `print()` in tests.

---

## Dependency constraints

- **Do not upgrade packages** without running `flutter analyze` and all tests afterwards.
- **Android Gradle Plugin:** Stay on AGP **8.x**.
- **Blocked package categories:** HTTP clients, WebSockets, Cloud/BaaS SDKs, Analytics, Crash reporting, Ads, Network status packages.
- **Approved local-only packages:** `sqflite_sqlcipher`, `sqflite_common_ffi`, `path`, `path_provider`, `flutter_riverpod`, `go_router`, `intl`, `fl_chart`, `table_calendar`, `uuid`, `flutter_localizations`, `characters`, `freezed`, `freezed_annotation`, `json_serializable`, `json_annotation`, `build_runner`, `mocktail`, `flutter_test`, `unorm_dart`, `file_picker`, `flutter_native_splash`, `rrule`, `shared_preferences`.

---

## Where things live

```text
AGENTS.md            # AI agent / LLM project rules (this file)
CLAUDE.md            # Claude Code native project rules (synced with AGENTS.md)
docs/                # Living & point-in-time project documentation suite
plans/               # Dated workflow implementation plans
change_log/          # Timestamped feature change logs
lib/                 # Flutter application source code (5 layers)
test/                # Unit, DAO, use-case, and widget tests
integration_test/    # End-to-end integration tests
android/             # Android host configuration
windows/             # Windows desktop host configuration
```

---

## Workflow rules (mandatory — from global rules)

Every change follows plan-before-changing and log-after-changing:

1. **Plan before changing.** Write a full plan to `plans/` named `yyyymmdd_hhMMss_<short-slug>.md` with a `**Status:**` line, the files to change, the issue, and the fix. Then **STOP and get explicit approval** before editing/creating/deleting any project file (other than the plan). A question or ambiguous reply is not approval.
2. **Log after changing.** After implementing, write a change log to `change_log/` named `yyyymmdd_hhMMss_<short-slug>.md` describing what changed and referencing its plan.
3. **Relative paths & privacy only.** All `plans/` and `change_log/` files MUST use relative repository paths only (never absolute system paths like `C:\...`, `l:\...`, or `file:///...`). They MUST NOT contain any sensitive or private information that cannot be shared publicly on the internet (secrets, API keys, tokens, passwords, keystore passphrases, local absolute paths, internal IPs, credentials, or PII).

Create `plans/` and `change_log/` if they do not exist.

---

## Communication rules

- **Always use simple English.** Write all responses, plans, change logs, and explanations in plain, simple English. Short sentences, common words. Explain any jargon you must use.

---

## What AI agents must always / never do

**Always:**
1. Read this file and `CLAUDE.md` before making non-trivial changes.
2. State the target layer before adding a new class or feature slice.
3. Enforce NFC normalization on every DB text write path (`unicodeUtils.nfcNormalize`).
4. Enforce day-lock checks in every repository mutation.
5. Add unit tests with every new DAO method.
6. Keep user-visible strings in `lib/core/constants/app_strings.dart`.
7. Route multi-step operations through domain use-cases (`lib/domain/usecases/`).
8. Use bundled assets only (`AssetImage`, `Image.asset()`, `Image.file()`).
9. Use PowerShell syntax in docs and command examples on Windows.
10. Run `flutter analyze` and `flutter test` after behavior changes before considering work complete.
11. Preserve the undo UX: SnackBar with 5-second timeout and persistent app-bar undo button for status changes.

**Never:**
1. Put business logic in widget files.
2. Call DAOs directly from widgets or Notifiers.
3. Edit generated `*.freezed.dart` or `*.g.dart` files manually.
4. Write directly to SQLite tables outside the repository layer.
5. Expose raw `sqflite` `Database` objects outside `lib/data/`.
6. Skip NFC normalization before DB text writes.
7. Allow a second open time segment (`end_time IS NULL`) for the same todo.
8. Store secrets, keys, or signing credentials in the project root.
9. Use `Navigator.push()` instead of `go_router`.
10. Add cloud, analytics, networking, telemetry, or connectivity dependencies.
11. Add Android network permissions (`INTERNET`, `ACCESS_NETWORK_STATE`).
12. Use `NetworkImage` or URL-based image loading.
13. Store or transmit data outside the local device filesystem.
14. Make outbound network calls from Dart for any reason.
15. Use `compute()` or `Isolate.spawn()` for `sqflite` queries.
16. Cache the full autocomplete title list in memory.
