# jeden_z_dziesieciu_v2

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

## Android release (Google Play)

The app targets Android 16 (API 36) via `flutter.targetSdkVersion` / `flutter.compileSdkVersion` (Flutter 3.50+).

Build a release App Bundle:

```
flutter pub get
flutter build appbundle --release
```

Signing uses `android/key.properties` (gitignored) pointing at the Play **upload** keystore. A sample file:

```
storePassword=...
keyPassword=...
keyAlias=...
storeFile=/absolute/path/to/upload-keystore.jks
```

If `key.properties` is missing, the release bundle is signed with the debug key and must not be uploaded to Play.
