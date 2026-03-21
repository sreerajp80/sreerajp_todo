# Flutter Project Engineering Standard

This document is a reusable engineering standard for future Flutter projects.

It is intentionally layered. Small apps should inherit the core baseline without being forced into release-process or high-security requirements that do not fit the product.

## 1. How To Use This Standard

### 1.1 Conformance Language

Use these terms consistently:

- `MUST`: mandatory for the stated scope.
- `SHOULD`: expected default; deviations require a reason.
- `MAY`: optional.

### 1.2 Applicability Profiles

Every Flutter repository MUST declare which profile applies.

| Profile | Applies To | Purpose |
|---------|------------|---------|
| `Core Baseline` | All Flutter application repositories | Universal maintainability and code-quality rules |
| `Production App Extension` | Apps shipped to real users, external QA, or store review | Release, CI, UX, and environment discipline |
| `Sensitive Data Extension` | Apps handling auth secrets, financial data, health data, PII, or locally encrypted content | Stronger security, storage, logging, and backup rules |

A simple internal tool may use only `Core Baseline`.
A public consumer app will usually use `Core Baseline` plus `Production App Extension`.
An authenticator, password manager, finance, or health app will usually use all three.

### 1.3 Repository Types

This document primarily targets Flutter application repositories.

If the repository is a Flutter package or plugin:

- `android/`, `ios/`, and build-flavor rules MAY be omitted if not applicable.
- `pubspec.lock` SHOULD follow package conventions rather than application conventions.
- UI, release, and integration-test requirements apply only if the package ships runnable example apps or demo apps.

---

## 2. Core Principles

1. Structure by responsibility first, then by implementation detail.
2. Keep business logic outside widgets.
3. Prefer explicit code over clever abstractions.
4. Enforce standards through tooling where practical.
5. One repository SHOULD have one clear way to do state, navigation, theming, errors, and testing.
6. Optimize for current complexity, not hypothetical future complexity.
7. Security and logging policy are product requirements, not cleanup work.

---

## 3. Project Structure

### 3.1 Choose The Simplest Layout That Fits

#### Tier 1: Layer-First

Use for smaller apps, single-domain apps, or early products.

```text
lib/
|-- config/
|-- models/
|-- providers/        # Or controllers/blocs/cubits
|-- screens/
|-- services/
|-- widgets/
`-- main.dart
```

#### Tier 2: Feature-First

Use when multiple product areas evolve independently or when several developers routinely touch unrelated features.

```text
lib/
|-- app/
|   |-- config/
|   |-- routing/
|   `-- theme/
|-- core/
|   |-- errors/
|   |-- logging/
|   |-- network/
|   |-- security/
|   |-- storage/
|   `-- widgets/
|-- features/
|   `-- <feature_name>/
|       |-- data/
|       |-- domain/
|       `-- presentation/
`-- main.dart
```

Promote from Tier 1 to Tier 2 only when the current shape creates actual boundary confusion, naming collisions, or merge friction.

### 3.2 Structure Rules

These rules apply to all app repositories.

- `main.dart` MUST stay thin: framework initialization, config loading, provider or DI setup, then `runApp`.
- A broad catch-all `utils/` directory SHOULD be avoided. If a `utils/` folder starts collecting unrelated concerns, split it into named locations.
- `test/` SHOULD mirror `lib/` closely enough that ownership is obvious.
- Platform directories MUST NOT contain business logic that belongs in Dart unless platform constraints require it.

### 3.3 Recommended Root Layout For App Repositories

```text
project/
|-- android/                  # Optional for non-Android targets or packages
|-- ios/                      # Optional for non-iOS targets or packages
|-- assets/
|   |-- icons/
|   `-- images/
|-- docs/
|-- lib/
|-- test/
|-- integration_test/         # Required only when end-to-end coverage applies
|-- .github/workflows/
|-- analysis_options.yaml
|-- pubspec.yaml
|-- README.md
`-- .gitignore
```

Application repositories SHOULD commit `pubspec.lock`.
Packages and plugins SHOULD follow normal package conventions.

---

## 4. Architecture Baseline

### 4.1 State Management

- Pick one primary state-management approach per repository.
- Do not mix multiple state systems for the same problem unless there is a documented reason.
- Providers, controllers, or blocs MUST expose UI-facing state and transitions, not raw storage primitives.
- State layers MUST NOT import widget classes.

### 4.2 Data Flow

Preferred flow:

```text
Widget -> State Layer -> Service or Use Case -> Repository -> Datasource
```

Not every Tier 1 app needs an explicit repository layer. Introduce `Repository` and `Datasource` boundaries when they reduce complexity or isolate external systems cleanly.

Rules:

