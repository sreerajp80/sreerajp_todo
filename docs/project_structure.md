# Project Structure — SreerajP ToDo

This document details the file tree and directory responsibility layout for SreerajP ToDo.

Read [AGENTS.md](../AGENTS.md) and [architecture.md](architecture.md) first to understand the architectural design.

---

## 1. Directory Tree Overview

```text
sreerajp_todo/
├── .githooks/               # Git automation hooks (pre-commit checks)
├── .github/workflows/       # CI: format, analyze, test, Android + Windows release builds
├── android/                 # Android native app host configuration & resources
├── assets/                  # Bundled static assets (config/, fonts/, splash/, tessdata/)
├── change_log/              # Timestamped feature change logs
├── docs/                    # Living & point-in-time project documentation suite
│   ├── GUIDELINES_MANIFEST.md # Portable manifest pointer to shared Flutter guidelines
│   ├── PROJECT_PROFILE.md   # Declared identity, platforms, stores, languages
│   ├── sreerajp_todo_idea.md # Original product concept and full project plan
│   └── guidelines/          # Shared Flutter Guidelines Git Submodule
├── integration_test/        # End-to-end Flutter integration tests
├── lib/                     # Application source code (5-layer architecture + l10n)
│   ├── application/         # StateNotifiers, Riverpod providers, UI state management
│   ├── core/                # Pure Dart: config (About), constants, errors, logging, rules, security, storage, network, utils, voice
│   ├── data/                # Repository impls, DAOs, migrations, backups, platform channels
│   ├── domain/              # Entities (incl. freezed models), use-cases, repository interfaces
│   ├── l10n/                # ARB localization sources and generated AppLocalizations
│   └── presentation/        # Screens, shared widgets, theme, l10n delegates, context extensions
├── plans/                   # Dated workflow implementation plans
├── prompts/                 # Phase-by-phase AI build prompts (historical)
├── test/                    # Unit, DAO, use-case, and widget tests
│   ├── application/         # Notifier & application state unit tests
│   ├── core/                # Core unit tests (mirrors lib/core/)
│   ├── data/                # DAO, migration, platform & service tests (mirrors lib/data/)
│   ├── domain/              # Entity, repository, service & use-case tests (mirrors lib/domain/)
│   ├── helpers/             # Test factories, fakes, and harness helpers
│   ├── l10n/                # Translation parity & Sanskrit quality tests
│   └── presentation/        # Screen & shared widget tests (mirrors lib/presentation/)
├── tool/                    # Build-metadata generators & development scripts
├── windows/                 # Windows C++ desktop host configuration
├── .gitignore               # Git untracked and excluded files configuration
├── AGENTS.md                # AI agent rulebook (synced with CLAUDE.md)
├── CLAUDE.md                # Primary developer rulebook
├── LICENSE                  # Open source license
├── analysis_options.yaml    # Static analysis and linting configuration
├── l10n.yaml                # Flutter localization tool configuration
├── pubspec.yaml             # Package dependencies and asset manifests
└── README.md                # Project README & user guide
```

---

## 2. Layer Responsibilities (`lib/`)

