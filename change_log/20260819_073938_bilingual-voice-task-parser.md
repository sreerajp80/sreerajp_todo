# Change log — Bilingual Offline Voice Task Parser (`en-IN` & `ml-IN`)

Implements the plan `plans/20260819_071646_bilingual-voice-task-parser.md` (option **A**:
parser, typed sheet, and the Android microphone behind an off-by-default setting).

Covers feature 3.2 of `docs/unique_features_and_improvements.md`.

---

## What was built

One plain sentence in, one ready-made task out, worked out entirely on the device.

### 1. The parser — pure Dart, `lib/core/voice/`

- `voice_parse_result.dart` — what a sentence was understood to mean: title, day, time of
  day, target seconds, priority, and which of those were actually found. `VoicePriority`
  mirrors `TodoPriority` by name so `core/` never imports `data/`.
- `voice_command_parser.dart` — the engine. It walks the sentence four times, in this
  order, taking the matched words out as it goes; the leftovers become the title:
  1. **duration** (`for 30 minutes`, `45 മിനിറ്റ്`) — first, because a duration always
     names its unit, and because it stops `രണ്ട് മണിക്കൂർ` ("two hours long") from being
     read as `രണ്ട് മണിക്ക്` ("at two o'clock"), which start the same way;
  2. **time of day** (`at 10 am`, `10:30 pm`, `half past seven`, `ഏഴരയ്ക്ക്`,
     `പത്തു മണിക്ക്`);
  3. **date** (`tomorrow`, `the day after tomorrow`, `in 3 days`, any weekday,
     `അടുത്ത തിങ്കളാഴ്ച`, `മറ്റന്നാൾ`, `അടുത്ത ആഴ്ച`);
  4. **priority** (`urgent`, `low priority`, `അടിയന്തിരം`).
- `voice_lexicon_en.dart` and `voice_lexicon_ml.dart` — every word the engine knows. The
  engine itself holds rules and no vocabulary.

Two decisions worth recording:

- **Malayalam is matched by stem, not by whole word.** Malayalam glues its case endings on,
  so `ഏഴര` turns up in a real sentence as `ഏഴരയ്ക്ക്`. The Malayalam lexicon stores stems,
  the parser matches the start of a token and then swallows the whole token. Longer stems
  always win, so `പത്തൊൻപത` (19) beats `പത്ത` (10), and `ഒന്നര` (half past one) beats
  `ഒന്ന്` (one). Glued forms such as `പത്തുമണിക്ക്` and `45മിനിറ്റ്` are handled too.
- **The parser never invents.** No date words means today. An hour with no `am`, `pm` or
  part-of-day word is kept exactly as said, so `ഏഴര` is 07:30 and `at 5` is 05:00 rather
  than a guessed 17:00. A day already past is clamped to today, because Day-Lock makes past
  days read-only.

Both lexicons run against every token, so a mixed sentence such as
`Call അമ്മ നാളെ for 20 minutes` needs no language switch.

### 2. The sheet and its state

- `lib/application/voice_capture_state.dart` (+ generated `.freezed.dart`) and
  `voice_capture_notifier.dart` — idle / listening / ready, the words, the reading, and any
  error. It touches no DAO and saves nothing.
- `lib/presentation/screens/daily_list/widgets/voice_command_sheet.dart` — the floating
  sheet: language toggle, microphone button, text box, and chips showing what was
  understood. **Create task** opens the ordinary create form with the fields filled in, so
  Day-Lock, the duplicate-title check and NFC normalisation stay enforced where they always
  were. `nfcNormalize()` runs before matching and on the title after;
  `detectTextDirection()` drives the text box and the chips.
- A task has no time-of-day column, so a spoken time is written into the description as a
  short note (`At 10:30`) rather than being dropped.
- Opening the sheet on a future day and saying nothing about a day keeps that day, instead
  of quietly moving the task to today.

### 3. Speech to text, without a package

- `lib/core/platform/speech_channel.dart` and a new `in.sreerajp.todo/speech` method
  channel plus `…/speech_events` event channel in `MainActivity.kt`, over Android
  `SpeechRecognizer`. No package was added, so the audited dependency list is unchanged.
- The on-device engine is always asked for — `createOnDeviceSpeechRecognizer` on API 33+,
  `EXTRA_PREFER_OFFLINE` below it. A device that cannot promise that reports `no_offline`
  and **listening is refused**, rather than being allowed to fall back to a server. A
  recogniser that still reaches for the network has that error mapped to
  `no_offline_language`, and the user is told to install an offline pack or type instead.
- No audio is recorded or kept. The recogniser is destroyed when the sentence ends, when
  the sheet closes, and in `onDestroy`.

### 4. Off by default

`Settings → Task defaults → Day list → Voice input`, off by default. Only with it on does a
microphone button appear above the add button on the day list, and only then can the
microphone permission ever be asked for. A fresh install behaves exactly as before.

---

## Files changed

**New**

| File | What it is |
|---|---|
| `lib/core/voice/voice_parse_result.dart` | The reading of a sentence |
| `lib/core/voice/voice_command_parser.dart` | The four-pass engine |
| `lib/core/voice/voice_lexicon_en.dart` | Every English word it knows |
| `lib/core/voice/voice_lexicon_ml.dart` | Every Malayalam stem it knows |
| `lib/core/platform/speech_channel.dart` | Dart side of the recogniser channel |
| `lib/application/voice_capture_state.dart` (+ `.freezed.dart`) | Sheet state |
| `lib/application/voice_capture_notifier.dart` | Sheet logic |
| `lib/presentation/screens/daily_list/widgets/voice_command_sheet.dart` | The sheet |
| `test/core/voice/voice_command_parser_en_test.dart` | 27 English tests |
| `test/core/voice/voice_command_parser_ml_test.dart` | 20 Malayalam tests |
| `test/application/voice_capture_notifier_test.dart` | 13 state tests |
| `test/presentation/voice_command_sheet_test.dart` | 5 widget tests |

