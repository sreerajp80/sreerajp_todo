# Add assets/config/app_config.json and AppConfig Service as per Guidelines

**Status:** completed

## Files to change

- `assets/config/app_config.json` [NEW]
- `pubspec.yaml` [MODIFY]
- `lib/core/config/app_config.dart` [NEW]
- `lib/core/config/config_service.dart` [NEW]
- `lib/application/providers.dart` [MODIFY]
- `lib/presentation/screens/about/about_screen.dart` [MODIFY]
- `test/core/config/app_config_test.dart` [NEW]
- `test/core/config/config_service_test.dart` [NEW]

## What is wrong

The app is missing `assets/config/app_config.json`, `lib/core/config/app_config.dart`, and `lib/core/config/config_service.dart`.
According to the cross-app folder-structure guideline (`docs/guidelines/guideline.md`), all apps MUST feature `assets/config/app_config.json` as the single source of truth for About-screen metadata, load it through `ConfigService` and `AppConfig`, and register `assets/config/` in `pubspec.yaml`.

## Proposed Plan

1. Create `assets/config/app_config.json` containing app metadata (`appName`, `description`, `version`, `build`, `details`).
2. Update `pubspec.yaml` to include `- assets/config/` under `flutter: assets:`.
3. Create `lib/core/config/app_config.dart` with `AppConfig` domain model class, safe fallback constants, and `fromJson` deserializer.
4. Create `lib/core/config/config_service.dart` to safely load and decode `assets/config/app_config.json` with fallback on failure.
5. Update `lib/application/providers.dart` to expose `configServiceProvider` and `appConfigProvider`.
6. Update `lib/presentation/screens/about/about_screen.dart` to consume `appConfigProvider` and dynamically render detail key-value pairs from `AppConfig`.
7. Add unit test suite in `test/core/config/app_config_test.dart` and `test/core/config/config_service_test.dart`.

## After approval

Write a change log in `change_log/20260810_113120_add-assets-config-and-app-config.md` describing the additions.
