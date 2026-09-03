# Closed the offline speech gap and removed the hardcoded test key

Implements `plans/20260903_050503_offline_speech_and_test_key.md`.

## Why

A review of the shipped release APK checked what a person can read after unzipping
it. No secrets are exposed: the database key is made at first run and kept in the
Android Keystore, the signing private key is not bundled, and there is no network
code. Two items came out of that review.

The author email in the bundled config and the `RECORD_AUDIO` permission were also
looked at, but both are intentional (the About screen shows the email, and the
microphone drives voice task capture). Neither was changed.

## What changed

### 1. Voice capture now needs Android 13 or newer

`android/app/src/main/kotlin/in/sreerajp/sreerajp_todo/MainActivity.kt`

`checkSpeechReadiness()` only asked for an on-device recogniser on Android 13 and
newer. Our `minSdk` is 21, so devices on Android 6 through 12 skipped that check
and were told listening was `"ready"`. Those devices then fell back to the plain
`createSpeechRecognizer` with `EXTRA_PREFER_OFFLINE`, which is only a hint. If the
system speech service had no offline language model but did have a connection, it
could send the recording to a server and return a normal successful result. The app
itself has no `INTERNET` permission, but the recognition runs in another app's
process that does have network access, so spoken task text could leave the device.

The version check is now a single test: anything below Android 13 returns
`"no_offline"`, and Android 13 and newer must report an on-device recogniser.

Nothing else needed changing. The Dart side already maps `"no_offline"` to
`SpeechUnavailableReason.noOfflineEngine`, and the voice sheet already shows
`voiceUnavailableNoOffline`, whose wording fits this case in both English and
Malayalam. The version branch inside `startListening()` was left as a second guard.

Effect: on Android 12 and older the microphone button explains why it is off and
the person types the task instead. Losing the feature on old devices is the
deliberate trade for keeping the offline promise.

### 2. No fixed key literal in the shipped binary

`lib/data/database/database_key_service.dart`

The test path returned the literal `0123456789abcdef...`. Dart string constants
survive into `libapp.so`, and that value was present twice in the release APK. It
was never exploitable, since the environment variable cannot be set on an installed
app and the real database is encrypted with the real Keystore key, but a
key-shaped constant in a binary is what a security scan flags.

The literal is replaced by `_testKeyHex`, a random 64-character hex key made once
per process by a new private static `_randomKeyHex()`. `generateKeyHex()` now calls
that same helper, so behaviour is unchanged. Sharing one value across all instances
in a run means a test that reopens a database with a fresh service still gets the
same key.

### 3. Test updated to match

`test/data/database_key_service_test.dart`

The test asserted the exact old literal. It now checks what matters: the key is 64
lowercase hex characters, and a new test confirms two separate instances return the
same key within one run. The existing caching test is unchanged.

## Verification

- `flutter analyze` — no issues found.
- `flutter test` — all 631 tests passed.
- Rebuilt the prod release APK for arm64 and searched the new `libapp.so`: zero
  matches for the old key literal, down from two.

Not yet done, and left for the device owner: the manual checks on real hardware —
that voice capture still works on Android 13 or newer, and that on an Android 12 or
older device the microphone button is refused with the offline message.

Note: `lib/core/constants/build_date.g.dart` was updated by the build hook during
the verification build. It is generated, not hand edited.
