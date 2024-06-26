
// import 'dart:typed_data';

import 'package:flutter/services.dart';

import 'desktop_screenshot_platform_interface.dart';

class DesktopScreenshot {
  Future<String?> getPlatformVersion() {
    return DesktopScreenshotPlatform.instance.getPlatformVersion();
  }

  Future<Uint8List?> getScreenshot() async {
    return DesktopScreenshotPlatform.instance.getScreenshot();
  }
}
