# Update the docs/guidelines submodule

**Status:** completed

## What the issue is

The `docs/guidelines` submodule (shared Flutter guidelines) points at commit
`3f1aa0b`. The upstream `master` branch has 2 newer commits (now at
`519e7f3`), with 30 files changed. Main updates: a Flutter 3.47 toolchain note,
"latest stable, not pinned versions" guidance, guidelines made generic and
multi-platform, a new Sanskrit/Malayalam language pack, a new platform store
readiness guide, and a rewritten engineering standard.

## Plan for the fix

1. In `docs/guidelines`, check out `origin/master` (`519e7f3`).
2. Record the new submodule commit in the main repository.
3. Do not change any app code in this change. If the new guidelines ask for
   app changes (for example a Flutter version bump), list them for a separate
   plan.
4. Write a change log.

## Files to be changed

- `docs/guidelines` (submodule pointer only)
- `change_log/<timestamp>_update_guidelines_submodule.md` (new)
