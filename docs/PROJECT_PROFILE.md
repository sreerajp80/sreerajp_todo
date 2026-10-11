# Project Profile — SreerajP ToDo

This file records the choices the shared guidelines leave open for SreerajP ToDo: identity,
platforms, stores, languages and About options. Read it before writing code. Every rule that
depends on a platform, store or language applies **only when this file declares it**.

Read [CLAUDE.md](../CLAUDE.md) and [AGENTS.md](../AGENTS.md) first. This file is filled in from
[guidelines/PROJECT_PROFILE_TEMPLATE.md](guidelines/PROJECT_PROFILE_TEMPLATE.md).

> **Privacy:** this file is committed. Put only public information here. Never put passwords,
> keys or keystore details here.

---

## 1. Identity

| Item | Value |
|---|---|
| App display name | `SreerajP ToDo` |
| Short description (one line) | `Personal offline-first daily ToDo and time-tracker.` |
| Organization / publisher | `Sreeraj P` |
| Reverse-DNS app id | `in.sreerajp.sreerajp_todo` — permanent once published |
| Dart package name (`pubspec.yaml` `name`) | `sreerajp_todo` |
| Public support contact | `to be decided before a public store release` |
| Website | `none` |
| Privacy policy URL | `to be decided before a public store release` |
| Copyright line | `© 2026 Sreeraj P` |
| License of the app's own code | `MIT` (see `LICENSE`) |

---

## 2. Applicability profiles

- [x] `Core Baseline` (always)
- [x] `Production App Extension` — release builds are signed, hardened and shipped to devices
- [x] `Sensitive Data Extension` — local encrypted database and passphrase-encrypted backups

---

## 3. Target platforms and distribution

| Platform | Ship? | Minimum OS | Distribution channels |
|---|---|---|---|
| Android | yes | `minSdk 21` (`targetSdk 35`) | Split APKs for direct install; Google Play gate prepared ([release_process.md](release_process.md) §10) |
| iOS | no (future) | — | — |
| Windows | yes | Windows 10 (Flutter minimum) | Portable release folder |
| macOS | no (future) | — | — |
| Linux | no (future) | — | — |
| Web | no | — | — |

Build flavors: `dev + prod` (Android only; Windows has no flavors).

---

## 4. Languages

| Locale | Language | Script | Role | Language pack |
|---|---|---|---|---|
| `en` | English | Latin | Template ARB, ultimate fallback | — |
| `ml` | Malayalam | Malayalam | Full UI translation | [guidelines/language_packs/sanskrit_malayalam.md](guidelines/language_packs/sanskrit_malayalam.md) |
| `sa` | Sanskrit | Devanagari | Full UI translation | [guidelines/language_packs/sanskrit_malayalam.md](guidelines/language_packs/sanskrit_malayalam.md) |

- In-app language picker: `required` — System Default, English, Malayalam, Sanskrit.
- Languages without a Flutter framework translation (need the fallback delegate): `sa`.
- Store-listing languages per store: `to be decided before a public store release`.
- Native-reader reviewer for each non-template language: `maintainer`.

---

## 5. About screen

The About content comes from `assets/config/app_config.json`.

| Item | Value |
|---|---|
| `details` rows to show | `author, email, license, aiUsed, ideUsed` |
| Signature badge | `on` |
| Badge text — English | `Made with {heart} from India` |
| Badge text — Malayalam | `സ്നേഹത്തോടെ {heart} ഇന്ത്യയിൽ നിന്ന്` |
| Badge text — Sanskrit | `सस्नेहं निर्मितम् {heart} भारततः` |

---

## 6. Optional project-specific values

| Item | Value |
|---|---|
| App size budget override | `default` |
| State management | `Riverpod` |
| Structure tier | `Tier 1 layer-first` (5 layers under `lib/`) |
| Release owner (role) | `maintainer` |
