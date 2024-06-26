#include "desktop_screenshot_plugin.h"

// This must be included before many other Windows headers.
#include <windows.h>

// For getPlatformVersion; remove unless needed for your plugin implementation.
#include <VersionHelpers.h>

#include <flutter/method_channel.h>
#include <flutter/plugin_registrar_windows.h>
#include <flutter/standard_method_codec.h>

#include <atlimage.h>
#include <codecvt>
#include <map>

#include <cstdint>

#include <iostream>
#include <vector>
#include <fstream>

#include <memory>
#include <sstream>

namespace desktop_screenshot {

    HBITMAP CaptureScreen();

    std::vector<BYTE> Hbitmap2PNG(HBITMAP hbitmap);

// static
    void DesktopScreenshotPlugin::RegisterWithRegistrar(
            flutter::PluginRegistrarWindows *registrar) {
        auto channel =
                std::make_unique < flutter::MethodChannel < flutter::EncodableValue >> (
                        registrar->messenger(), "desktop_screenshot",
                                &flutter::StandardMethodCodec::GetInstance());

        auto plugin = std::make_unique<DesktopScreenshotPlugin>();

        channel->SetMethodCallHandler(
                [plugin_pointer = plugin.get()](const auto &call, auto result) {
                    plugin_pointer->HandleMethodCall(call, std::move(result));
                });

        registrar->AddPlugin(std::move(plugin));
    }

    DesktopScreenshotPlugin::DesktopScreenshotPlugin() {}

    DesktopScreenshotPlugin::~DesktopScreenshotPlugin() {}

    void DesktopScreenshotPlugin::HandleMethodCall(
            const flutter::MethodCall <flutter::EncodableValue> &method_call,
            std::unique_ptr <flutter::MethodResult<flutter::EncodableValue>> result) {
        if (method_call.method_name().compare("getPlatformVersion") == 0) {
            std::ostringstream version_stream;
            version_stream << "Windows ";
            if (IsWindows10OrGreater()) {
                version_stream << "10+";
            } else if (IsWindows8OrGreater()) {
                version_stream << "8";
            } else if (IsWindows7OrGreater()) {
                version_stream << "7";
            }
            result->Success(flutter::EncodableValue(version_stream.str()));
        } else if (method_call.method_name().compare("getScreenshot") == 0) {
            HBITMAP bitmap = CaptureScreen();
            if (bitmap) {
                std::vector<BYTE> pngBuf = Hbitmap2PNG(bitmap);
                result->Success(flutter::EncodableValue(pngBuf));
                pngBuf.clear();
                DeleteObject(bitmap);
            } else {
                result->Error("INVALID_IMAGE_DATA", "Failed to capture valid image data");
            }
        } else {
            result->NotImplemented();
        }
    }

    HBITMAP CaptureScreen() {
        HWND hwnd = GetDesktopWindow();

        flutter::EncodableMap result_map = flutter::EncodableMap();

        HDC hdcScreen;
        HDC hdcWindow;
        HDC hdcMemDC = NULL;
        HBITMAP hbitmap = NULL;

        // Retrieve the handle to a display device context for the client
        // area of the window.
        hdcScreen = GetDC(NULL);
        hdcWindow = GetDC(hwnd);

        // Create a compatible DC, which is used in a BitBlt from the window DC.
        hdcMemDC = CreateCompatibleDC(hdcWindow);

        if (!hdcMemDC) {
//            result->Error("Failed", "CreateCompatibleDC has failed");
            return nullptr;
        }

        // Get the client area for size calculation.
        RECT rcClient;
        GetClientRect(hwnd, &rcClient);

        // This is the best stretch mode.
        SetStretchBltMode(hdcWindow, HALFTONE);

        // The source DC is the entire screen, and the destination DC is the current
        // window (HWND).
        if (!StretchBlt(hdcWindow, 0, 0, rcClient.right, rcClient.bottom, hdcScreen,
                        0, 0, GetSystemMetrics(SM_CXSCREEN),
                        GetSystemMetrics(SM_CYSCREEN), SRCCOPY)) {
//            result->Error("Failed", "StretchBlt has failed");
            return nullptr;
        }

        // Create a compatible bitmap from the Window DC.
        hbitmap = CreateCompatibleBitmap(hdcWindow, rcClient.right - rcClient.left,
                                         rcClient.bottom - rcClient.top);

        if (!hbitmap) {
//            result->Error("Failed", "CreateCompatibleBitmap Failed");
            return nullptr;
        }

        // Select the compatible bitmap into the compatible memory DC.
        SelectObject(hdcMemDC, hbitmap);

        // Bit block transfer into our compatible memory DC.
        if (!BitBlt(hdcMemDC, 0, 0, rcClient.right - rcClient.left,
                    rcClient.bottom - rcClient.top, hdcWindow, 0, 0, SRCCOPY)) {
//            result->Error("Failed", "BitBlt has failed");
            return nullptr;
        }

        DeleteObject(hdcMemDC);
        ReleaseDC(NULL, hdcScreen);
        ReleaseDC(hwnd, hdcWindow);

        return hbitmap;
//        DeleteObject(hbitmap);
    }

    std::vector<BYTE> Hbitmap2PNG(HBITMAP hbitmap) {
        std::vector<BYTE> buf;
        if (hbitmap != NULL) {
            IStream* stream = NULL;
            CreateStreamOnHGlobal(0, TRUE, &stream);
            CImage image;
            ULARGE_INTEGER liSize;

            // screenshot to png and save to stream
            image.Attach(hbitmap);
            image.Save(stream, Gdiplus::ImageFormatPNG);
            IStream_Size(stream, &liSize);
            DWORD len = liSize.LowPart;
            IStream_Reset(stream);
            buf.resize(len);
            IStream_Read(stream, &buf[0], len);
            stream->Release();
        }
        return buf;
    }

}  // namespace desktop_screenshot
