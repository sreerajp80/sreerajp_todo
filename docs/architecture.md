# Architecture

Use this document to describe the current system design of the Flutter app.

## 1. Scope

- Product: `<app name>`
- Repository type: `application` or `package/plugin`
- Engineering standard profiles in force:
  - `Core Baseline`
  - `Production App Extension` if applicable
  - `Sensitive Data Extension` if applicable
- Platforms: `Android`, `iOS`, `Web`, `Desktop` as applicable

## 2. Goals And Non-Goals

### Goals

- `<goal 1>`
- `<goal 2>`
- `<goal 3>`

### Non-Goals

- `<non-goal 1>`
- `<non-goal 2>`

## 3. Architecture Summary

Describe the current architecture in one short paragraph.

Example:

> The app uses a Tier 1 layer-first Flutter structure with Provider for state management. Screens delegate business logic to services, local persistence is isolated behind storage services, and app-wide configuration is injected at startup through the root widget tree.

## 4. Repository Structure

### Current Structure Tier

- `Tier 1` or `Tier 2`
- Why this tier is appropriate now:
  - `<reason 1>`
  - `<reason 2>`

### Top-Level Source Layout

```text
lib/
|-- <folder>
|-- <folder>
`-- main.dart
```

### Ownership Rules

| Path | Responsibility |
|------|----------------|
| `lib/...` | `<responsibility>` |
| `lib/...` | `<responsibility>` |

## 5. State Management

- Primary pattern: `Provider`, `Riverpod`, `Bloc`, etc.
- Why this pattern was chosen:
  - `<reason 1>`
  - `<reason 2>`
- State boundaries:
  - Widgets own: `<ui-only concerns>`
  - State layer owns: `<screen/app state concerns>`
  - Services own: `<business logic concerns>`

## 6. Data Flow

Describe the expected request and update path.

```text
Widget -> State Layer -> Service or Use Case -> Repository -> Datasource
```

If the app intentionally omits a layer, document that here.

### Rules

- Widgets must not know: `<sql/http/crypto/etc.>`
- Services must not know: `<navigation/copy/etc.>`
- Repositories abstract: `<api/db/cache/etc.>`

## 7. Domain Model

### Core Models Or Entities

| Type | Purpose | Mutable? | Notes |
|------|---------|----------|-------|
| `<ModelName>` | `<purpose>` | `No` | `<notes>` |
| `<ModelName>` | `<purpose>` | `No` | `<notes>` |

### Serialization Strategy

- JSON models: `<yes/no>`
- Database models: `<yes/no>`
- Separate domain entities from transport models: `<yes/no and why>`

## 8. Dependency Management And Injection

- DI approach: `<provider tree / get_it / riverpod / manual wiring>`
- App-root dependencies:
  - `<dependency>`
  - `<dependency>`
- Test replacement strategy:
  - `<mock/fake/override approach>`

## 9. Navigation

- Navigation approach: `<Navigator 1.0 / go_router / auto_route / custom>`
- Route definition location: `<path>`
- Protected-route strategy: `<auth/app-lock gating pattern>`
- Deep-link support: `<yes/no>`

## 10. Persistence And External Systems

### Local Storage

- Database: `<sqflite/isars/hive/etc.>`
- Key-value storage: `<shared_preferences/etc.>`
- Secure storage: `<flutter_secure_storage/etc.>`

### Network

- Network client: `<dio/http/none>`
- Offline behavior: `<online-only/offline-first/cache-assisted>`

### Platform Channels Or Native Integrations

- `<integration>`: `<purpose>`
- `<integration>`: `<purpose>`

## 11. Environment And Build Model

- Flavors used: `<dev/prod/staging/none>`
- Runtime config mechanism: `<dart-define/config file/native flavor>`
- Build outputs supported:
  - `<debug apk>`
  - `<release apk>`
  - `<app bundle>`

## 12. UI System

- Theme source of truth: `<path>`
- Design tokens location: `<path>`
- Shared widget strategy: `<where shared UI lives>`
- Accessibility expectations: `<baseline requirements>`

## 13. Testing Strategy

| Test Type | Scope | Notes |
|-----------|-------|-------|
| Unit | `<scope>` | `<notes>` |
| Widget | `<scope>` | `<notes>` |
| Integration | `<scope>` | `<notes>` |

### Test Layout

```text
test/
|-- <mirrored folders>
```

### Critical Test Areas

- `<critical logic area>`
- `<critical flow>`
- `<migration or parsing path>`

## 14. Operational Constraints

Document constraints that shape implementation choices.

- Minimum supported OS versions: `<versions>`
- Performance constraints: `<startup/memory/offline/etc.>`
- Regulatory or store constraints: `<if any>`
- Team constraints: `<single developer / multi-developer / release cadence>`

## 15. Decisions And Tradeoffs

Record the decisions that are likely to be questioned later.

| Decision | Chosen Option | Why | Tradeoff |
|----------|---------------|-----|----------|
| `<topic>` | `<choice>` | `<reason>` | `<tradeoff>` |
| `<topic>` | `<choice>` | `<reason>` | `<tradeoff>` |

## 16. Known Risks And Follow-Ups

- Risk: `<risk>`
  Mitigation: `<mitigation>`
- Risk: `<risk>`
  Mitigation: `<mitigation>`

## 17. Related Documents

- `README.md`
- `docs/flutter_project_engineering_standard.md`
- `docs/project_structure.md`
- `docs/release_process.md` if applicable
- `docs/security.md` if applicable
