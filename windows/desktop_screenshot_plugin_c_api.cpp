#include "include/desktop_screenshot/desktop_screenshot_plugin_c_api.h"

#include <flutter/plugin_registrar_windows.h>

#include "desktop_screenshot_plugin.h"

void DesktopScreenshotPluginCApiRegisterWithRegistrar(
    FlutterDesktopPluginRegistrarRef registrar) {
  desktop_screenshot::DesktopScreenshotPlugin::RegisterWithRegistrar(
      flutter::PluginRegistrarManager::GetInstance()
          ->GetRegistrar<flutter::PluginRegistrarWindows>(registrar));
}
