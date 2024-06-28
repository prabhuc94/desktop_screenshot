# desktop_screenshot

This plugin allows Flutter desktop apps to take screenshots.

[![pub version][pub-image]][pub-url]

[pub-image]: https://img.shields.io/pub/v/desktop_screenshot.svg
[pub-url]: https://pub.dev/packages/desktop_screenshot


## Platform Support

| Linux | macOS | Windows |
| :---: | :---: | :-----: |
|  ✔️   |  ✔️   |   ✔️    |

## Quick Start

### Installation

Add this to your package's pubspec.yaml file:

```yaml
dependencies:
  desktop_screenshot: ^0.0.2
```
#### Windows requirements

Be sure to modify your Visual Studio installation and ensure that **"C++ ATL for latest v142 build tools (x86 & x64)"** is installed!

### Usage

### macOS

Change the file `macos/Runner/DebugProfile.entitlements` or `macos/Runner/Release.entitlements` as follows:

> Required only for sandbox mode.

```diff
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
	<key>com.apple.security.app-sandbox</key>
	<true/>
+	<key>com.apple.security.temporary-exception.mach-register.global-name</key>
+	<string>com.apple.screencapture.interactive</string>
</dict>
</plist>
```

```dart

import 'package:desktop_screenshot/desktop_screenshot.dart';

final _desktopScreenshotPlugin = DesktopScreenshot();

Uint8List? capturedData = await _desktopScreenshotPlugin.getScreenshot();

```

> Please see the example app of this plugin for a full example.

## License