- Widgets MUST NOT know SQL, encryption, HTTP, or storage implementation details.
- Services SHOULD be stateless where practical.
- Singletons SHOULD be limited to infrastructure concerns such as database access, app config, or logging.
- Services MUST NOT decide UI copy or navigation policy.

### 4.3 Models And Entities

- Prefer immutable models.
- In Tier 1, a single model MAY serve both storage and UI if the shape is simple.
- In Tier 2, transport models and domain entities SHOULD diverge when the serialization shape and business shape differ.
- Constants that define protocols, storage keys, or cryptographic formats SHOULD live in one reviewed location.

### 4.4 Dependency Injection

- Use framework-native dependency wiring first.
- Introduce a dedicated DI solution only when it clearly reduces complexity.
- Anything that tests need to replace MUST be injectable.

---

## 5. Environment And Build Configuration

This section is optional for `Core Baseline` projects and applies fully under `Production App Extension`.

### 5.1 When Flavors Are Required

Build flavors are REQUIRED when any of the following is true:

- The app has distinct `dev`, `staging`, or `prod` environments.
- QA needs production-like builds against non-production config.
- Multiple variants must be installed side by side.
- Release behavior differs materially by environment.

If the app has only one environment and no parallel install need, flavors MAY be omitted.

### 5.2 Recommended Flavor Model

A common baseline is `dev` and `prod`.

```dart
enum AppFlavor { dev, prod }

class AppFlavorConfig {
  AppFlavorConfig._(this.flavor);

  static const _flavorValue = String.fromEnvironment(
    'FLUTTER_APP_FLAVOR',
    defaultValue: 'prod',
  );

  static final AppFlavorConfig instance = AppFlavorConfig._(
    _parse(_flavorValue),
  );

  final AppFlavor flavor;

  static AppFlavor _parse(String value) {
    switch (value.trim().toLowerCase()) {
      case 'dev':
        return AppFlavor.dev;
      case 'prod':
      default:
        return AppFlavor.prod;
    }
  }

  bool get isDev => flavor == AppFlavor.dev;
  bool get isProd => flavor == AppFlavor.prod;

  String get appName => isDev ? 'MyApp Dev' : 'MyApp';
  bool get showEnvironmentBanner => isDev;
  bool get enableVerboseLogging => isDev;
}
```

If you use a Dart-define based flavor config, build and run commands MUST pass the same value explicitly.

```bash
flutter run --flavor dev --dart-define=FLUTTER_APP_FLAVOR=dev
flutter run --flavor prod --dart-define=FLUTTER_APP_FLAVOR=prod
flutter build apk --flavor prod --release --dart-define=FLUTTER_APP_FLAVOR=prod
```

Native Android and iOS flavor names SHOULD stay aligned with the Dart flavor value.

### 5.3 Android Flavor Setup

When Android flavors are used, the project SHOULD define product flavors in `android/app/build.gradle` or `android/app/build.gradle.kts`.

```kotlin
android {
    flavorDimensions += "environment"
    productFlavors {
        create("dev") {
            dimension = "environment"
            applicationIdSuffix = ".dev"
            versionNameSuffix = "-dev"
        }
        create("prod") {
            dimension = "environment"
        }
    }
}
```

### 5.4 Artifact Selection

Under `Production App Extension`:

- Use split APKs when distributing directly outside an app store.
- Use `.aab` for Google Play submission.
- Avoid universal release APKs unless there is a specific distribution reason.

`--target-platform` does not replace `--split-per-abi`.

---

## 6. UI And UX Baseline

This section applies to user-facing applications. It is advisory for infrastructure packages.

### 6.1 Theme And Design Tokens

- Use one source of truth for theme configuration.
- Centralize colors, typography, spacing, radius, and motion values.
- Prefer semantic names over raw literals in widgets.
- If the product supports both light and dark themes, both MUST be tested.

### 6.2 Widget Structure

- Screens compose flows and sections.
- Reusable widgets belong in shared widget locations only when they are actually shared.
- Widgets MUST NOT own persistence, cryptography, or network behavior.
- Large `build` methods SHOULD be split when readability drops.

### 6.3 Screen-State Guidance

Async and task-oriented screens SHOULD define the states they genuinely need:

1. Loading
2. Empty
3. Success
4. Error

Not every static screen needs all four states. Apply this rule where asynchronous data or user actions make those states meaningful.

### 6.4 UX Rules For Production Apps

Under `Production App Extension`:

- Forms MUST validate before submission and show actionable errors.
- Destructive actions MUST require confirmation or provide undo.
- Layouts SHOULD work on common phone sizes before release.
- Accessibility SHOULD cover semantics, tap targets, contrast, and focus order.
- Route definitions SHOULD be centralized.
- Deep links, if supported, SHOULD have integration coverage.

---

