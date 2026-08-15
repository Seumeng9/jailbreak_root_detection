# jailbreak_root_detection

[![pub package](https://img.shields.io/pub/v/jailbreak_root_detection.svg)](https://pub.dartlang.org/packages/jailbreak_root_detection)
[![license](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)

Detects rooted, jailbroken, tampered and otherwise untrusted devices from Flutter.

Uses [RootBeer](https://github.com/scottyab/rootbeer) + Magisk and Frida checks for Android root detection, and [IOSSecuritySuite (~> 1.9.10)](https://github.com/securing/IOSSecuritySuite/tree/1.9.10) for iOS jailbreak detection.

## Requirements

| | Minimum |
| --- | --- |
| Flutter | 3.44.0 |
| Dart SDK | 3.12.0 |
| Android | minSdk 21, compileSdk 34, Java/Kotlin 17 |
| iOS | 11.0 |

The iOS side ships as a Swift Package (Swift Package Manager). A CocoaPods podspec is still
included, so both dependency managers work.

## Getting started

Add the dependency to your `pubspec.yaml`:

```yaml
dependencies:
  jailbreak_root_detection: "^1.2.3"
```

Or:

```shell
flutter pub add jailbreak_root_detection
```

### iOS setup

To let the plugin probe for jailbreak-related URL schemes, add them to `ios/Runner/Info.plist`:

```xml
<key>LSApplicationQueriesSchemes</key>
<array>
    <string>undecimus</string>
    <string>sileo</string>
    <string>zbra</string>
    <string>filza</string>
    <string>activator</string>
    <string>cydia</string>
</array>
```

Without this entry iOS blocks the `canOpenURL` checks and jailbreak detection is less accurate.

### Android setup

No extra configuration required.

## Usage

```dart
import 'package:jailbreak_root_detection/jailbreak_root_detection.dart';

final detector = JailbreakRootDetection.instance;

// One combined verdict — the usual entry point.
final isNotTrust = await detector.isNotTrust;
if (isNotTrust) {
  // Block, warn, or degrade functionality.
}
```

### API

| Member | Returns | Android | iOS | Description |
| --- | --- | :---: | :---: | --- |
| `isNotTrust` | `Future<bool>` | ✅ | ✅ | Combined verdict: jailbroken/rooted, not a real device, or (Android) installed on external storage. Returns `true` if any check throws. |
| `isJailBroken` | `Future<bool>` | ✅ | ✅ | Rooted (RootBeer, Frida, Magisk) on Android; jailbroken on iOS. |
| `isRealDevice` | `Future<bool>` | ✅ | ✅ | `false` on an emulator or simulator. |
| `isDebugged` | `Future<bool>` | ✅ | ✅ | A debugger is attached to the process. |
| `isDevMode` | `Future<bool>` | ✅ | — | Developer options are enabled. |
| `isOnExternalStorage` | `Future<bool>` | ✅ | — | The app is installed on external storage. |
| `isTampered(String bundleId)` | `Future<bool>` | — | ✅ | The app bundle/signature has been modified. |
| `checkForIssues` | `Future<List<JailbreakIssue>>` | ✅ | ✅ | All detected issues in one call. |

Android-only members throw a `MissingPluginException` on iOS and vice versa, so guard them with
`Platform.isAndroid` / `Platform.isIOS`:

```dart
if (Platform.isAndroid) {
  final isOnExternalStorage = await detector.isOnExternalStorage;
  final isDevMode = await detector.isDevMode;
}

if (Platform.isIOS) {
  const bundleId = 'com.w3conext.jailbreakRootDetectionExample';
  final isTampered = await detector.isTampered(bundleId);
}
```

### checkForIssues

`checkForIssues` runs every check the platform supports and returns only the problems it found —
an empty list means the device looks clean.

```dart
final issues = await detector.checkForIssues;
for (final issue in issues) {
  print('issue: $issue');
}
```

| `JailbreakIssue` | Android | iOS | Meaning |
| --- | :---: | :---: | --- |
| `jailbreak` | ✅ | ✅ | Device is rooted or jailbroken. |
| `notRealDevice` | ✅ | ✅ | Running on an emulator or simulator. |
| `debugged` | ✅ | ✅ | A debugger is attached. |
| `fridaFound` | ✅ | ✅ | The Frida instrumentation framework was detected. |
| `devMode` | ✅ | — | Developer options are enabled. |
| `onExternalStorage` | ✅ | — | App is installed on external storage. |
| `proxied` | — | ✅ | An HTTP proxy is configured. |
| `reverseEngineered` | — | ✅ | Reverse-engineering tooling was detected. |
| `cydiaFound` | — | ✅ | Cydia was detected. |
| `tampered` | — | — | Reported only by `isTampered(bundleId)`, not by `checkForIssues`. |
| `unknown` | ✅ | ✅ | An issue this Dart version doesn't recognise. Android currently reports Magisk detection here. |

Handle `unknown` as untrusted rather than ignoring it.

## Important: test on real devices only

This package must be tested on a physical device.

Running on an emulator or simulator may cause false positives — for example, detection may
incorrectly report that the device is jailbroken or rooted.

## Example

See [`example/lib/main.dart`](example/lib/main.dart) for a complete app that runs every check
and prints the results.

## Reference

- [RootBeer](https://github.com/scottyab/rootbeer)
- [IOSSecuritySuite](https://github.com/securing/IOSSecuritySuite)
- [trust_fall](https://github.com/anish-adm/trust_fall)

## License

[MIT](LICENSE)
