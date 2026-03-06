import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'models/markdown_file.dart';
import 'providers/file_provider.dart';
import 'providers/theme_provider.dart';
import 'screens/home_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/viewer_screen.dart';
import 'services/bookmark_service.dart';
import 'services/intent_service.dart';
import 'utils/constants.dart';
import 'utils/theme.dart';

final _navigatorKey = GlobalKey<NavigatorState>();

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

  // Check if started from an "Open with" intent before the widget tree builds
  final initialFilePath = await IntentService.getInitialFile();

  runApp(
    ProviderScope(
      child: MDViewerApp(initialFilePath: initialFilePath),
    ),
  );
}

class MDViewerApp extends ConsumerStatefulWidget {
  final String? initialFilePath;

  const MDViewerApp({super.key, this.initialFilePath});

  @override
  ConsumerState<MDViewerApp> createState() => _MDViewerAppState();
}

class _MDViewerAppState extends ConsumerState<MDViewerApp> {
  @override
  void initState() {
    super.initState();
    // Handle files opened while the app is already running
    IntentService.registerHandler(_openIntentFile);
    // Handle cold-start intent — navigate after first frame
    if (widget.initialFilePath != null) {
      WidgetsBinding.instance.addPostFrameCallback(
        (_) => _openIntentFile(widget.initialFilePath!),
      );
    }
  }

  Future<void> _openIntentFile(String path) async {
    final file = await ref.read(fileProvider.notifier).openFromPath(path);
    if (file != null) {
      _navigatorKey.currentState?.pushNamedAndRemoveUntil(
        '/viewer',
        (route) => route.isFirst,
        arguments: file,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeMode = ref.watch(themeProvider);

    return MaterialApp(
      navigatorKey: _navigatorKey,
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
