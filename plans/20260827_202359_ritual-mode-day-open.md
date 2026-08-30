# Ritual Mode — a guided day open for SreerajP ToDo (feature 4.9)

**Status:** completed

Ports Ritual Mode from SreerajP Journal Vault (its plan
`20260824_111500_c9_ritual_mode.md`) and reworks it for a ToDo and
time-tracker instead of a journal.

---

## 1. What already exists in the Journal app

I read the shipped code, not just the idea note. It is larger than the note
said:

| Part | File in Journal Vault | Size |
|---|---|---|
| 50-card Sanathana Dharma deck, English + Malayalam inline | `lib/features/ritual/domain/ritual_card.dart` | ~1030 lines |
| Card-level spaced repetition (Hard 1d / Revision 3d / Easy 7×level) | `lib/features/ritual/domain/spaced_repetition.dart` | ~110 lines |
| Service: card pick, review state, prefs | `lib/features/ritual/services/ritual_service.dart` | ~330 lines |
| Animated breathing orb, 3 techniques | `lib/features/ritual/presentation/widgets/breathing_orb_widget.dart` | ~340 lines |
| 3-step flow screen | `lib/features/ritual/presentation/ritual_screen.dart` | ~670 lines |
| Deck browser | `lib/features/ritual/presentation/ritual_deck_screen.dart` | ~460 lines |
| User-made cards (stored in the journal DB) | `create_ritual_card_screen.dart` + a drift table | ~380 lines |

The flow there is **Breathe -> Reflect (card + Hard/Revision/Easy) -> Write**,
and it ends by opening today's journal entry.

Three breathing techniques: Box 4-4-4-4, Relaxing 4-7-8, Calm 4-4. Cycles 1 to
5, default 2. Card review state and all preferences live in
`SharedPreferences`, not in the database.

---

## 2. The rework for ToDos

A ToDo app has no "entry" to open. It has a **day** that either starts clear or
starts with yesterday's mess. So step 3 changes, and only step 3:

**Breathe -> Reflect on one card -> Settle the day -> Begin.**

| Step | Journal Vault | SreerajP ToDo |
|---|---|---|
| 1 | Breathing orb | **Same, ported unchanged** |
| 2 | Card + Hard / Revision / Easy | **Same, ported unchanged**, plus "Make this today's intention" |
| 3 | Open today's journal entry | **Settle the day** — carry over yesterday's unfinished tasks, pick up to three focus tasks |
| 4 | — | **Begin** — short summary, then today's list |

Everything except step 3 is a port, so most of this change is moving proven
code across, not writing new code.

### Step 1 — Breathe

`breathing_orb_widget.dart`, `BreathTechnique` and its extension port as they
are. Only the phase labels change: they are hard-coded English there
("Inhale", "Hold gently at the top...") and must move into
`lib/l10n/app_en.arb` and `app_ml.arb` here, because this app is bilingual in
its chrome.

### Step 2 — One card

The whole 50-card deck and the card SRS port unchanged. The card shown is
picked by the same rule as the journal app: cards due for review first, then
never-seen cards by number, then the card reviewed longest ago. Rating it
Hard / Revision / Easy schedules when it comes back.

One addition for ToDos: a **"Make this today's intention"** button. It writes
the card title into the existing `daily_intentions` row for today, through the
existing intention write path (which already NFC-normalizes). So the Morning
Intention Card on the day list (feature 4.3) then shows the same words the
ritual showed. One source of truth, no new table, and 4.3 stops being a
separate loose thread.

### Step 3 — Settle the day (the only genuinely new screen)

Two short lists:

- **Yesterday's unfinished tasks**, with tick boxes and a "Carry over" button.
  This calls the existing `CarryOverSheet` logic, not a copy of it.
- **Today's tasks**, including recurring and mastery-deck tasks already
  generated at startup. The user taps up to three to mark as today's focus.
  Focus is stored as the existing `TodoPriority.high` — no new column. A fourth
  tap shows a gentle note that three is the limit.

Both lists can be empty, and the step can be skipped.

### Step 4 — Begin

One line of summary ("3 carried over, 3 in focus") and a "Begin the day" button
that goes to today's list. The ritual is marked done for that date and will not
open again until tomorrow.

### Evening close (optional, off by default)

If turned on, opening the app after the set hour (default 20:00), once a day,
offers the **existing** `EveningReflectionModal` from 4.3. Nothing new is built
for it.

---

