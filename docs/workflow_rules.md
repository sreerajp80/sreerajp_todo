# Workflow Rules — SreerajP ToDo

This document defines the plan-before-changing, explicit user approval gate, and log-after-changing workflow rules for SreerajP ToDo.

Read [AGENTS.md](../AGENTS.md) and [CLAUDE.md](../CLAUDE.md) first before modifying code or architecture.

---

## 1. Scope

These workflow rules apply to all development, feature additions, refactoring, and documentation updates within `SreerajP ToDo`.

---

## 2. Plan Before Changing

- For non-trivial features, architectural modifications, database schema migrations, or security changes, create an implementation plan first in `plans/`.
- Ensure all plans are stored as snake_case Markdown files with date-timestamp prefixes (`YYYYMMDD_HHMMSS_description.md`).
- **Relative paths & privacy only:** All `plans/` and `change_log/` files MUST use relative repository paths only (never absolute system paths like `C:\...` or `l:\...`). They MUST NOT contain any **local system details** — OS user name, computer/host name, home or drive-letter paths, network share names, LAN/internal IP addresses, local server URLs with ports, device serial numbers, personal email addresses — or any secret (API keys, tokens, passwords, keystore passphrases, credentials, PII). Write them as if a stranger will read them; nothing should reveal the machine they came from.

---

## 3. Explicit User Approval Gate

- Present proposed implementation plans, architectural decisions, or breaking changes to the user for explicit approval before proceeding with execution.
- If unexpected complexities or schema breaks arise during execution, halt and update the implementation plan before proceeding.

---

## 4. Log After Changing

- Record completed implementation milestones and key decisions in `change_log/` named `YYYYMMDD_HHMMSS_description.md` referencing its plan.
- Ensure change logs follow the same relative-paths-only and zero-local-system-details policy.
- Maintain `docs/features.md` as the authoritative, up-to-date reference for implemented features.

---

## 5. Verification & Definition of Done

Before declaring any change complete:
1. Run `flutter analyze` and confirm zero static analysis warnings or errors.
2. Run `dart format lib/ test/ integration_test/` and ensure all files are formatted.
3. Run `flutter test` and ensure all unit and widget tests pass clean.
4. Execute the offline dependency audit command to verify zero network dependencies:
   ```powershell
   flutter pub deps --json | Select-String -Pattern "http|socket|firebase|supabase|sentry|crashlytics|analytics"
   ```
