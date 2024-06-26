import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:desktop_screenshot/desktop_screenshot.dart';
import 'package:desktop_screenshot/desktop_screenshot_platform_interface.dart';
import 'package:desktop_screenshot/desktop_screenshot_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockDesktopScreenshotPlatform
    with MockPlatformInterfaceMixin
    implements DesktopScreenshotPlatform {

  @override
  Future<String?> getPlatformVersion() => Future.value('42');

  @override
  Future<Uint8List?> getScreenshot() => Future.value(Uint8List(0));
}

void main() {
  final DesktopScreenshotPlatform initialPlatform = DesktopScreenshotPlatform.instance;

  test('$MethodChannelDesktopScreenshot is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelDesktopScreenshot>());
  });

  test('getPlatformVersion', () async {
    DesktopScreenshot desktopScreenshotPlugin = DesktopScreenshot();
    MockDesktopScreenshotPlatform fakePlatform = MockDesktopScreenshotPlatform();
    DesktopScreenshotPlatform.instance = fakePlatform;

    expect(await desktopScreenshotPlugin.getPlatformVersion(), '42');
  });
}
