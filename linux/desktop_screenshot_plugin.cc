#include "include/desktop_screenshot/desktop_screenshot_plugin.h"

#include <flutter_linux/flutter_linux.h>
#include <gtk/gtk.h>
#include <sys/utsname.h>

#include <cstring>

#include "desktop_screenshot_plugin_private.h"

#define DESKTOP_SCREENSHOT_PLUGIN(obj) \
  (G_TYPE_CHECK_INSTANCE_CAST((obj), desktop_screenshot_plugin_get_type(), \
                              DesktopScreenshotPlugin))

struct _DesktopScreenshotPlugin {
  GObject parent_instance;
};

G_DEFINE_TYPE(DesktopScreenshotPlugin, desktop_screenshot_plugin, g_object_get_type())

// Called when a method call is received from Flutter.
static void desktop_screenshot_plugin_handle_method_call(
    DesktopScreenshotPlugin* self,
    FlMethodCall* method_call) {
  g_autoptr(FlMethodResponse) response = nullptr;

  const gchar* method = fl_method_call_get_name(method_call);

  if (strcmp(method, "getPlatformVersion") == 0) {
    response = get_platform_version();
  } else if (strcmp(method, "readImageFromClipboard") == 0) {
      read_image_from_clipboard(method_call);
      return;
  } else {
    response = FL_METHOD_RESPONSE(fl_method_not_implemented_response_new());
  }

  fl_method_call_respond(method_call, response, nullptr);
}

FlMethodResponse* get_platform_version() {
  struct utsname uname_data = {};
  uname(&uname_data);
  g_autofree gchar *version = g_strdup_printf("Linux %s", uname_data.version);
  g_autoptr(FlValue) result = fl_value_new_string(version);
  return FL_METHOD_RESPONSE(fl_method_success_response_new(result));
}

static void clipboard_request_image_callback(GtkClipboard* clipboard,
                                             GdkPixbuf* pixbuf,
                                             gpointer user_data) {
    g_autoptr(FlMethodCall) method_call = static_cast<FlMethodCall*>(user_data);

    if (!pixbuf) {
        fl_method_call_respond_success(method_call, nullptr, nullptr);
        return;
    }

    gchar* buffer = nullptr;
    gsize buffer_size = 0;
    GError* error = nullptr;

    gdk_pixbuf_save_to_buffer(pixbuf, &buffer, &buffer_size, "png", &error,
                              nullptr);
    if (error) {
        fl_method_call_respond_error(method_call, "0", error->message, nullptr,
                                     nullptr);
        return;
    }

    if (!buffer) {
        fl_method_call_respond_error(method_call, "0", "failed to get image",
                                     nullptr, nullptr);
        return;
    }

    fl_method_call_respond_success(
            method_call,
            fl_value_new_uint8_list(reinterpret_cast<const uint8_t*>(buffer),
                                    buffer_size),
            nullptr);
}

static void read_image_from_clipboard(FlMethodCall* method_call) {
    auto* clipboard = gtk_clipboard_get_default(gdk_display_get_default());
    gtk_clipboard_request_image(clipboard, clipboard_request_image_callback,
                                g_object_ref(method_call));
}

static void desktop_screenshot_plugin_dispose(GObject* object) {
  G_OBJECT_CLASS(desktop_screenshot_plugin_parent_class)->dispose(object);
}

static void desktop_screenshot_plugin_class_init(DesktopScreenshotPluginClass* klass) {
  G_OBJECT_CLASS(klass)->dispose = desktop_screenshot_plugin_dispose;
}

static void desktop_screenshot_plugin_init(DesktopScreenshotPlugin* self) {}

static void method_call_cb(FlMethodChannel* channel, FlMethodCall* method_call,
                           gpointer user_data) {
  DesktopScreenshotPlugin* plugin = DESKTOP_SCREENSHOT_PLUGIN(user_data);
  desktop_screenshot_plugin_handle_method_call(plugin, method_call);
}

void desktop_screenshot_plugin_register_with_registrar(FlPluginRegistrar* registrar) {
  DesktopScreenshotPlugin* plugin = DESKTOP_SCREENSHOT_PLUGIN(
      g_object_new(desktop_screenshot_plugin_get_type(), nullptr));

  g_autoptr(FlStandardMethodCodec) codec = fl_standard_method_codec_new();
  g_autoptr(FlMethodChannel) channel =
      fl_method_channel_new(fl_plugin_registrar_get_messenger(registrar),
                            "desktop_screenshot",
                            FL_METHOD_CODEC(codec));
  fl_method_channel_set_method_call_handler(channel, method_call_cb,
                                            g_object_ref(plugin),
                                            g_object_unref);

  g_object_unref(plugin);
}
