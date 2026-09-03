# Close the offline speech gap and remove the hardcoded test key

**Status:** completed

## Background

We unzipped the shipped release APK and reviewed what a person can read from it.
Nothing secret is exposed: the database key is made at first run and kept in the
Android Keystore, the signing private key is not bundled, and there are no tokens
or network code. Two items came out of that review and are handled here.

The author email in `assets/config/app_config.json` and the `RECORD_AUDIO`
permission were also raised, but both are intentional (the About screen shows the
email, and the microphone drives voice task capture). No change for those.

## Files to change

| File | Change |
|------|--------|
| `android/app/src/main/kotlin/in/sreerajp/sreerajp_todo/MainActivity.kt` | Refuse voice capture on Android below 13, where offline speech cannot be promised |
| `lib/data/database/database_key_service.dart` | Stop using a fixed literal key in the test path |
| `test/data/database_key_service_test.dart` | Assert key shape and stability instead of one fixed value |

## Issue 1 — offline speech is not guaranteed on Android 6 to 12

`checkSpeechReadiness()` only checks `isOnDeviceRecognitionAvailable` when the
device runs Android 13 (`TIRAMISU`) or newer. Our `minSdk` is 21, so devices on
Android 6 through 12 skip that check and get back `"ready"`. `startListening()`
then falls back to the plain `createSpeechRecognizer` and sets
`EXTRA_PREFER_OFFLINE`, which is only a hint, not a promise.

If the system speech service on such a device has no offline language model but
does have a working internet connection, it can send the recorded audio to a
server and return a normal successful result. Our app itself stays clean, because
it holds no `INTERNET` permission, but the recognition runs inside another app's
process that has its own network access. So the spoken task text can leave the
device, which breaks the "fully offline" promise in `CLAUDE.md`.

The existing `ERROR_NETWORK` to `no_offline_language` mapping does not cover this.
That only fires when the network call *fails*. When the network works, the cloud
path simply succeeds and nobody is told.

### Fix

In `checkSpeechReadiness()`, treat every Android version below `TIRAMISU` the same
way we already treat versions below `M`: return `"no_offline"`.

Nothing else needs to change. The Dart side already turns `"no_offline"` into
`SpeechUnavailableReason.noOfflineEngine`, and `voice_command_sheet.dart` already
shows `voiceUnavailableNoOffline`, whose wording ("This device cannot recognise
speech without going online, so the microphone stays off. Type the sentence
instead.") fits this case exactly. The Malayalam string is present too.

`startListening()` keeps its own version branch as a second guard, so a call that
somehow gets through still behaves safely.

### Effect on users

Voice task capture becomes Android 13 and newer only. On older devices the
microphone button explains why it is off and the person types instead. This is the
honest trade: we would rather lose the feature on old devices than quietly send a
recording to a server.

## Issue 2 — a fixed key literal is compiled into the shipped binary

`DatabaseKeyService.getOrCreateDatabaseKey()` returns the literal
`0123456789abcdef...` when `FLUTTER_TEST` is set. Dart string constants survive
into `libapp.so`, and we confirmed this one appears twice in the release APK.

This is **not** exploitable. An attacker cannot set that environment variable on an
installed app, and even if they could, the real database is encrypted with the real
Keystore key and would refuse to open. But a fixed-looking key sitting in a binary
is exactly what a security scan flags, and it costs little to remove.

### Fix

Replace the literal with a random 64-character key made once per process and shared
by every instance, using the existing `generateKeyHex()`:

- Add a private `static final String _testKey` initialised from `generateKeyHex()`.
- The test branch returns `_testKey`.

`generateKeyHex()` is currently an instance method. It only uses `Random.secure()`
and local state, so it moves to a static helper (or the static field calls a small
private static function) with no behaviour change.

Sharing one value across all instances in a run keeps today's behaviour exactly. A
test that opens a database with one `DatabaseKeyService`, then reopens it with a
fresh one, still sees the same key. Only the fixed *value* goes away.

### Test update

`test/data/database_key_service_test.dart` asserts the exact literal. That test
changes to check what actually matters:

- the key is 64 characters of lowercase hex,
- two calls on the same instance return the same value (already covered),
- two different instances return the same value within one test run.

The test name changes from "returns deterministic test key in test environment" to
something like "returns a stable hex key in test environment".

## Verification

- `flutter analyze` must report 0 issues.
- `flutter test` must pass in full, not just the key service test. Other tests open
  databases through this service, so a whole-suite run is the real check.
- Rebuild the release APK and confirm the literal is gone from `libapp.so`.
- Manual check on an Android 13+ device: voice capture still works.
- Manual check on an Android 12 or older device or emulator: the microphone button
  is refused with the offline message rather than listening.

## Risks

- The Kotlin change removes a working feature on older Android. This is deliberate
  and is the point of the fix, but it is a visible behaviour change.
- If any test turns out to depend on the exact old key value beyond the one test
  listed, the whole-suite run will catch it and that test gets the same treatment.