- **`lib/core/`**: Pure Dart only — no Flutter imports, and no imports from other `lib/` layers. Folders: `config/` (`AppConfig` + `ConfigService`, the fixed About-screen path from `docs/guidelines/guideline.md §1`; `config_service.dart` is the one allowed Flutter import because it reads the asset bundle), `constants/`, `errors/` (exception types under the sealed `AppException`), `logging/` (`app_logger.dart`, the only logger), `network/` (local-network address check), `rules/` (pure business-rule tables such as `time_tracking_rules.dart`), `security/` (`app_lock_service.dart`, `crypto_utils.dart`, `win32_dpapi.dart`), `storage/` (`atomic_saver.dart`), `voice/` (offline voice command parser), and `utils/` (small helpers only: `unicode_utils.dart`, `date_utils.dart`, `duration_utils.dart`, `date_format_rules.dart`, `indic_search_utils.dart`, `rrule_display_utils.dart`).
- **`lib/l10n/`**: Trilingual ARB localization files (`app_en.arb`, `app_ml.arb`, `app_sa.arb`) and generated `AppLocalizations` classes. Every user-visible text string in the app originates from this layer.
- **`lib/domain/`**: Pure Dart business logic (no Flutter and no `data/` imports) containing the entity definitions, including the freezed models (`TodoEntity`, `TimeSegmentEntity`, `RecurrenceRuleEntity`), repository and service interface declarations (`OcrService`, `OcrEnhancer`, `ImageEditService` under `services/`), and orchestration use-cases (`MoveTodo`, `RepairOrphanedSegments`, `DeleteRecurringTodos`).
- **`lib/data/`**: Data access and persistence layer implementing domain interfaces. Includes DAOs (`TodoDao`, `TimeSegmentDao`, `RecurringPatternDao`), SQLite migration runners (`migration_v1.dart`, `migration_v2.dart`), encrypted database backup helpers (`backup_service.dart`), and the device-facing services under `services/` — including the OCR engine (`native_ocr_service.dart`, Tesseract), the QR decoder (`native_qr_decoder_service.dart`, ZXing) and the image enhancement isolate (`isolate_ocr_enhancer.dart`). Thin Dart sides of the app's own method channels (speech, notifications, app lock, keep-awake) live under `platform/`.
- **`lib/application/`**: State management layer holding Riverpod providers (`providers.dart`) and StateNotifiers managing daily lists, search, statistics, backup, and settings state.
- **`lib/presentation/`**: Flutter UI layer structured by screens under `screens/` (`daily_list`, `create_edit_todo`, `statistics`, `backup`, `search_results`, `copy_todos`, `recurring_todos`, `about`, `air_qr_scan`) with screen-private `widgets/` subdirectories, and reusable components under `shared/widgets/` (dialogs, bottom sheets, banners, empty/error states, and `MadeWithLove` adhering to `docs/guidelines/guideline.md §1.7`). Also holds `shared/extensions/localization_extensions.dart` (`context.l10n`), `shared/l10n/sa_framework_localizations.dart` (Sanskrit framework delegates) and `shared/error_message_mapper.dart`. Consumes `AppLocalizations` via `context.l10n`. Completely decoupled from direct `lib/data/` imports.

---

## 3. Platform Host Directories

- **`android/`**: Configured with target SDK 35, AGP 9.x, native splash configuration, locale configuration (`locales_config.xml`), and `INTERNET` as the only network permission (local Wi-Fi sync only).
- **`windows/`**: Configured for Windows C++ desktop host with SQLCipher FFI binding support and no internet traffic (Wi-Fi sync stays on the local network).

---

## 4. Test Directory Layout

The `test/` directory strictly mirrors `lib/` layout to ensure clear ownership and traceability ([engineering standard](guidelines/flutter_project_engineering_standard.md) §3.2):

- **`test/application/`**: Unit tests for Riverpod StateNotifiers (appearance, focus, locale, notifications, ritual, settings).
- **`test/core/`**: Unit tests mirroring `lib/core/` (`config/`, `errors/`, `network/`, `rules/`, `storage/`, `utils/`, `voice/`).
- **`test/data/`**: Tests mirroring `lib/data/` (`backup/`, `dao/`, `database/migrations/`, `platform/`, `repositories/`, `services/`), run against in-memory SQLite database instances.
- **`test/domain/`**: Tests mirroring `lib/domain/` (`entities/`, `repositories/`, `services/`, `usecases/`) covering domain rules (day lock, status lock, duplicate titles).
- **`test/helpers/`**: Test harness utilities, in-memory database factories, and mock providers.
- **`test/l10n/`**: Translation parity tests (`translation_parity_test.dart`) enforcing 100% key parity, `{heart}` badge marker, and JSON config validity; and Sanskrit quality gate tests (`sanskrit_quality_test.dart`) enforcing classical Sanskrit standards.
- **`test/presentation/`**: Widget tests mocking repository interfaces. Screen tests live in `screens/<screen>/`; shared widget, theme and l10n-delegate tests live in `shared/` (including `made_with_love_test.dart`). `icon_button_tooltips_compliance_test.dart` is a whole-app check and stays at the top.
- **`integration_test/`**: End-to-end integration tests (`app_test.dart`).
