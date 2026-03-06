import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'models/markdown_file.dart';
import 'providers/theme_provider.dart';
import 'screens/home_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/viewer_screen.dart';
import 'services/bookmark_service.dart';
import 'utils/constants.dart';
import 'utils/theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Hive
  await Hive.initFlutter();
  Hive.registerAdapter(MarkdownFileAdapter());
  Hive.registerAdapter(BookmarkAdapter());

  // Open Hive boxes
  await Hive.openBox(AppConstants.settingsBox);
  await Hive.openBox<MarkdownFile>(AppConstants.recentFilesBox);
  await Hive.openBox<Bookmark>(AppConstants.bookmarksBox);

  runApp(
    const ProviderScope(
      child: MDViewerApp(),
    ),
  );
}

class MDViewerApp extends ConsumerWidget {
  const MDViewerApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeProvider);

    return MaterialApp(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: themeMode,
      initialRoute: '/',
      routes: {
        '/': (context) => const HomeScreen(),
        '/viewer': (context) => const ViewerScreen(),
        '/settings': (context) => const SettingsScreen(),
      },
    );
  }
}
