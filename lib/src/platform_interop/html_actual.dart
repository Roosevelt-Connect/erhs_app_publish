// This file provides the actual web implementations.
import 'dart:html' as html;
import 'dart:js_util' as js_util;
import 'dart:ui_web' as ui; // ADD this import for platformViewRegistry

// Export or define the types and functions you need from dart:html and dart:js_util
typedef VideoElement = html.VideoElement;

// Re-export js_util functions and globalThis
final dynamic globalThis = js_util.globalThis;
void setProperty(dynamic o, String name, dynamic value) => js_util.setProperty(o, name, value);
dynamic allowInterop(Function f) => js_util.allowInterop(f);
void callMethod(dynamic o, String method, List<dynamic> args) => js_util.callMethod(o, method, args);

// ADD this function for web
void registerViewFactory(String viewType, VideoElement videoElement) {
  ui.platformViewRegistry.registerViewFactory(
    viewType,
    (int viewId) => videoElement,
  );
}