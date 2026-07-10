# Fix: Malayalam not showing on Malayalam-enabled Android

Date: 2026-06-24 19:40:21

## The issue

The app has multilingual support (English + Malayalam) wired up correctly on the
Flutter side, but a device with the system language set to Malayalam still shows
English.

### What is already correct (no change needed)

- `l10n.yaml` configured; `lib/l10n/app_en.arb` + `lib/l10n/app_ml.arb` present.
- Generated `AppLocalizations` declares `supportedLocales = [Locale('en'), Locale('ml')]`.
- Delegates registered in `lib/app.dart`
  (`localizationsDelegates` / `supportedLocales`).
- Widgets consume strings via `context.l10n` (extension over `AppLocalizations.of`).
- `app_ml.arb` / `app_localizations_ml.dart` contain genuine Malayalam translations.

### Root cause

- `android/app/build.gradle.kts` sets `targetSdk = maxOf(flutter.targetSdkVersion, 35)`
  → Android 13+ (API 33+), where per-app language is system-managed.
- The project has **no** `res/xml/locales_config.xml` and **no**
  `android:localeConfig` attribute on `<application>` in `AndroidManifest.xml`.
- Without these, on Android 13+ the OS does not know the app supports Malayalam:
  the per-app "App language" picker won't list it, and the system does not reliably
  deliver the `ml` locale to the app. This is the officially documented requirement
  for Flutter apps on Android 13+.

## Files to change

1. `android/app/src/main/res/xml/locales_config.xml` — **new file**.
   Lists the app's supported BCP-47 locales (`en`, `ml`).
2. `android/app/src/main/AndroidManifest.xml` — add
   `android:localeConfig="@xml/locales_config"` to the `<application>` element.
   (Offline rule check: this adds no network permission — compliant.)

## The fix

### 1. New `res/xml/locales_config.xml`

```xml
<?xml version="1.0" encoding="utf-8"?>
<locale-config xmlns:android="http://schemas.android.com/apk/res/android">
    <locale android:name="en"/>
    <locale android:name="ml"/>
</locale-config>
```

### 2. Manifest

Add to the existing `<application ...>` tag:

```
android:localeConfig="@xml/locales_config"
```

## Verification

```powershell
# Rebuild a fresh APK (the device may be running a build that predates app_ml.arb)
flutter clean
flutter build apk --flavor dev --debug   # or run on device
flutter analyze
```

On the device (Android 13+):
- Settings → Apps → SreerajP ToDo → App language → Malayalam should now be listed.
- With system or per-app language = Malayalam, app UI shows Malayalam.

Note: a likely contributing factor is that the device has an **older APK** built
before `app_ml.arb` existed (arb/generated files are dated today). A clean rebuild
+ reinstall is required regardless of the manifest change.

## Optional enhancement (NOT in this plan unless approved)

An in-app language switcher in Settings (persisted preference + `MaterialApp.locale`
override) would guarantee Malayalam regardless of OS/OEM locale quirks and let users
switch without changing the whole device. This adds an `app_strings`/settings provider
and a shared_preferences-equivalent local store. Decide separately.