## 7. Security Standard

### 7.1 Core Security Rules

These rules apply to all Flutter apps.

- Never log secrets, tokens, private payloads, or decrypted sensitive data.
- Request only the permissions the app actually uses.
- Ask for permissions at point of use where the platform allows it.
- Production logs SHOULD avoid personal data unless operationally necessary.

### 7.2 Sensitive Data Extension

Apply this section when the app handles authentication factors, private documents, health data, financial data, recovery codes, or local encrypted stores.

- Sensitive values MUST NOT be stored in `SharedPreferences`.
- Use platform-backed secure storage for keys, tokens, or secret material.
- Use authenticated encryption such as AES-GCM for stored sensitive payloads.
- Never hardcode keys, IVs, salts, recovery passwords, or backup passwords.
- Cryptographic formats SHOULD be versioned so migrations remain possible.
- Clipboard use for secrets SHOULD be time-bounded or explicitly communicated.
- Screenshot and screen-recording protection SHOULD be enabled where supported.
- App lock, background lock, and session-expiry behavior SHOULD be explicit in app state.
- Export of sensitive data SHOULD be encrypted by default; plaintext export, if allowed, MUST be explicit and user-confirmed.
- Backup, recovery, import, and migration flows MUST be tested as critical flows.

### 7.3 Logging And Telemetry

Under `Sensitive Data Extension`:

- Use structured logging rather than scattered `print` calls.
- Verbose logging MUST be gated by environment or flavor config.
- Error logs SHOULD contain operation and error context without exposing protected data.

---

## 8. Coding Standards

### 8.1 Formatting And Analysis

- Run `dart format .` before commit.
- New work MUST NOT introduce analyzer issues.
- Repositories SHOULD aim for zero analyzer warnings overall.
- Start from `package:flutter_lints/flutter.yaml` and add stricter rules deliberately.

Recommended baseline additions:

```yaml
include: package:flutter_lints/flutter.yaml

linter:
  rules:
    avoid_print: true
    prefer_single_quotes: true
    prefer_const_constructors: true
    prefer_const_declarations: true
    prefer_final_fields: true
    prefer_final_locals: true
    avoid_unnecessary_containers: true
    sized_box_for_whitespace: true
    use_key_in_widget_constructors: true
    prefer_is_empty: true
    avoid_empty_else: true
    unnecessary_brace_in_string_interps: true
    unnecessary_this: true
    no_duplicate_case_values: true
    avoid_redundant_argument_values: true
    sort_child_properties_last: true
    use_full_hex_values_for_flutter_colors: true
    always_use_package_imports: true
    cancel_subscriptions: true
    close_sinks: true
```

### 8.2 Size And Complexity Guidance

These are prompts to review, not automatic failures.

| Metric | Guideline |
|--------|-----------|
| File length | Around 300 lines: consider splitting |
| File length | Around 500 lines: split or justify |
| Function length | Around 50 lines: consider extracting |
| Widget build method | Around 120 lines: consider sub-widgets |
| Parameters per function | More than 5: consider a parameter object |

### 8.3 Naming

- Use `snake_case` for files, `PascalCase` for classes, and `camelCase` for variables and functions.
- Suffix state objects with their role where helpful, such as `AccountProvider` or `AuthController`.
- Prefer explicit names over abbreviations.

### 8.4 Comments And Error Handling

- Comments SHOULD explain why, not restate what code does.
- TODOs SHOULD include an owner, issue, or clear follow-up context.
- Do not swallow exceptions silently.
- Show user-safe error messages in the UI while preserving internal diagnostic context appropriately.

### 8.5 Dependencies

- Add dependencies only when they remove meaningful complexity.
- Prefer maintained packages with clear ownership and null-safety support.
- Review transitive risk for packages that handle auth, storage, files, camera, or encryption.
- Remove unused dependencies promptly.

---

## 9. Testing Standard

### 9.1 Test Levels

| Level | Core Baseline | Production App Extension |
|-------|---------------|--------------------------|
| Unit tests | Required for business logic, models, parsing, validation, and services | Required |
| Widget tests | Required for screens or widgets with meaningful UI logic | Required |
| Integration tests | Optional unless the app has critical end-to-end flows | Required for critical release paths |
| Golden tests | Optional | Optional but recommended for design systems |

### 9.2 Test Rules

- `test/` SHOULD mirror `lib/` closely.
- Services, state layers, and models with non-trivial logic SHOULD have corresponding tests.
- Critical math, parsing, migration, and security logic MUST use deterministic vectors where available.
- Bug fixes SHOULD add regression tests when feasible.
- Run `flutter test` after code changes that affect Dart behavior.
- Shared test scaffolding SHOULD live in `test/helpers/` or an equally obvious location.

