import 'package:flutter/material.dart';

class AppConstants {
  AppConstants._();

  // App info
  static const String appName = 'MD Viewer';
  static const String appVersion = '1.0.0';

  // Colors
  static const Color primaryColor = Color(0xFF4F46E5);
  static const Color secondaryColor = Color(0xFF0EA5E9);

  // File constraints
  static const List<String> allowedExtensions = ['md', 'markdown'];
  static const int maxFileSizeBytes = 5 * 1024 * 1024; // 5 MB

  // Hive box names
  static const String recentFilesBox = 'recent_files';
  static const String settingsBox = 'settings';
  static const String bookmarksBox = 'bookmarks';

  // Settings keys
  static const String themeKey = 'theme_mode';
  static const String fontSizeKey = 'font_size';

  // History
  static const int maxRecentFiles = 20;
}