## 3. Two spaced repetition engines, kept apart

This app already has an SRS engine (feature 3.5, the Mastery Deck) with a
`spaced_repetition_items` table for real tasks. The ritual card SRS is a
**separate, smaller thing**: it schedules reflection cards, lives entirely in
`SharedPreferences`, and never touches the todos table.

They must not be merged. Mixing "recall this reflection card" into the task
mastery deck would make both harder to read. To keep the two clearly apart in
the UI:

- Task mastery deck stays at `/mastery-deck`, named "Mastery Deck".
- Ritual card deck lives at `/ritual/deck`, named "Ritual Deck".

---

## 4. Settings

New page `Settings -> Ritual mode` at `/settings/ritual`:

| Setting | Values | Default |
|---|---|---|
| Ritual mode | on / off | **off** |
| Open the ritual on the first launch of a day | on / off | on (only matters when ritual mode is on) |
| Breathing technique | Box 4-4-4-4 / Relaxing 4-7-8 / Calm 4-4 | Box |
| Breath cycles | 1 to 5 | 2 |
| Haptic at each phase change | on / off | off |
| Card step | on / off | on |
| Settle step | on / off | on |
| Evening close | on / off | off |
| Evening close from | hour picker | 20:00 |
| Browse the Ritual Deck | opens `/ritual/deck` | — |
| Reset all card reviews | button, asks first | — |
| Run the ritual now | button | — |

All of it is device UI state in `SharedPreferences`, through a `RitualNotifier`
built the same way as `AppearanceNotifier`. It stays out of the database and out
of backups.

---

## 5. Rules this must respect

- **No new packages.** The orb is a plain `AnimationController` plus a `Timer`;
  haptics use `HapticFeedback`, as focus pulse (4.6) already does. The offline
  guarantee is untouched.
- **No database migration.** `kDatabaseVersion` stays where it is. The ritual
  writes only through paths that already exist: `daily_intentions` (step 2) and
  the todo repository (step 3).
- **Day lock.** The ritual only runs for today. Carry-over and every task write
  already go through the repository, so day lock and every other rule still
  applies.
- **No direct DB access from widgets.** Ritual widgets read and write only
  through Riverpod providers in `lib/application/providers.dart`.
- **Strings, including the deck. No exception to rule 10.** All UI chrome *and*
  all 50 cards live in `lib/l10n/app_en.arb` and `lib/l10n/app_ml.arb`. The
  Journal app keeps its card text inline in Dart; this app will not, so the
  project stays uniform and every user-visible string is in one place.

  That is about 400 entries (50 cards x 4 fields x 2 languages). **Nobody types
  them.** A one-off script, `tool/ritual_deck_to_arb.dart`, reads the ported
  Dart deck and prints ready-made ARB blocks for both files:

  - Key shape: `ritualCardSd01Title`, `ritualCardSd01Prompt`,
    `ritualCardSd01Quote`, `ritualCardSd01QuoteAuthor`.
  - English from `title` / `prompt` / `quote` / `quoteAuthor`, Malayalam from
    `titleMl` / `promptMl` / `quoteMl` / `quoteAuthorMl`.
  - Every English entry gets a `@ritualCardSd01Title` description block, as the
    rest of `app_en.arb` does.
  - A card with no Malayalam text for a field is reported by name, so the gap is
    seen and filled rather than silently falling back to English.

  So no Malayalam character is ever retyped, and the script is run once and kept
  in `tool/` as the record of how the deck was converted.

- **After conversion the deck file holds no text.** `ritual_card.dart` keeps
  only card id, number and theme. The screen resolves text through
  `AppLocalizations`, so the `localizedTitle(...)` / `localizedPrompt(...)`
  helpers from the Journal app are dropped, not ported.
- **Startup order.** The ritual gate runs *after* recurring and spaced
  repetition task generation, so step 3 shows a complete list for today.

---

## 6. Files

### New — ported from Journal Vault

| File | Ported from | Change on the way |
|---|---|---|
| `lib/domain/entities/ritual_card.dart` | `features/ritual/domain/ritual_card.dart` | All card text moves to ARB (section 5); file keeps id, number, theme, and the theme icon/colour table. Drops `isUserCreated` / `dbId` (section 8) and the `localized*` helpers |
| `tool/ritual_deck_to_arb.dart` | new, one-off | Reads the ported deck and prints the ARB blocks for both language files |
| `lib/domain/entities/ritual_review_state.dart` | `features/ritual/domain/spaced_repetition.dart` | Import paths only |
| `lib/data/services/ritual_service.dart` | `features/ritual/services/ritual_service.dart` | Drop the user-card DAO half; keep card pick, review state, prefs |
| `lib/presentation/screens/ritual/widgets/breathing_orb.dart` | `breathing_orb_widget.dart` | Phase labels move to ARB |
| `lib/presentation/screens/ritual/ritual_deck_screen.dart` | `ritual_deck_screen.dart` | Renamed "Ritual Deck", no create/edit buttons |

