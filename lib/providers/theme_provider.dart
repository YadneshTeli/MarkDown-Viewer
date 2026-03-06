import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../utils/constants.dart';

/// Manages the app's theme mode (light / dark / system).
class ThemeNotifier extends Notifier<ThemeMode> {
  @override
  ThemeMode build() {
    return _loadFromHive();
  }

  ThemeMode _loadFromHive() {
    final box = Hive.box(AppConstants.settingsBox);
    final stored = box.get(AppConstants.themeKey, defaultValue: 'system');
    return _fromString(stored);
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    state = mode;
    final box = Hive.box(AppConstants.settingsBox);
    await box.put(AppConstants.themeKey, _toString(mode));
  }

  /// Cycle through: system → light → dark → system
  Future<void> toggleTheme() async {
    switch (state) {
      case ThemeMode.system:
        await setThemeMode(ThemeMode.light);
      case ThemeMode.light:
        await setThemeMode(ThemeMode.dark);
      case ThemeMode.dark:
        await setThemeMode(ThemeMode.system);
    }
  }

  IconData get icon {
    return switch (state) {
      ThemeMode.system => Icons.brightness_auto,
      ThemeMode.light => Icons.light_mode,
      ThemeMode.dark => Icons.dark_mode,
    };
  }

  String get label {
    return switch (state) {
      ThemeMode.system => 'System',
      ThemeMode.light => 'Light',
      ThemeMode.dark => 'Dark',
    };
  }

  static ThemeMode _fromString(String value) {
    return switch (value) {
      'light' => ThemeMode.light,
      'dark' => ThemeMode.dark,
      _ => ThemeMode.system,
    };
  }

  static String _toString(ThemeMode mode) {
    return switch (mode) {
      ThemeMode.light => 'light',
      ThemeMode.dark => 'dark',
      ThemeMode.system => 'system',
    };
  }
}

final themeProvider = NotifierProvider<ThemeNotifier, ThemeMode>(
  ThemeNotifier.new,
);
