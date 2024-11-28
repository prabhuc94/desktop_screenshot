import 'package:desktop_screenshot/desktop_screenshot.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:desktop_screenshot/desktop_screenshot_method_channel.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  MethodChannelDesktopScreenshot platform = MethodChannelDesktopScreenshot();
  const MethodChannel channel = MethodChannel('desktop_screenshot');

  late DesktopScreenshot desktopScreenshot;


  setUp(() {
    desktopScreenshot = DesktopScreenshot();
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(
      channel,
      (MethodCall methodCall) async {
        return await channel.invokeMethod<String>('getPlatformVersion');
      },
    );
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(channel, null);
  });

  test('returns a valid screenshot', () async {
    // Mock a valid response
    when(channel.invokeMethod<List<int>>('getScreenshot'))
        .thenAnswer((_) async => [1, 2, 3, 4]);

    final result = await desktopScreenshot.getScreenshot();
    expect(result, isNotNull);
    expect(result, isA<List<int>>());
    expect(result, [1, 2, 3, 4]);
  });

  test('getPlatformVersion', () async {
    expect(await platform.getPlatformVersion(), '42');
  });

  test("getScreenshot", () async {
    expect(await platform.getScreenshot(), isNotNull);
  });
}
