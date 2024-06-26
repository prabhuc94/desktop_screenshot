import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'desktop_screenshot_platform_interface.dart';

/// An implementation of [DesktopScreenshotPlatform] that uses method channels.
class MethodChannelDesktopScreenshot extends DesktopScreenshotPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('desktop_screenshot');

  @override
  Future<String?> getPlatformVersion() async {
    final version = await methodChannel.invokeMethod<String>('getPlatformVersion');
    return version;
  }

  @override
  Future<Uint8List?> getScreenshot() async {
    final List<int> screenshot = await methodChannel.invokeMethod('getScreenshot');
    return Uint8List.fromList(screenshot);
  }
}
