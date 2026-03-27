# AGENTS

This file guides agentic contributors working in this repository.

## Agent behavior requirements

- **Be autonomous**: work through tasks end-to-end. Run builds, tests, and lint after every change. Fix issues before declaring done.
- **Verify before acting**: before using any package API, check its version on pub.dev and read its documentation. Never guess at API signatures.
- **Use latest versions**: when adding or updating dependencies, always check pub.dev for the latest release. Use `flutter pub upgrade` to stay current.
- **Run tests**: after every meaningful change, run `flutter test`. Confirm zero failures before moving on.
- **Run lint**: run `flutter analyze` after changes. Fix all warnings and errors.
- **Commit and push**: when the task is complete (tests pass, lint is clean), commit all changes with a descriptive message and push to the remote. **Always push immediately after committing** — never stop to ask whether to continue; just commit, push, and keep going. Never ask the user whether to continue — just do the work.

## Build, lint, and test commands

### Dependencies
```sh
flutter pub get
```

### Build (code generation)
```sh
# Run build_runner (if using freezed, json_serializable, etc.)
dart run build_runner build --delete-conflicting-outputs
# Watch mode during development
dart run build_runner watch --delete-conflicting-outputs
```

### Lint
```sh
flutter analyze
dart fix --apply
```

### Format
```sh
dart format .
# CI check (non-zero exit if unformatted)
dart format --set-exit-if-changed .
```

### Test
```sh
# Run all tests
flutter test
# Run a single test file
flutter test test/features/auth/auth_repository_test.dart
# Run a single test by name
flutter test --name "returns user on success" test/features/auth/auth_repository_test.dart
# Run tests in a directory
flutter test test/unit/
# Run with coverage
flutter test --coverage
```

### Run
```sh
flutter run                 # debug
flutter build apk           # Android release
flutter build ios           # iOS release
flutter build web           # Web release
```

## Code generation rules

**Never edit generated files.** They will be overwritten:
- `**/*.freezed.dart`, `**/*.g.dart`, `**/*.gen.dart`

Run `dart run build_runner build --delete-conflicting-outputs` to regenerate.

Build order (from `build.yaml` when applicable): `freezed` -> `json_serializable` -> `retrofit_generator`.

## Code style guidelines

Base lint: `very_good_analysis` (or `flutter_lints`) — check `analysis_options.yaml`.

### Naming
- Classes, enums, typedefs, extensions: `UpperCamelCase` — `UserProfile`, `AuthState`
- Variables, parameters, functions: `lowerCamelCase` — `userName`, `fetchData()`
- Files and directories: `lower_snake_case` — `user_profile_screen.dart`
- Constants: `lowerCamelCase` — `const defaultPadding = 16.0` (not SCREAMING_CASE)
- Private members: `_` prefix — `_internalState`
- Booleans: use `is`, `has`, `should` prefixes — `isLoading`, `hasError`
- File suffixes by role: `_screen.dart`, `_widget.dart`, `_model.dart`, `_repository.dart`, `_service.dart`, `_controller.dart`, `_provider.dart`, `_test.dart`

### Imports
- Use `package:` imports for project files, never relative imports
- Order imports in groups separated by blank lines:
  1. `dart:` SDK imports
  2. `package:flutter/` SDK imports
  3. Third-party `package:` imports (alphabetical)
  4. Project `package:` imports (alphabetical)
- Alias when ambiguous: `import 'package:http/http.dart' as http;`
- Use `show`/`hide` only to resolve name conflicts
- Do not manually edit barrel/index files if they are generated

### Types & null safety
- Explicit types for public API (function signatures, class fields)
- `final` for locals by default; `const` for compile-time constants
- Avoid implicit `dynamic`; use `Object?` when the type is truly unknown
- Never use `!` without a preceding null check or documented guarantee
- Use `required` keyword for required named parameters

### Enums
Use enhanced Dart enums with a `value` field when serialization is needed:
```dart
enum Status {
  active('active'),
  inactive('inactive');
  const Status(this.value);
  final String value;
}
```

### Error handling
- Prefer typed exceptions (`StateError`, `TimeoutException`) with context in messages
- Do not swallow exceptions; log or rethrow with context
- Use `try/catch` close to where the error originates; avoid wrapping large blocks
- For I/O or network failures, surface actionable messages to the user
- Use `try/catch` with `rethrow` when logging before propagation

```dart
try {
  final user = await repository.fetchUser(id);
  state = AsyncData(user);
} on NetworkException catch (e) {
  state = AsyncError(e, StackTrace.current);
  logger.warning('Failed to fetch user $id: $e');
}
```

### Formatting
- Line length: **80 characters** (Dart default)
- Trailing commas on all argument/parameter lists and collection literals
- Let `dart format` handle all formatting — do not manually adjust
- Single quotes for strings: `'hello'` not `"hello"`
- Do not reformat generated files
- Use `// ignore_for_file:` only when strictly necessary

### Widget & UI conventions
- Extract widgets into separate classes, not helper methods returning `Widget`
- Keep `build()` methods short — decompose into smaller widgets
- Use `const` constructors wherever possible
- Widget key as first parameter: `const MyWidget({super.key})`
- Prefer `StatelessWidget` unless local mutable state is required
- Use `super.key` instead of `Key? key` in constructor + `super(key: key)`

### Patterns
- Dispose pattern: cleanup streams/timers/subscriptions in `dispose()`
- Fire-and-forget async: use `unawaited()` explicitly
- Constructor injection for dependencies with `required` named parameters
- Cascade notation (`..`) for fluent API setup

## Architecture

Organize code by feature with separated layers:

```
lib/
  core/
    constants/
    theme/
    utils/
    widgets/           # shared reusable widgets
  features/
    auth/
      data/            # repositories, data sources, models
      domain/          # entities, use cases
      presentation/    # screens, widgets, controllers
    home/
      ...
  main.dart
```

Keep business logic out of widgets — use controllers, providers, blocs, or equivalent.

## Test conventions

- Mirror the `lib/` structure under `test/`
- Name test files with `_test.dart` suffix
- Structure: `group('ClassName', () { test('verb phrase', () { ... }); })`
- Description style: lowercase, verb-leading phrases (`'returns user on success'`)
- Each test must be independent — no shared mutable state between tests
- Use `setUp`/`tearDown` for common setup
- Mock dependencies using `mocktail` or `mockito`
- Use `const` constructors in tests where possible
- Assertions: `expect(actual, matcher)` with `isTrue`, `isFalse`, `isNotNull`, `equals()`

## Documentation
- Add `///` doc comments to all public classes, methods, and properties
- Reference other symbols with `[]`: `/// Returns a [User] instance`
- Explain *why*, not *what*

## Git commits
- Conventional commits: `feat:`, `fix:`, `refactor:`, `test:`, `docs:`, `chore:`
- Keep commits atomic — one logical change per commit

## Dependencies
- Read the package README on pub.dev before adding any dependency
- Prefer well-maintained packages with high pub points
- Pin major versions in `pubspec.yaml`
- Run `flutter pub upgrade --major-versions` periodically to stay current
- Do not add platform-specific or UI dependencies to core library code
