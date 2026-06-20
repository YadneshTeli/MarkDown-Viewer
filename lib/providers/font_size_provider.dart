import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../utils/constants.dart';

/// Manages and persists the user-selected text font size for markdown rendering.
class FontSizeNotifier extends Notifier<double> {
  @override
  double build() {
    final box = Hive.box(AppConstants.settingsBox);
    return box.get(AppConstants.fontSizeKey, defaultValue: 16.0) as double;
  }

  /// Update the font size and persist to Hive.
  Future<void> setFontSize(double size) async {
    state = size;
    final box = Hive.box(AppConstants.settingsBox);
    await box.put(AppConstants.fontSizeKey, size);
  }
}

final fontSizeProvider = NotifierProvider<FontSizeNotifier, double>(
  FontSizeNotifier.new,
);
