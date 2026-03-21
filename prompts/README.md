# SreerajP ToDo — Implementation Prompts

These prompt files are designed to be given to an AI assistant to implement each phase of the app. Each prompt is **self-contained** with full context, constraints, task breakdowns, test requirements, and deliverable checklists.

## Execution Order

Phases must be executed in order — each depends on the previous:

| # | Prompt File | Phase | Description | Est. Duration |
|---|-------------|-------|-------------|---------------|
| 1 | [phase1_project_setup.md](phase1_project_setup.md) | Phase 1 | Project scaffold, dependencies, routing, theming, folder structure, offline enforcement | 2.5–3.5 days |
| 2 | [phase2_database_layer.md](phase2_database_layer.md) | Phase 2 | Encrypted SQLite, models (freezed), DAOs, query service, repositories, unit tests | 3–4 days |
| 3 | [phase3_core_todo_features.md](phase3_core_todo_features.md) | Phase 3 | Daily list, CRUD, autocomplete, status changes, undo, multi-select, search, day lock | 5.5–6.5 days |
| 4 | [phase3b_recurring_tasks.md](phase3b_recurring_tasks.md) | Phase 3B | RRULE recurrence rules, auto-generation, management UI, editor | 3–4 days |
| 5 | [phase4_time_tracking.md](phase4_time_tracking.md) | Phase 4 | Start/stop timers, live display, manual entry, orphan repair, segment detail screen | 4–5 days |
| 6 | [phase5_copy_port.md](phase5_copy_port.md) | Phase 5 | Copy wizard, port workflow, conflict detection, visual indicators | 2–3 days |
| 7 | [phase5b_backup_restore.md](phase5b_backup_restore.md) | Phase 5B | Encrypted backup export/import, passphrase management, backup list screen | 2–3 days |
| 8 | [phase6_statistics.md](phase6_statistics.md) | Phase 6 | Dashboard with charts, paginated tables, date range filter, productive vs dropped time | 3.5–4.5 days |
| 9 | [phase7_ui_polish_unicode.md](phase7_ui_polish_unicode.md) | Phase 7 | Unicode audit, responsive layout, theme polish, accessibility, app icon, splash screen | 2.5–3.5 days |
| 10 | [phase8_testing.md](phase8_testing.md) | Phase 8 | Coverage audit, integration tests, performance profiling | 2–3 days |
| 11 | [phase9_build_release.md](phase9_build_release.md) | Phase 9 | Signed builds, offline verification, release packaging | 1–2 days |

**Total estimated: 31–42 days**

## How to Use These Prompts

1. **Start each session** by telling the AI:
   > "Read `CLAUDE.md` and the docs listed in the Pre-Requisites of `prompts/phaseN_xxx.md`, then follow the prompt."

2. **One phase per session** (or set of sessions) — complete it before moving to the next.

3. **After each phase**, verify the deliverables checklist at the bottom of the prompt file.

4. **Run tests** after each phase:
   ```powershell
   flutter test
   flutter analyze
   ```

## Key References

- **`CLAUDE.md`** — The single source of truth for all project rules and constraints. Every prompt references it.
- **`flutter_todo_app_plan.md`** — The full project plan with detailed specifications.
- **`docs/`** — Engineering standards, architecture, security, and release process. Each prompt lists the specific docs relevant to that phase, but the following apply universally:

| Document | Applies To | Key Sections |
|----------|-----------|-------------|
| `docs/flutter_project_engineering_standard.md` | **All phases** | Coding standards (§8), testing standard (§9), AI assistant instructions (§13), Definition of Done (§14) |
| `docs/architecture.md` | **All phases** | Layer boundaries, data flow, provider types, route table, test layout |
| `docs/security.md` | Phases handling encryption or sensitive data (2, 5B, 7, 8, 9) | Encryption design, logging policy, never-log rules, platform security controls |
| `docs/release_process.md` | Phase 9 (and final verification of any phase) | Release checklist, signing, offline enforcement |

## Non-Negotiable Constraints (apply to ALL phases)

1. **Fully offline** — zero internet access, no networking packages, no INTERNET permission.
2. **Unicode first** — NFC normalisation, RTL support, all scripts.
3. **Day lock** — past-date items are read-only, enforced in repository layer.
4. **No direct DB access from widgets** — always go through Repository (or UseCase → Repository).
5. **All strings in `app_strings.dart`** — no hardcoded user-visible strings in widgets.
6. **Tests alongside features** — every DAO method must have a test.
