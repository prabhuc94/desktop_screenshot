import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:desktop_screenshot/desktop_screenshot.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String _platformVersion = 'Unknown';
  Uint8List? capturedScreenShot;
  final _desktopScreenshotPlugin = DesktopScreenshot();

  @override
  void initState() {
    super.initState();
    initPlatformState();
    initScreenShotState();
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {
    String platformVersion;
    // Platform messages may fail, so we use a try/catch PlatformException.
    // We also handle the message potentially returning null.
    try {
      platformVersion = await _desktopScreenshotPlugin.getPlatformVersion() ??
          'Unknown platform version';
    } on PlatformException {
      platformVersion = 'Failed to get platform version.';
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    setState(() {
      _platformVersion = platformVersion;
    });
  }

  Future<void> initScreenShotState() async {
    Uint8List? screenShot;
    try {
      screenShot = await _desktopScreenshotPlugin.getScreenshot();
    } on PlatformException {
      screenShot = Uint8List(0);
    }

    if (kDebugMode) {
      print("ScreenShotSize ${screenShot?.lengthInBytes}");
    }


    if (!mounted) return;

    setState(() {
      if (screenShot != null) {
        capturedScreenShot = screenShot;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        floatingActionButton: FloatingActionButton.small(
            onPressed: initScreenShotState,
            child: Icon(Icons.screenshot_monitor_rounded)),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text('Running on: $_platformVersion\n'),
              SizedBox(height: 20),
              if (capturedScreenShot != null &&
                  (capturedScreenShot?.isNotEmpty ?? false))
                AspectRatio(
                  aspectRatio: 2.25,
                  child: Container(
                    margin: EdgeInsets.all(20),
                    child: Image(image: MemoryImage(capturedScreenShot!)),
                  ),
                )
            ],
          ),
        ),
      ),
    );
  }
}
