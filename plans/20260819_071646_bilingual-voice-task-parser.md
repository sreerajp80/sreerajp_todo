# Bilingual Offline Natural Language Voice Task Parser (`en-IN` & `ml-IN`)

**Status:** completed

Implements feature 3.2 from `docs/unique_features_and_improvements.md`.

---

## 1. What we want

Let the user speak or type one plain sentence and get a ready-made task from it.
Both English and Malayalam must work equally well. Everything must run on the
device. No network calls, no cloud speech service, no new package.

Example inputs and what the app should pull out of them:

| Spoken / typed sentence | Title | Date | Time | Target |
|---|---|---|---|---|
| `Call the bank tomorrow at 10 am for 30 minutes` | Call the bank | tomorrow | 10:00 | 30 min |
| `Study Dart next Monday for 1 hour 30 minutes` | Study Dart | next Monday | — | 90 min |
| `ഏഴരയ്ക്ക് നടക്കാൻ പോകണം` | നടക്കാൻ പോകണം | today | 07:30 | — |
| `അടുത്ത തിങ്കളാഴ്ച 45 മിനിറ്റ് പഠനം` | പഠനം | next Monday | — | 45 min |
| `പത്തു മണിക്ക് ഡോക്ടറെ കാണണം` | ഡോക്ടറെ കാണണം | today | 10:00 | — |

---

## 2. The two halves, and the honest limit

**Half A — the parser.** Pure Dart. Sentence in, structured task out. This is
100% offline with no doubt at all, and it is the part the feature is really
about.

**Half B — turning speech into text.** Flutter cannot hear a microphone by
itself. There are only three honest options:

1. **Android's own on-device recogniser through a small method channel.**
   No new package. Our app still declares **no** `INTERNET` permission. We ask
   Android for the on-device recogniser (`createOnDeviceSpeechRecognizer` on
   API 33+, and `EXTRA_PREFER_OFFLINE = true` below that). It needs one new
   permission: `RECORD_AUDIO`.
   Caveat to be clear about: the recogniser is a separate app (usually Google
   Speech Services). We ask it to stay offline and we can prove our own app has
   no network permission, but we cannot audit that other app. If the device has
   no offline language pack, we report it and fall back to typing.
2. **A speech package** (`speech_to_text`). Rejected — it is not on the approved
   dependency list in `CLAUDE.md`.
3. **No microphone at all.** The sheet is a text box only; the user can still tap
   the keyboard's own mic key if they want. Fully offline with zero doubt, zero
   new permissions, and it works on Windows too.

**This plan builds the parser and the sheet first (works everywhere, no new
permission), and puts the Android recogniser behind an off-by-default setting.**
So a fresh install shows no microphone prompt and no behaviour change until the
user turns "Voice input" on in Settings. The manifest permission still has to be
declared for the feature to exist at all; the permissions screen will explain it
plainly.

**If you would rather not add `RECORD_AUDIO` at all, say so and I will drop
Half B and ship the parser plus the typed sheet only.**

---

## 3. Files to change

### New — parser (pure Dart, `core/`, no Flutter imports)

| File | What it holds |
|---|---|
| `lib/core/voice/voice_parse_result.dart` | Plain data class: title, date, time of day, target seconds, priority, the spans that were removed from the title, and a list of what was understood. |
| `lib/core/voice/voice_command_parser.dart` | The engine. Takes raw text plus today's date and a locale hint, returns a `VoiceParseResult`. |
| `lib/core/voice/voice_lexicon_en.dart` | English word lists: weekdays, `today` / `tomorrow` / `day after tomorrow`, `next <weekday>`, `in N days`, `at H[:MM] am/pm`, `half past`, `quarter past` / `quarter to`, `o clock`, spelled numbers one to sixty, duration units (`min`, `mins`, `minute`, `hour`, `hr`, `h`), priority words (`urgent`, `important`, `low priority`). |
| `lib/core/voice/voice_lexicon_ml.dart` | Malayalam word lists: `ഇന്ന്`, `നാളെ`, `മറ്റന്നാൾ`, weekdays `ഞായർ` / `തിങ്കൾ` / `ചൊവ്വ` / `ബുധൻ` / `വ്യാഴം` / `വെള്ളി` / `ശനി` with the `ആഴ്ച` suffix, `അടുത്ത` (next), `മണിക്ക്` (at o clock), the `യ്ക്ക്` / `ക്ക്` time suffix, the half-hour forms `ഒന്നര` to `പന്ത്രണ്ടര` (`ഏഴര` = 7:30), spelled numerals `ഒന്ന്` to `അറുപത്`, `മിനിറ്റ്`, `മണിക്കൂർ`, and `രാവിലെ` / `ഉച്ചയ്ക്ക്` / `വൈകുന്നേരം` / `രാത്രി` (morning / noon / evening / night) for am-pm resolution. |

Parser rules:

- Detect script per token (Malayalam block `U+0D00` to `U+0D7F`) so a mixed
  sentence still works; both lexicons are always tried.
- Run `nfcNormalize` on the input **before** matching, and again on the final
  title, exactly as rule 2 in `CLAUDE.md` requires.
- Take out the matched date, time, duration and priority spans, then squeeze
  spaces and trim leftover joining words to build the title.
- Never return an empty title — if everything was eaten, keep the original text.
- Never invent a date: no date words means today.
- A parsed date in the past is clamped to today (Day-Lock, rule 3) and the sheet
  says so.

### New — the sheet and its state

