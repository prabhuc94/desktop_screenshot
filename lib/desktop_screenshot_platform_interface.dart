// import 'dart:typed_data';

import 'package:flutter/services.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'desktop_screenshot_method_channel.dart';

abstract class DesktopScreenshotPlatform extends PlatformInterface {
  /// Constructs a DesktopScreenshotPlatform.
  DesktopScreenshotPlatform() : super(token: _token);

  static final Object _token = Object();

  static DesktopScreenshotPlatform _instance = MethodChannelDesktopScreenshot();

  /// The default instance of [DesktopScreenshotPlatform] to use.
  ///
  /// Defaults to [MethodChannelDesktopScreenshot].
  static DesktopScreenshotPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [DesktopScreenshotPlatform] when
  /// they register themselves.
  static set instance(DesktopScreenshotPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<String?> getPlatformVersion() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }

  Future<Uint8List?> getScreenshot() {
    throw UnimplementedError('getScreenshot() has not been implemented.');
  }
}
