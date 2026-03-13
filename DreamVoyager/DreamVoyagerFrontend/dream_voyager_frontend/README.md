# DreamVoyager Frontend

Flutter frontend for the DreamVoyager app.

## Requirements

If you want to start the app on a new laptop, install these tools first:

1. Git
2. Flutter SDK 3.38.x or newer
3. Android Studio
4. Android SDK via Android Studio
5. At least one Android emulator or one physical Android device
6. Optional: VS Code with Flutter and Dart extensions

This project currently uses:

- Dart SDK `^3.10.1`
- Java 17 for Android builds
- Android emulator networking via `10.0.2.2:3000`

## Downloads

Recommended downloads:

1. Git: https://git-scm.com/downloads
2. Flutter: https://docs.flutter.dev/get-started/install
3. Android Studio: https://developer.android.com/studio
4. VS Code: https://code.visualstudio.com/

## Initial Setup On A New Laptop

### 1. Install Flutter

Follow the official Flutter installation guide for your operating system.

After installing Flutter, verify it with:

```powershell
flutter doctor -v
```

Fix everything that Flutter marks as missing, especially the Android toolchain.

### 2. Install Android Studio And SDK Components

Open Android Studio and install the required Android components.

You should have at least:

1. Android SDK
2. Android SDK Platform for a current Android version
3. Android SDK Build-Tools
4. Android Emulator
5. One emulator image, ideally a Pixel device with Google Play support

The project uses the Android Studio bundled Java runtime, so in most cases no separate Java installation is needed.

### 3. Accept Android Licenses

Run:

```powershell
flutter doctor --android-licenses
```

Then check again:

```powershell
flutter doctor -v
```

### 4. Clone The Repository

```powershell
git clone <REPO_URL>
cd DreamVoyager\DreamVoyagerFrontend\dream_voyager_frontend
```

Replace `<REPO_URL>` with the actual repository URL.

### 5. Install Flutter Packages

```powershell
flutter pub get
```

## Backend Requirement

This frontend expects a backend API running on port `3000`.

The current API base URL logic is:

- Android emulator: `http://10.0.2.2:3000/api`
- Web and desktop: `http://localhost:3000/api`

That means:

1. If you use an Android emulator, the backend must run on the laptop itself on port `3000`.
2. If you use a real Android device, you will probably need to change the backend URL to your laptop's local IP address.

## Run The App

### Start An Emulator

Start the emulator from Android Studio Device Manager.

Check if Flutter sees it:

```powershell
flutter devices
```

### Run The Frontend

```powershell
flutter run -d emulator-5554
```

If your emulator has a different ID, replace `emulator-5554` with the correct one from `flutter devices`.

## Useful Commands

```powershell
flutter pub get
flutter clean
flutter analyze
flutter devices
flutter run
```

## Speech-To-Text Notes

This app uses microphone input and Android speech recognition.

If Speech-to-Text does not work on a fresh emulator:

1. Enable microphone access for the emulator itself.
2. Open the Google app once and allow microphone access.
3. Make sure the emulator image includes Google services.
4. In emulator settings, confirm that speech input works in the Google app.
5. If needed, cold boot the emulator.

If the microphone works in Google but not in the app, inspect app permissions and rerun the app.

## Common Problems

### `flutter doctor` shows missing Android toolchain

Install Android Studio, Android SDK, and accept licenses.

### The app cannot reach the backend

Make sure the backend is running on port `3000`.

For Android emulator testing, the backend must be reachable at:

```text
http://10.0.2.2:3000/api
```

### `flutter run` fails after dependency changes

Try:

```powershell
flutter clean
flutter pub get
flutter run
```

## Recommended VS Code Extensions

1. Dart
2. Flutter

## Project Entry Point

Main app entry file:

- [lib/main.dart](c:\Users\maxis\Documents\GitHub\wmc-project-maxstranzinger\DreamVoyager\DreamVoyagerFrontend\dream_voyager_frontend\lib\main.dart)
