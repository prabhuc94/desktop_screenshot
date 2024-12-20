import Cocoa
import FlutterMacOS

public class DesktopScreenshotPlugin: NSObject, FlutterPlugin {
  private var accessGranted: Bool = false
  
  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "desktop_screenshot", binaryMessenger: registrar.messenger)
    let instance = DesktopScreenshotPlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    switch call.method {
    case "getPlatformVersion":
      result("macOS " + ProcessInfo.processInfo.operatingSystemVersionString)
    case "isAccessAllowed":
      isAccessAllowed(call, result: result)
    case "requestAccess":
      requestAccess(call, result: result)
    case "readImageFromClipboard":
      readImageFromClipboard(call, result: result)
    case "getScreenshot":
      getScreenshot(result: result)
    default:
      result(FlutterMethodNotImplemented)
    }
  }

  public func isAccessAllowed(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    if #available(macOS 10.15, *) {
      result(CGPreflightScreenCaptureAccess())
      return
    }
    result(true)
  }

  public func requestAccess(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    let args: [String: Any] = call.arguments as! [String: Any]
    let onlyOpenPrefPane: Bool = args["onlyOpenPrefPane"] as! Bool

    if (!onlyOpenPrefPane) {
      if #available(macOS 10.15, *) {
        let granted = CGRequestScreenCaptureAccess()
        result(granted)
      } else {
        result(true)
      }
    } else {
      let prefpaneUrl = URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_ScreenCapture")!
      NSWorkspace.shared.open(prefpaneUrl)
      result(true)
    }
  }

  public func readImageFromClipboard(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    guard let image = NSPasteboard.general.readObjects(forClasses: [NSImage.self], options: nil)?.first as? NSImage else {
      result(nil)
      return
    }
    result(image.png)
  }

  public func getScreenshot(result: @escaping FlutterResult) {
    if accessGranted || isScreenCaptureAccessAllowed() {
      guard let screenshot = captureScreen() else {
        result(FlutterError(code: "INVALID_IMAGE_DATA", message: "Failed to capture valid image data", details: nil))
        return
      }
      result(screenshot.png)
    } else {
      let granted = requestScreenCaptureAccess()
      self.accessGranted = granted
      if granted {
        guard let screenshot = self.captureScreen() else {
          result(FlutterError(code: "INVALID_IMAGE_DATA", message: "Failed to capture valid image data", details: nil))
          return
        }
        result(screenshot.png)
      } else {
        result(FlutterError(code: "ACCESS_DENIED", message: "Screen capture access denied", details: nil))
      }
    }
  }

  private func isScreenCaptureAccessAllowed() -> Bool {
    if #available(macOS 10.15, *) {
      return CGPreflightScreenCaptureAccess()
    }
    return true
  }

  private func requestScreenCaptureAccess() -> Bool {
    if #available(macOS 10.15, *) {
      return CGRequestScreenCaptureAccess()
    }
    return true
  }

  private func captureScreen() -> NSImage? {
    let displayId = CGMainDisplayID()
    guard let imageRef = CGDisplayCreateImage(displayId) else { return nil }
    let bitmapRep = NSBitmapImageRep(cgImage: imageRef)
    let image = NSImage(size: bitmapRep.size)
    image.addRepresentation(bitmapRep)
    return image
  }
}

extension NSBitmapImageRep {
  var png: Data? { representation(using: .png, properties: [:]) }
}

extension Data {
  var bitmap: NSBitmapImageRep? { NSBitmapImageRep(data: self) }
}

extension NSImage {
  var png: Data? { tiffRepresentation?.bitmap?.png }
}
