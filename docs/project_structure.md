# Project Structure — SreerajP ToDo

This document details the file tree and directory responsibility layout for SreerajP ToDo.

Read [AGENTS.md](../AGENTS.md) and [architecture.md](architecture.md) first to understand the architectural design.

---

## 1. Directory Tree Overview

```text
sreerajp_todo/
├── .githooks/               # Git automation hooks
├── android/                 # Android native app host configuration & resources
├── assets/                  # Bundled static assets (config/, fonts/, splash/, tessdata/)
├── change_log/              # Timestamped feature change logs
├── docs/                    # Living & point-in-time project documentation suite
│   ├── GUIDELINES_MANIFEST.md # Portable manifest pointer to shared Flutter guidelines
│   └── guidelines/          # Shared Flutter Guidelines Git Submodule
├── integration_test/        # End-to-end Flutter integration tests
├── lib/                     # Application source code (5-layer architecture + l10n)
│   ├── application/         # StateNotifiers, Riverpod providers, UI state management
│   ├── core/                # Utility functions, config (About), constants, theme, exceptions
│   ├── data/                # Repository impls, DAOs, SQLite models, migrations, backups
│   ├── domain/              # Domain entities, use-cases, repository interfaces
│   ├── l10n/                # ARB localization sources and generated AppLocalizations
│   ├── presentation/        # Screens, widgets, dialogs, router configuration
│   └── widgets/             # Reusable core widgets (made_with_love.dart)
├── plans/                   # Dated workflow implementation plans
├── test/                    # Unit, DAO, use-case, and widget tests
│   ├── application/         # Notifier & application state unit tests
│   ├── core/                # Utility & core model unit tests
│   ├── data/                # DAO & service tests against in-memory SQLite
│   ├── domain/              # Business rule & use-case unit tests
│   ├── helpers/             # Test factories, fakes, and harness helpers
│   ├── l10n/                # Translation parity & Sanskrit quality tests
│   ├── presentation/        # Screen & widget interaction tests
│   └── widgets/             # Reusable core widget tests mirroring lib/widgets/
├── tool/                    # Database inspection & development scripts
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

- **`lib/core/`**: Utilities (`unicode_utils.dart`, `date_utils.dart`, `duration_utils.dart`), config (`app_config.dart`, `config_service.dart`), constants (`app_constants.dart`, `app_routes.dart`), app theme definitions, and custom exception classes. Pure Dart utilities and domain types; `config/` implements the standard About-screen config loader adhering to `docs/guidelines/guideline.md §1`.
- **`lib/l10n/`**: Trilingual ARB localization files (`app_en.arb`, `app_ml.arb`, `app_sa.arb`) and generated `AppLocalizations` classes. Every user-visible text string in the app originates from this layer.
- **`lib/domain/`**: Pure business logic containing entity definitions (`TodoEntity`, `TimeSegmentEntity`, `RecurringPatternEntity`), repository and service interface declarations (`OcrService`, `OcrEnhancer`, `ImageEditService` under `services/`), and orchestration use-cases (`PortTodo`, `RepairOrphanedSegments`, `DeleteRecurringTodos`).
- **`lib/data/`**: Data access and persistence layer implementing domain interfaces. Includes DAOs (`TodoDao`, `TimeSegmentDao`, `RecurringPatternDao`), SQLite migration runners (`migration_v1.dart`, `migration_v2.dart`), encrypted database backup helpers (`backup_service.dart`), and the device-facing services under `services/` — including the OCR engines (`native_ocr_service.dart`, `mlkit_ocr_service.dart`) and the image enhancement isolate (`isolate_ocr_enhancer.dart`).
- **`lib/application/`**: State management layer holding Riverpod providers (`providers.dart`) and StateNotifiers managing daily lists, search, statistics, backup, and settings state.
- **`lib/presentation/`**: Flutter UI layer structured by screens under `screens/` (`daily_list`, `create_edit_todo`, `statistics`, `backup`, `search_results`, `copy_todos`, `recurring_todos`, `about`, `air_qr_scan`) with screen-private `widgets/` subdirectories, and reusable components under `shared/widgets/` (dialogs, bottom sheets, banners, empty/error states, and `MadeWithLove` adhering to `docs/guidelines/guideline.md §1.7`). Consumes `AppLocalizations` via `context.l10n`. Completely decoupled from direct `lib/data/` imports.

---

## 3. Platform Host Directories

- **`android/`**: Configured with target SDK 35, AGP 8.x, native splash configuration, locale configuration (`locales_config.xml`), and zero network permissions.
- **`windows/`**: Configured for Windows C++ desktop host with SQLCipher FFI binding support and zero network capabilities.

---

## 4. Test Directory Layout

The `test/` directory strictly mirrors `lib/` layout to ensure clear ownership and traceability (`flutter_project_engineering_standard.md §3.2`):

- **`test/application/`**: Unit tests for Riverpod StateNotifiers (appearance, focus, locale, notifications, ritual, settings).
- **`test/core/`**: Unit tests for date, duration, Unicode utilities, and About config models.
- **`test/data/`**: DAO and service unit tests executed against in-memory SQLite database instances.
- **`test/domain/`**: Use-case unit tests covering domain rules (Day lock, status lock, duplicate titles).
- **`test/helpers/`**: Test harness utilities, in-memory database factories, and mock providers.
- **`test/l10n/`**: Translation parity tests (`translation_parity_test.dart`) enforcing 100% key parity, `{heart}` badge marker, and JSON config validity; and Sanskrit quality gate tests (`sanskrit_quality_test.dart`) enforcing classical Sanskrit standards.
- **`test/presentation/`**: Widget tests mocking repository interfaces to test UI screens and dialogs.
- **`test/widgets/`**: Widget tests mirroring `lib/widgets/` for reusable core components (`made_with_love_test.dart`).
- **`integration_test/`**: End-to-end integration tests (`app_test.dart`).
