// This file provides stub implementations for non-web platforms.

// Stub for html.VideoElement
class VideoElement {
  final _MockStyle style = _MockStyle();
  bool autoplay = false;
  bool muted = false;
  void setAttribute(String name, String value) {
    // No-op for non-web platforms
  }
  // Add any other methods/properties of html.VideoElement that your code uses
  // if they are accessed outside of kIsWeb checks (which they shouldn't be).
}

class _MockStyle {
  String width = '';
  String height = '';
  String objectFit = '';
}

// Stubs for js_util functionalities
class _GlobalThisStub {} // Simple stub for globalThis type
final dynamic globalThis = _GlobalThisStub();

void setProperty(dynamic o, String name, dynamic value) {
  // No-op for non-web platforms
}

dynamic allowInterop(Function f) {
  // On non-web platforms, this function won't be called by JS.
  // Returning the original function is safe as it won't be used in a JS context.
  return f;
}

void callMethod(dynamic o, String method, List<dynamic> args) {
  // No-op for non-web platforms
}

// ADD this stub function
void registerViewFactory(String viewType, VideoElement videoElement) {
  // No-op for non-web platforms.
}