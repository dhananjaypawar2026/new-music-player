# Install Play Music

This repo contains the full source code for Play Music.

## Option 1: Install From GitHub Releases

1. Open the repo releases page:
   https://github.com/DhananjayPawar2023/play-music-/releases
2. Download the file for your device:
   - Android: `Play-Music-Android-debug.apk`
   - Windows: `play_music-windows.zip`
   - Web: open the GitHub Pages link after Pages is enabled
3. On Android, allow installing APKs from your browser or file manager if Android asks.

## Option 2: Build From Source

Install Flutter first:
https://docs.flutter.dev/install

Then run:

```powershell
cd "path\to\play-music-"
flutter pub get
flutter gen-l10n
flutter run -d chrome --target lib/main.dart
```

For Android:

```powershell
flutter run --flavor production --target lib/main.dart
```

To build an APK:

```powershell
flutter build apk --debug --flavor production --target lib/main.dart
```

The APK will be created at:

```text
build/app/outputs/flutter-apk/app-production-debug.apk
```

## GitHub Build

The `Build Install Files` workflow can create downloadable Android, Web, and Windows builds from GitHub Actions without Play Store signing secrets.

1. Open the repo on GitHub.
2. Go to `Actions`.
3. Select `Build Install Files`.
4. Click `Run workflow`.
5. Download the generated artifacts after the workflow finishes.
