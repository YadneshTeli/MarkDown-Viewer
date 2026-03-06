import 'package:flutter/services.dart';

typedef FileOpenedCallback = void Function(String path);

/// Bridges the native "Open with" intent / document handler to Flutter.
///
/// On Android this reads the Activity intent URI.
/// On iOS this reads the URL passed to `application(_:open:options:)`.
class IntentService {
  static const _channel = MethodChannel('com.example.nusta_md/open_file');

  /// Returns the file path if the app was cold-started via "Open with".
  /// Call once during app startup before the widget tree is built.
  static Future<String?> getInitialFile() async {
    try {
      return await _channel.invokeMethod<String>('getInitialFile');
    } catch (_) {
      return null;
    }
  }

  /// Register a callback invoked when a file is opened while the app is
  /// already running (warm start / app already in foreground).
  static void registerHandler(FileOpenedCallback onFileOpened) {
    _channel.setMethodCallHandler((call) async {
      if (call.method == 'openFile' && call.arguments is String) {
        onFileOpened(call.arguments as String);
      }
    });
  }
}