**Changed**

| File | Change |
|---|---|
| `lib/presentation/screens/daily_list/daily_list_screen.dart` | Add button became a stack: a small microphone button above it when Voice input is on. Both still hidden on a past day |
| `lib/app.dart` | `/todo/new` now also reads `title`, `description`, `target` and `priority` |
| `lib/core/constants/app_routes.dart` | New `createTodoPath(...)` builder, so query strings and their escaping are built in one place |
| `lib/presentation/screens/create_edit_todo/create_edit_todo_screen.dart` | Four optional `initial…` values, applied only when creating. A prefilled title runs the same duplicate check typing would have run |
| `lib/application/task_defaults_notifier.dart` | New `voiceInputEnabled` flag, off by default |
| `lib/presentation/screens/settings/task_defaults/defaults_day_list_screen.dart` | The Voice input switch |
| `lib/application/providers.dart` | `speechChannelProvider` and the auto-disposed `voiceCaptureProvider` |
| `lib/presentation/screens/settings/permissions_screen.dart` | Now lists the camera and the microphone honestly (see below) |
| `lib/l10n/app_en.arb`, `lib/l10n/app_ml.arb` | 30 new strings in both languages |
| `android/app/src/main/AndroidManifest.xml` | `RECORD_AUDIO`, and a `<queries>` entry for `android.speech.RecognitionService` so the recogniser is visible on API 30+. **No network permission was added** |
| `android/app/src/main/kotlin/in/sreerajp/sreerajp_todo/MainActivity.kt` | The speech channel, the microphone permission request, and recogniser clean-up |
| `docs/features.md` | New section 3.9, and the Voice input setting under 3.8 |
| `docs/architecture.md` | `core/voice/` and `core/platform/` in the source layout, the new channels, the widened `/todo/new` route |
| `docs/security.md` | Camera and microphone in the permission table, and a full section on why `RECORD_AUDIO` does not break the offline guarantee |
| `docs/dependencies.md` | Speech packages added to the prohibited list with the reason, and a new table of native capabilities reached by channel instead of by package |
| `docs/unique_features_and_improvements.md` | 3.2 marked done, summary row and count updated (13 done, 3 partly, 7 planned) |

No DAO, repository, migration or database change. Nothing about Day-Lock, terminal status,
open segments or title uniqueness moved.

---

## A correction made along the way

The permissions screen said the app "declares zero permissions in the Android manifest for
release builds. No runtime permission dialogs are shown." That was already untrue — the
camera is declared for QR scanning — and adding a microphone would have made it doubly so.
The old string was removed and the screen now lists both permissions with what each is for
and when it is asked for, followed by a plain statement that no network permission is
declared. `docs/security.md` was corrected in the same way.

---

## Checks run

- `flutter analyze` — no new errors. The 7 errors it reports are pre-existing and in files
  this change never touched (see below). Two new `prefer_initializing_formals` infos in
  `voice_capture_notifier.dart` match the two that already exist in
  `app_lock_notifier.dart` and `security_settings_notifier.dart`; the suggested fix cannot
  be applied, because Dart forbids a named parameter whose name starts with an underscore.
- `flutter test` — **557 passed, 0 failed** (65 of them new).
- `dart format lib/ test/` — clean.
- `./gradlew :app:compileDevDebugKotlin` — **BUILD SUCCESSFUL**, so the new Kotlin
  compiles.
- Merged manifest audit — see the two findings below.

---

## Two problems found that this change did not cause

Both were already in the working tree. Neither was fixed here, because both are outside
what was asked for and the second one needs a decision.

**1. `flutter analyze` has 7 pre-existing errors.** `securitySettingsProvider` and
`appLockProvider` are used by `lib/presentation/screens/settings/security_screen.dart` and
`lib/presentation/screens/settings/security/app_lock_screen.dart`, but they are not
declared anywhere in `lib/`. `lib/application/security_settings_notifier.dart` and
`app_lock_notifier.dart` exist; the two providers appear never to have been added to
`providers.dart`. Until that is fixed the app will not compile for a device, so
`flutter build apk` cannot run.

**2. The release build already carries `INTERNET` and `ACCESS_NETWORK_STATE`.** The merged
manifest for `prodRelease` was audited and it contains both. The manifest merger blame
report names the source:

```
mobile_scanner
  -> com.google.mlkit:barcode-scanning:17.3.0
    -> com.google.android.gms:play-services-mlkit-barcode-scanning:18.3.1
      -> com.google.android.datatransport:transport-backend-cct:2.3.3   <- declares both
```

`transport-backend-cct` is Google's telemetry upload transport, and the same chain also
pulls in `firebase-components` and `firebase-encoders`. This conflicts with three hard
rules at once: zero network permissions, no analytics or telemetry, and the blocked
package categories in `docs/dependencies.md`. It predates this change — the microphone work
added no Gradle dependency at all.

Worth deciding on separately. The usual options are to declare
`<uses-permission android:name="android.permission.INTERNET" tools:node="remove"/>` in the
main manifest, to move to an unbundled MLKit scanner, or to drop `mobile_scanner` and use a
different QR reader.
