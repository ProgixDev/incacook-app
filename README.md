# IncaCook

A new Flutter project.

## Local setup

Copy `.vscode/dart_defines.example.json` to `.vscode/dart_defines.json` (git-
ignored — never commit real values) and fill in real credentials. This
example file is the **canonical, tracked list** of every dart-define the app
reads (verified against `String.fromEnvironment`/`bool.fromEnvironment`/
`int.fromEnvironment` call sites) — keep it in sync whenever a define is
added, renamed, or removed in code, so the shipped artifact's config stays
auditable even though the real values never enter git. VS Code's Run/Debug
configs in `.vscode/launch.json` already pass
`--dart-define-from-file=.vscode/dart_defines.json`; `flutter test` doesn't
need it (no test reads a real dart-define).

## Build scripts

This repo uses Melos for release build shortcuts. All scripts pass the local
dart defines file at `.vscode/dart_defines.json`.

```bash
melos run build:android:apk   # build/app/outputs/flutter-apk/app-release.apk
melos run build:android:aab   # build/app/outputs/bundle/release/app-release.aab
melos run build:android       # APK + AAB
melos run build:ios           # iOS release app, no IPA export
melos run build:ios:ipa       # build/ios/ipa/*.ipa
```

Android release signing reads `android/key.properties` when present. iOS IPA
export requires signing to be configured in Xcode for `ios/Runner.xcworkspace`.
If `melos` is not installed globally, run the same commands as
`dart run melos run <script>`.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Learn Flutter](https://docs.flutter.dev/get-started/learn-flutter)
- [Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Flutter learning resources](https://docs.flutter.dev/reference/learning-resources)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