### 9.3 Test Quality

- Tests MUST be independent.
- Use descriptive test names.
- Mock external systems, not the logic under test.
- Important test files SHOULD be runnable in isolation.
- Coverage trends are useful, but arbitrary percentage gates SHOULD NOT replace judgment.

---

## 10. CI Standard

### 10.1 Minimum CI

All active app repositories SHOULD have CI on pull requests or on the merge path to the protected branch.

Minimum checks:

```yaml
steps:
  - run: flutter pub get
  - run: dart format --output=none --set-exit-if-changed .
  - run: flutter analyze
  - run: flutter test
```

### 10.2 Production App Extension

For shipped apps, also consider:

```yaml
  - run: flutter test --coverage
  - run: flutter build apk --flavor dev --debug
  - run: flutter build apk --flavor prod --release
```

Add integration smoke runs, dependency audits, or artifact size checks when the project risk justifies them.

### 10.3 Pre-Commit

A pre-commit hook MAY run formatting and analysis locally, but CI remains the source of truth.

---

## 11. Git And Repository Hygiene

### 11.1 Branching And Commits

- Protect the main branch for team repositories.
- Use short-lived branches.
- Prefer conventional commit prefixes such as `feat:`, `fix:`, `refactor:`, `test:`, `docs:`, and `build:`.
- Keep commits cohesive.

### 11.2 Never Commit

- Build output such as `build/`, APKs, AABs, and generated release artifacts
- Secrets, keys, keystores, and signing material
- Local machine configuration files containing credentials or machine-specific paths

### 11.3 Usually Commit

- `analysis_options.yaml`
- `.gitignore`
- `pubspec.lock` for application repositories

---

## 12. Documentation Standard

### 12.1 Required Documents For App Repositories

| Document | Purpose |
|----------|---------|
| `README.md` | Setup, run, test, and build instructions |
| `docs/architecture.md` or equivalent | Module boundaries and major decisions |
| `docs/release_process.md` | Required only for shipped apps with release process complexity |

### 12.2 Recommended Documents

- `CHANGELOG.md` for user-facing release history
- `docs/security.md` for sensitive-data apps
- `docs/adr/` for architecture decision records that are likely to be revisited
- Repository-specific AI instructions such as `AGENTS.md`, `CLAUDE.md`, or equivalent

---

## 13. AI Coding Assistant Instructions

When this standard is supplied to an AI coding assistant, the assistant MUST:

### 13.1 Before Writing Code

- Read the existing code before modifying it.
- Identify whether the repo is Tier 1 or Tier 2 and follow the existing structure.
- Identify the existing state-management pattern and follow it.
- Identify which applicability profile is in force for the repository.

### 13.2 While Writing Code

- Respect the current project structure unless the task explicitly includes restructuring.
- Do not introduce a second state-management system without a documented reason.
- Do not add boilerplate comments or type annotations to unchanged code.
- Do not invent abstractions for one-time operations.
- Apply the security profile in force; never log secrets or weaken cryptographic behavior.
- Do not use `kDebugMode` or `kReleaseMode` as a substitute for application flavor when the project has explicit environments.

### 13.3 After Writing Code

- Run `flutter test` after code changes that affect behavior.
- Run `flutter analyze` before considering the task complete.
- Add or update tests when logic changes.
- Verify that no secrets, local machine files, or build artifacts are staged.

---

## 14. Definition Of Done

A task is complete only when all applicable items are true.

### 14.1 Core Baseline

- Architecture boundaries were respected.
- New code follows the repository's chosen state-management pattern.
- Tests were added or updated for changed logic where appropriate.
- `flutter analyze` is clean for the change.
- `flutter test` passes for behavior-affecting code changes.
- `dart format .` produces no required follow-up changes.
- No secrets, build output, or local machine files were added to git.

### 14.2 Production App Extension

- Environment-specific behavior was verified if the change touched it.
- Required CI checks pass.
- User-facing documentation was updated if behavior changed.
- Release builds or flavor builds were verified when the change touched build, config, signing, or release behavior.

### 14.3 Sensitive Data Extension

- Sensitive data handling was reviewed against the security section.
- Logging was reviewed for protected data exposure.
- Backup, import, export, migration, or recovery paths were tested if touched.

---

## 15. Practical Guidance

- A thin `main.dart` scales better than a smart one.
- Mirrored tests reduce search time and ownership confusion.
- `utils/` is acceptable only when its scope stays clear and small.
- Flavors solve real problems, but not every app needs them on day one.
- Security requirements should be attached to product risk, not copied blindly.
- CI should enforce the boring rules so review can focus on behavior and design.

Treat this document as a baseline plus extensions. Tighten it for higher-risk apps, and relax optional guidance only with a deliberate reason.
