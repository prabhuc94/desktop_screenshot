#ifndef FLUTTER_PLUGIN_DESKTOP_SCREENSHOT_PLUGIN_H_
#define FLUTTER_PLUGIN_DESKTOP_SCREENSHOT_PLUGIN_H_

#include <flutter/method_channel.h>
#include <flutter/plugin_registrar_windows.h>

#include <memory>

namespace desktop_screenshot {

class DesktopScreenshotPlugin : public flutter::Plugin {
 public:
  static void RegisterWithRegistrar(flutter::PluginRegistrarWindows *registrar);

  DesktopScreenshotPlugin();

  virtual ~DesktopScreenshotPlugin();

  // Disallow copy and assign.
  DesktopScreenshotPlugin(const DesktopScreenshotPlugin&) = delete;
  DesktopScreenshotPlugin& operator=(const DesktopScreenshotPlugin&) = delete;

  // Called when a method is called on this plugin's channel from Dart.
  void HandleMethodCall(
      const flutter::MethodCall<flutter::EncodableValue> &method_call,
      std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result);
};

}  // namespace desktop_screenshot

#endif  // FLUTTER_PLUGIN_DESKTOP_SCREENSHOT_PLUGIN_H_
