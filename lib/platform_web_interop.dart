// This file conditionally exports the correct implementation.
export 'src/platform_interop/html_stub.dart' // Stub implementation (default)
    if (dart.library.html) 'src/platform_interop/html_actual.dart'; // Actual web implementation