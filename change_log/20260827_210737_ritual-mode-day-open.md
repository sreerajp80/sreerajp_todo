# Change log — Ritual Mode, the guided day open (feature 4.9)

**Date:** 2026-08-27
**Implements:** [plans/20260827_202359_ritual-mode-day-open.md](../plans/20260827_202359_ritual-mode-day-open.md)

Ports Ritual Mode from SreerajP Journal Vault and reworks it for a task and
time tracker. The journal flow ends by opening today's entry; this one ends by
settling the day.

**Off by default.** A fresh install behaves exactly as it did before.

---

## What was built

### The flow (`/ritual`)

Breathe → Reflect on one card → Settle the day → Begin. The middle two steps can
be switched off, so the flow is built from whatever is turned on rather than
being a fixed four. Every step can be skipped.

- **Breathe:** three rhythms (Box 4-4-4-4, Relaxing 4-7-8, Calm 4-4), 1 to 5
  breaths, optional buzz at each phase change. A plain `AnimationController` and
  a one-second `Timer`. No package, no asset, no sound.
- **Reflect:** one card from a 50-card deck, with a Hard / Revision / Easy
  rating that decides when it returns, and a "Make this today's intention"
  button that writes the card title through `DailyReflectionRepository`, so the
  Morning Intention Card (4.3) then shows the same words.
- **Settle:** carry over what is unfinished from before, through the same
  `CopyTodos` use case the carry-over sheet uses, then mark up to three of
  today's tasks as the day's focus, stored as the existing `TodoPriority.high`.
- **Begin:** a one-line summary, then today's list.

### Around it

- **Ritual Deck browser** (`/ritual/deck`): all 50 cards, filterable by theme,
  showing new / due / days away. Read-only.
- **Settings** (`/settings/ritual`): the on/off switch, automatic opening,
  rhythm, breath count, haptic, the two optional steps, evening close and its
  hour, the deck browser, "Reset card reviews", and "Run the ritual now".
- **Evening close:** once a day from a chosen hour (default 20:00), the day list
  offers the existing `EveningReflectionModal`. Nothing new was built for it.
- **Day list app bar:** a Ritual mode button, shown only on today and only when
  the feature is on.
- **Features screen:** a new "Ritual Mode" category with three entries.

---

## The deck, and how it got here

The deck is 50 Sanathana Dharma cards, each with a title, a reflection question,
a grounding quote and its attribution, in English and Malayalam. In the Journal
app that text sits inline in Dart. Here it does not: all 400 entries live in
`lib/l10n/app_en.arb` and `lib/l10n/app_ml.arb`, so the project stays uniform
and every user-visible string is in one place.

`tool/ritual_deck_to_arb.dart` did the conversion. It reads a source deck file
and writes four things:

| Output                    | What it is                                              |
| ------------------------- | ------------------------------------------------------- |
| `ritual_deck_en.arb.part` | 200 English entries, each with an `@` description block |
| `ritual_deck_ml.arb.part` | the matching 200 Malayalam entries                      |
| `ritual_card_deck.part`   | the const card list for the deck file                   |
| `ritual_card_text.dart`   | the id-to-strings resolver                              |

So no card text — no Malayalam character — was retyped, and the resolver cannot
drift from the ARB keys because both come from the same run. The tool edits
nothing in the project, only writes into an output directory, so a bad run
cannot damage the ARB files. It reported no missing text: all 50 cards are
complete in both languages.

The resolver is generated because the ARB getters are generated methods: a
card's text cannot be looked up by key at run time, so the 50 cards need an
explicit switch.

After conversion `lib/domain/entities/ritual_card.dart` holds no text at all —
only card id, number and theme. The Journal app's `localizedTitle(...)` and
`localizedPrompt(...)` helpers were dropped rather than ported, because
`AppLocalizations` now does that job.

---

## Two spaced repetition engines, kept apart

The app already had one (feature 3.5, the Mastery Deck) for real tasks in the
`spaced_repetition_items` table. The Ritual Deck's is separate and smaller: it
schedules reflection cards entirely in `SharedPreferences` and never touches the
database. They live at different routes with different names — `/mastery-deck`
and `/ritual/deck` — so neither has to explain the other.

**One rule was deliberately changed from the Journal app.** There, among cards
that are due, never-seen cards come first. That was carried over at first and a
test caught what it means here: rating a card "Hard" promises it comes back
tomorrow, and with unseen cards going first that promise could not be kept until
all fifty had been seen. So in this app a card that is due back beats a card
never seen. The reason is written into the code at `RitualService.cardForToday`.

---

## Rules kept

- **No new package.** `pubspec.yaml` is untouched.
- **No database migration.** `kDatabaseVersion` is unchanged. The ritual writes
  only through paths that already existed: `daily_intentions` for the intention,
  and the todo repository for carry-over and priority.
- **No direct DB access from widgets.** Everything goes through Riverpod
  providers in `lib/application/providers.dart`.
- **Day lock, title uniqueness, NFC.** Untouched: the ritual reuses the existing
  write paths rather than adding its own, so all three are still applied exactly
  once, in one place.
- **Strings.** Every user-visible string, cards included, is in the ARB files.
- **Nothing new in backups.** All ritual state is device preferences, so it is
  not in any backup, export or sync payload.

