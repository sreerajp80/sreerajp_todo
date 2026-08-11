# Added assets/config/app_config.json and AppConfig Service

**Plan:** `plans/20260810_113120_add-assets-config-and-app-config.md`

## Summary of Changes

1. **Created `assets/config/app_config.json`**: Defined application metadata (`appName`, `description`, `version`, `build`, and custom `details` key-value pairs).
2. **Updated `pubspec.yaml`**: Registered `- assets/config/` under `flutter: assets:`.
3. **Created `lib/core/config/app_config.dart`**: Implemented `AppConfig` domain data model with static `fallback` defaults and safe `fromJson` constructor.
4. **Created `lib/core/config/config_service.dart`**: Implemented `ConfigService` for asset loading and JSON decoding.
5. **Updated `lib/application/providers.dart`**: Exposed `configServiceProvider` and `appConfigProvider` for Riverpod state management.
6. **Updated `lib/presentation/screens/about/about_screen.dart`**: Converted `AboutScreen` to a `ConsumerWidget` that dynamically renders values and details from `AppConfig`.
7. **Created Unit Tests**: Added `test/core/config/app_config_test.dart` and `test/core/config/config_service_test.dart`.
