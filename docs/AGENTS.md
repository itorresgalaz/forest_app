# Repository Guidelines

## Project Structure & Module Organization

The repository currently contains `Forest Senior Mobile Engineer (Flutter) Test.md`, the specification for a two-screen brewery application. No Flutter scaffold exists yet. Treat the brief as the source of requirements.

When implementing, organize `lib/` into domain, data, and presentation layers, optionally grouped under `features/breweries/`. Keep entities and repository contracts in domain, API clients and DTO mapping in data, and screens plus Cubit/Bloc state in presentation. Place tests in `test/`, mirroring source paths; declare any assets in `pubspec.yaml`.

## Build, Test, and Development Commands

Once the Flutter project and `pubspec.yaml` exist, run commands from the application root:

- `flutter pub get`: install dependencies.
- `flutter run`: launch on a connected device or emulator.
- `flutter analyze`: check Dart code for static issues.
- `dart format lib test`: format source and tests.
- `flutter test`: run the test suite.
- `flutter build apk`: build an Android release APK when needed.

## Coding Style & Naming Conventions

Use standard Dart formatting with two-space indentation, `snake_case.dart` filenames, `UpperCamelCase` types, and `lowerCamelCase` members. Adopt Flutter lints when scaffolding.

Use Cubit/Bloc with sealed states and inject dependencies through constructors; avoid service-locator calls from widgets. Repositories should throw typed exceptions, which presentation logic converts into visible error states. Never leave catch blocks empty. Explain departures from the suggested stack in the README.

## Testing Guidelines

Include at least one meaningful test, as required by the brief. Use Flutter's test framework, with `bloc_test` and `mocktail` where useful. Name files `*_test.dart` and describe observable behavior. Prioritize loading-to-success and loading-to-error transitions with fake or mocked repositories. Full coverage is outside the exercise scope; no numeric threshold is specified.

## Commit & Pull Request Guidelines

No usable Git history is available to establish commit conventions. Prefer concise, imperative messages such as `Add paginated brewery list`. Keep changes focused.

PR descriptions should explain completed requirements, validation commands, trade-offs, and intentional omissions. Link relevant issues when available and include screenshots for screen changes. Maintain a short README covering setup, completed work, omissions, and future improvements.

## Agent Instructions

Prefer codebase-memory MCP graph tools for code discovery; index the project first if needed. Fall back to text search for non-code files, literals, or insufficient graph results.
