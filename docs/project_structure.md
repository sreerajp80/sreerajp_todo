# Project Structure — SreerajP ToDo

This document details the file tree and directory responsibility layout for SreerajP ToDo.

Read [AGENTS.md](../AGENTS.md) and [architecture.md](architecture.md) first to understand the architectural design.

---

## 1. Directory Tree Overview

```text
sreerajp_todo/
├── .githooks/               # Git automation hooks
├── android/                 # Android native app host configuration & resources
├── assets/                  # Bundled static assets (config/, fonts/, splash images)
├── change_log/              # Timestamped feature change logs
├── docs/                    # Living & point-in-time project documentation suite
│   └── guidelines/          # Shared Flutter Guidelines Git Submodule
├── integration_test/        # End-to-end Flutter integration tests
├── lib/                     # Application source code (5-layer architecture + l10n)
│   ├── application/         # StateNotifiers, Riverpod providers, UI state management
│   ├── core/                # Utility functions, config (About), constants, theme, exceptions
│   ├── data/                # Repository impls, DAOs, SQLite models, migrations, backups
│   ├── domain/              # Domain entities, use-cases, repository interfaces
│   ├── l10n/                # ARB localization sources and generated AppLocalizations
│   └── presentation/        # Screens, widgets, dialogs, router configuration
├── plans/                   # Dated workflow implementation plans
├── test/                    # Unit, DAO, use-case, and widget tests
├── tool/                    # Database inspection & development scripts
├── windows/                 # Windows C++ desktop host configuration
├── AGENTS.md                # AI agent rulebook (synced with CLAUDE.md)
├── CLAUDE.md                # Primary developer rulebook
├── pubspec.yaml             # Package dependencies and asset manifests
└── README.md                # Project README & user guide
```

---

## 2. Layer Responsibilities (`lib/`)

- **`lib/core/`**: Utilities (`unicode_utils.dart`, `date_utils.dart`, `duration_utils.dart`), config (`app_config.dart`, `config_service.dart`), constants (`app_constants.dart`, `app_routes.dart`), app theme definitions, and custom exception classes. Pure Dart utilities and domain types; `config/` implements the standard About-screen config loader.
- **`lib/l10n/`**: Bilingual ARB localization files (`app_en.arb`, `app_ml.arb`) and generated `AppLocalizations` classes. Every user-visible text string in the app originates from this layer.
- **`lib/domain/`**: Pure business logic containing entity definitions (`TodoEntity`, `TimeSegmentEntity`, `RecurringPatternEntity`), repository interface declarations, and orchestration use-cases (`PortTodo`, `RepairOrphanedSegments`, `DeleteRecurringTodos`).
- **`lib/data/`**: Data access and persistence layer implementing domain interfaces. Includes DAOs (`TodoDao`, `TimeSegmentDao`, `RecurringPatternDao`), SQLite migration runners (`migration_v1.dart`, `migration_v2.dart`), and encrypted database backup helpers (`backup_service.dart`).
- **`lib/application/`**: State management layer holding Riverpod providers (`providers.dart`) and StateNotifiers managing daily lists, search, statistics, backup, and settings state.
- **`lib/presentation/`**: Flutter UI layer structured by screens (`daily_list`, `create_edit_todo`, `statistics`, `backup`, `search_results`, `copy_todos`, `recurring_todos`, `about`) with supporting `widgets/` subdirectories. Consumes `AppLocalizations` via `context.l10n`.

---

## 3. Platform Host Directories

- **`android/`**: Configured with target SDK 34, AGP 8.x, native splash configuration, locale configuration (`locales_config.xml`), and zero network permissions.
- **`windows/`**: Configured for Windows C++ desktop host with SQLCipher FFI binding support and zero network capabilities.

---

## 4. Test Directory Layout

- **`test/core/`**: Unit tests for date, duration, and Unicode utilities.
- **`test/data/`**: DAO unit tests executed against in-memory SQLite database instances.
- **`test/domain/`**: Use-case unit tests covering domain rules (Day lock, status lock, duplicate titles).
- **`test/presentation/`**: Widget tests mocking repository interfaces to test UI interactions.
- **`integration_test/`**: End-to-end integration tests (`app_test.dart`).
