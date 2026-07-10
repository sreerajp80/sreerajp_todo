# Change log: Malayalam not showing on Malayalam-enabled Android

Date: 2026-06-24 19:40:21
Implements plan: `plans/20260624_194021_malayalam-locale-not-showing.md`
Scope approved: native fix only (no in-app language switcher).

## Changes made

1. **New file** `android/app/src/main/res/xml/locales_config.xml`
   - Declares the app's supported locales (`en`, `ml`) so Android 13+ (targetSdk 35)
     recognises Malayalam as an app-supported language.

2. **Edited** `android/app/src/main/AndroidManifest.xml`
   - Added `android:localeConfig="@xml/locales_config"` to the `<application>` element.

No network permissions added — offline constraint preserved.
No Flutter/Dart source changed (localization was already correctly wired).

## Required follow-up by user (verification)

The installed APK may predate `app_ml.arb`. Clean rebuild + reinstall required:

```powershell
flutter clean
flutter analyze
flutter run --flavor dev -d <device-id>   # or build apk
```

Then on the device (Android 13+):
- Settings → Apps → SreerajP ToDo → App language → Malayalam should be listed.
- With system or per-app language = Malayalam, the UI shows Malayalam.
