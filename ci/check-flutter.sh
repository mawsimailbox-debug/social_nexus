#!/usr/bin/env bash
set -euo pipefail
cd -- "$(dirname -- "$0")/../app-flutter"
test -s pubspec.yaml
flutter --version
flutter pub get --enforce-lockfile
dart format --output=none --set-exit-if-changed lib test integration_test
flutter analyze --fatal-infos --fatal-warnings
flutter test --coverage
flutter build apk --release
flutter build appbundle --release
# Emulator/device integration tests, cert pinning, signing and IPA require their own runners.