---

## Two departures from the plan, and why

1. **`RitualSettings` is a plain `@immutable` class, not `@freezed`.** The plan
   said freezed. Every other settings group in this app — `TaskDefaults`,
   `TimeTrackingSettings`, `AppearanceState` — is a plain immutable class with a
   hand-written `copyWith`. Matching the neighbours won over matching the plan.

2. **`carry_over_sheet.dart` did not need to be taken apart.** The plan expected
   to lift the candidate query and the carry action out of it. In the event
   `CarryOverSheet.findCandidates` was already a static helper and the copy runs
   through `copyTodosProvider`, so the settle step calls both as they are. The
   file is unchanged.

---

## Files

### New

| File                                                                   | Purpose                                                                                      |
| ---------------------------------------------------------------------- | -------------------------------------------------------------------------------------------- |
| `lib/core/utils/ritual_rules.dart`                                     | Breathing rhythms and phases, breath and hour limits, the three-task focus limit. Pure Dart. |
| `lib/domain/entities/ritual_card.dart`                                 | The 50-card deck as identities only: id, number, theme.                                      |
| `lib/domain/entities/ritual_review_state.dart`                         | The card rating and its schedule.                                                            |
| `lib/data/services/ritual_service.dart`                                | Which card comes next, and when a rated card returns. Preference-backed.                     |
| `lib/application/ritual_notifier.dart`                                 | Every ritual preference, plus the once-a-day gates.                                          |
| `lib/presentation/screens/ritual/ritual_screen.dart`                   | The four-step shell.                                                                         |
| `lib/presentation/screens/ritual/ritual_card_text.dart`                | Generated id-to-strings resolver.                                                            |
| `lib/presentation/screens/ritual/ritual_deck_screen.dart`              | The deck browser.                                                                            |
| `lib/presentation/screens/ritual/widgets/breathing_orb.dart`           | The breathing circle.                                                                        |
| `lib/presentation/screens/ritual/widgets/ritual_card_step.dart`        | Step 2.                                                                                      |
| `lib/presentation/screens/ritual/widgets/ritual_settle_step.dart`      | Step 3.                                                                                      |
| `lib/presentation/screens/ritual/widgets/ritual_theme_style.dart`      | Icon, tint and name for each deck theme.                                                     |
| `lib/presentation/screens/settings/ritual/ritual_settings_screen.dart` | The settings page.                                                                           |
| `tool/ritual_deck_to_arb.dart`                                         | The one-off deck converter, kept as the record of how it was done.                           |
| `test/application/ritual_notifier_test.dart`                           | Defaults, saving, and both once-a-day gates.                                                 |
| `test/data/ritual_service_test.dart`                                   | The deck itself, card picking, rating intervals, stored state.                               |
| `test/presentation/ritual_screen_test.dart`                            | The flow, skipping, the card step, the deck browser, the rhythms.                            |

### Changed

| File                                                         | Change                                                                                                                                                                                                                                                           |
| ------------------------------------------------------------ | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `lib/app.dart`                                               | Three new routes; the router is now built by `_createRouter(initialLocation)` and `TodoApp` takes a first screen, so the ritual can be the first thing shown. Built once and kept, so a theme or language change never throws the user back to the first screen. |
| `lib/main.dart`                                              | Chooses the first screen after the recurring and mastery-deck generators have run, so the settle step sees a complete list for today.                                                                                                                            |
| `lib/core/constants/app_routes.dart`                         | `ritual`, `ritualDeck`, `ritualSettings`.                                                                                                                                                                                                                        |
| `lib/application/providers.dart`                             | `ritualProvider` and `ritualServiceProvider`.                                                                                                                                                                                                                    |
| `lib/presentation/screens/settings/settings_screen.dart`     | The "Ritual mode" row.                                                                                                                                                                                                                                           |
| `lib/presentation/screens/daily_list/daily_list_screen.dart` | The app-bar ritual button and the evening close offer.                                                                                                                                                                                                           |
| `lib/presentation/screens/features/features_screen.dart`     | A "Ritual Mode" category.                                                                                                                                                                                                                                        |
| `lib/l10n/app_en.arb`, `lib/l10n/app_ml.arb`                 | ~90 chrome strings and the 400 deck entries.                                                                                                                                                                                                                     |
| `test/presentation/settings_screen_test.dart`                | Now expects 11 settings cards, and checks the new row.                                                                                                                                                                                                           |
| `docs/unique_features_and_improvements.md`                   | Section 4.9, and the status summary (now 14 done).                                                                                                                                                                                                               |
| `docs/features.md`                                           | Section 8.1, and three rows in the navigation map.                                                                                                                                                                                                               |

---

## Verification

- `flutter gen-l10n` — regenerated. The 16 untranslated messages it reports are
  the pre-existing data-handoff gaps, none of them from this change.
- `dart format lib/ test/ tool/` — clean.
- `flutter analyze` — **0 issues**.
- `flutter test` — **598 passed**, including the 37 new ones.
- `flutter build apk --flavor dev --debug` — built, so the changed entry points
  compile as well as analyse.
- English and Malayalam checked key for key: every ritual key exists in both
  files.