| File | What it holds |
|---|---|
| `lib/presentation/screens/daily_list/widgets/voice_command_sheet.dart` | The floating sheet: a big mic button (or a text box where there is no mic), a live text field holding the recognised or typed words, a preview of what was understood (title, date, time and target chips), an "Edit first" button and a "Create" button. |
| `lib/application/voice_capture_notifier.dart` | `StateNotifier` holding `idle` / `listening` / `done` / `error`, the current text, and the parse result. Talks to the recogniser channel; never touches a DAO. |
| `lib/application/voice_capture_state.dart` (+ generated `.freezed.dart`) | Immutable state class. |
| `lib/core/platform/speech_channel.dart` | Dart side of the recogniser channel. Methods: `isAvailable()`, `hasPermission()`, `requestPermission()`, `start(localeTag)`, `stop()`, plus a stream of partial and final results. Reports "not supported" on Windows, exactly like `screen_wake_channel.dart` does. |

### Changed

| File | Change |
|---|---|
| `lib/presentation/screens/daily_list/daily_list_screen.dart` | Turn the single add FAB into a small mic FAB above the existing add FAB (hidden on past days, hidden when the setting is off). It opens the sheet. |
| `lib/app.dart` | `/todo/new` gains optional query params `title`, `time`, `target` and `priority` so the sheet can hand a filled-in draft over. |
| `lib/presentation/screens/create_edit_todo/create_edit_todo_screen.dart` | Accept the new prefill params and seed the controllers on first build. Existing validation, the uniqueness check and Day-Lock all stay as they are. |
| `lib/core/constants/app_routes.dart` | Add a `createTodoPath(...)` builder so nothing hand-builds query strings. |
| `lib/application/providers.dart` | Add `voiceCaptureProvider` and `speechChannelProvider`. |
| `lib/application/task_defaults_notifier.dart` (or a small new settings notifier) | Add the `voiceInputEnabled` flag, off by default, stored in `shared_preferences` like the other flags. |
| `lib/presentation/screens/settings/task_defaults/` | New "Voice input" tile: off by default, with a one-line note that it uses the phone's own offline recogniser and needs the microphone. |
| `lib/l10n/app_en.arb`, `lib/l10n/app_ml.arb` | All new user-visible strings, in both languages. |
| `lib/presentation/screens/settings/permissions_screen.dart` | New entry under explicit permissions: microphone — why it is asked, that it is only asked when the user turns voice input on, and that no audio is stored or sent anywhere. |
| `android/app/src/main/AndroidManifest.xml` | Add the `RECORD_AUDIO` permission and a `<queries>` entry for `android.speech.RecognitionService` (needed on API 30+ to see the recogniser). **No network permission is added.** |
| `android/app/src/main/kotlin/in/sreerajp/sreerajp_todo/MainActivity.kt` | New `in.sreerajp.todo/speech` channel: availability check, runtime permission request, start and stop of `SpeechRecognizer` with `EXTRA_PREFER_OFFLINE`, results pushed back over an `EventChannel`. Errors get named codes and are never thrown raw. |
| `docs/unique_features_and_improvements.md` | Mark 3.2 as done (or partly done if Half B is dropped) and update the count line. |
| `docs/features.md`, `docs/architecture.md`, `docs/security.md`, `docs/dependencies.md` | Describe the feature, the new layer files, the microphone permission and the offline reasoning. |
| `AGENTS.md`, `CLAUDE.md` | Only if the permission list needs a line. The offline rule itself does not change. |

### New tests

| File | Covers |
|---|---|
| `test/core/voice/voice_command_parser_en_test.dart` | English dates, times, durations, priority, title clean-up, past-date clamping, the empty-title guard. |
| `test/core/voice/voice_command_parser_ml_test.dart` | Malayalam numerals (`ഏഴര`, `പത്തു മണിക്ക്`), `അടുത്ത തിങ്കളാഴ്ച`, `45 മിനിറ്റ്`, mixed English and Malayalam sentences, and different NFC forms of the same word. |
| `test/application/voice_capture_notifier_test.dart` | State moves, error paths, and the channel-not-supported case. |
| `test/presentation/voice_command_sheet_test.dart` | Widget test with a fake channel: typing a sentence shows the right preview chips, and "Create" hands the right params on. |

No DAO, repository, migration or database change. Nothing about Day-Lock,
terminal status, open segments or title uniqueness moves — the sheet only ever
opens the normal create screen, which already enforces all of them.

---

## 4. Order of work

1. Parser, lexicons and their tests (the biggest piece, pure Dart, no risk).
2. State notifier and provider wiring.
3. The sheet, typing only, wired to the create-screen prefill.
4. Route and create-screen prefill params.
5. Settings flag, off by default.
6. Android channel, manifest, permissions screen text.
7. Localisation strings in both `.arb` files.
8. Docs.
9. `dart format`, `flutter analyze` (must be zero), `flutter test`.

---

## 5. Risks

- **Recogniser quality for Malayalam** varies a lot by device and by which
  offline packs are installed. The typed path always works, so the feature is
  never dead.
- **Regex creep.** Kept in check by putting every word list in the two lexicon
  files and keeping the parser itself free of hard-coded words.
- **`RECORD_AUDIO` reads badly** in a privacy-first app. That is why the flag is
  off by default and the permissions screen explains it in full.

---

## 6. Question for you

Do you approve this plan? And on Half B specifically, please pick one:

- **A** — build both halves as written (parser, typed sheet, and the optional
  Android microphone behind an off-by-default setting; adds `RECORD_AUDIO`).
- **B** — parser and typed sheet only. No new permission, no Kotlin change, and
  it works on Windows too. The user can still use the keyboard's own mic key.