### New — written for this app

| File | Purpose |
|---|---|
| `lib/application/ritual_notifier.dart` | Settings and "last completed date", backed by `SharedPreferences` |
| `lib/application/ritual_state.dart` | `@freezed` state model |
| `lib/presentation/screens/ritual/ritual_screen.dart` | The four-step shell |
| `lib/presentation/screens/ritual/widgets/breath_step.dart` | Step 1 wrapper |
| `lib/presentation/screens/ritual/widgets/card_step.dart` | Step 2, card + rating + "make this today's intention" |
| `lib/presentation/screens/ritual/widgets/settle_step.dart` | Step 3, the new part |
| `lib/presentation/screens/ritual/widgets/begin_step.dart` | Step 4 |
| `lib/presentation/screens/settings/ritual/ritual_settings_screen.dart` | Settings page |
| `test/data/ritual_service_test.dart` | Card pick order, rating intervals, reset |
| `test/application/ritual_notifier_test.dart` | Gate: once a day, off when disabled, never a past date |
| `test/presentation/ritual_screen_test.dart` | Skip works at every step; three-task focus limit |

### Changed

| File | Change |
|---|---|
| `lib/core/constants/app_routes.dart` | Add `ritual` (`/ritual`), `ritualDeck` (`/ritual/deck`), `ritualSettings` (`/settings/ritual`) |
| `lib/app.dart` | Register the three routes |
| `lib/application/providers.dart` | Expose `ritualServiceProvider`, `ritualProvider`, `ritualDueProvider` |
| `lib/main.dart` | After task generation, decide whether the first route is `/ritual` |
| `lib/presentation/screens/settings/settings_screen.dart` | Add the "Ritual mode" row |
| `lib/presentation/screens/daily_list/daily_list_screen.dart` | Small app-bar action to run the ritual by hand |
| `lib/presentation/screens/daily_list/widgets/carry_over_sheet.dart` | Lift the candidate query and the carry action out so the ritual can call them without showing the sheet |
| `lib/presentation/screens/features/...` | Add a Ritual Mode entry to the features screen |
| `lib/l10n/app_en.arb`, `lib/l10n/app_ml.arb` | All chrome strings |
| `docs/unique_features_and_improvements.md` | Add 4.9 and a roadmap row |
| `docs/features.md` | Document the ritual and its settings |

---

## 7. Effort

Medium, and mostly assembly, because roughly 1,900 of the ~2,500 lines are a
straight port. Rough shape: port and re-wire about 35%, the new settle step
about 20%, settings page about 15%, deck-to-ARB conversion about 10%, remaining
strings, docs and tests about 20%.

The ARB conversion is scripted, so it is a short job, not the day of typing it
would be by hand. The one manual part is reading the generated `app_ml.arb`
block once to confirm nothing came out empty or mis-paired.

---

## 8. Deliberately left out of v1

- **User-created cards.** The Journal app stores them in its database. Doing the
  same here means a schema migration, a DAO, tests, and a place in backup,
  AirQR and P2P sync payloads. That is a feature of its own. v1 ships the 50
  curated cards read-only; the ported `RitualCard` keeps its shape so user cards
  can be added later without touching the deck.
- **Merging the two SRS engines.** See section 3.
- **Sound.** Silence and optional haptics only.
- **Streaks or badges.** A ritual that shames you for missing a day is not a
  ritual.

---

## 9. Done when

- `flutter analyze` reports 0 issues.
- `flutter test` passes, including the three new test files.
- Ritual off by default; a fresh install behaves exactly as it does today.
- With it on: it opens once per day, every step is skippable, rating a card
  changes when that card next appears, and "Make this today's intention" makes
  the Morning Intention Card show the same words.
- No new package in `pubspec.yaml`; `kDatabaseVersion` unchanged.
- No user-visible string, card text included, is left in a `.dart` file. All 50
  cards read correctly with the app set to English and again with it set to
  Malayalam.
