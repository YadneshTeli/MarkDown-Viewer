import 'package:flutter/material.dart';

class AppConstants {
  AppConstants._();

  // App info
  static const String appName = 'MD Viewer';
  static const String appVersion = '1.0.0';

  // Colors
  static const Color primaryColor = Color(0xFF2196F3);
  static const Color secondaryColor = Color(0xFF009688);
  static const Color darkSurface = Color(0xFF1E1E1E);
  static const Color darkCard = Color(0xFF2D2D2D);

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
