# Fix swapped times in the target progress label

Implements plan: `plans/20260928_102935_fix_target_progress_label_order.md`

## What was wrong

On a task tile with a target time, the label showed the target time first and the tracked
time second (for example "00:30:00 of 00:29:00"). The tile passed the two values to
`targetProgressLabel(target, tracked)` in the wrong order. This affected all three
languages.

## What changed

- `lib/presentation/screens/daily_list/widgets/todo_list_tile.dart` — now passes the
  target time first and the tracked time second, matching the generated method.
- `lib/l10n/app_en.arb` — wording is now `{tracked} out of {target}`. The `@` description
  now explains both placeholders.
- `lib/l10n/app_ml.arb` — wording is now `ആകെ {target}-ൽ {tracked}`.
- `lib/l10n/app_sa.arb` — wording is now `आहत्य {target} मध्ये {tracked}`.
- `lib/l10n/app_localizations_*.dart` — regenerated with `flutter gen-l10n`.
- `test/presentation/todo_list_tile_test.dart` — the fake time segment repository can now
  return segments. New test: a task with a 30-minute target and 29 minutes tracked shows
  "00:29:00 out of 00:30:00".

Example result (29 minutes tracked, 30-minute target):

| Lang | Shows as |
|------|----------|
| en | 00:29:00 out of 00:30:00 |
| ml | ആകെ 00:30:00-ൽ 00:29:00 |
| sa | आहत्य 00:30:00 मध्ये 00:29:00 |

## Checks

- `flutter analyze`: no issues.
- `flutter test`: all 834 tests pass.
