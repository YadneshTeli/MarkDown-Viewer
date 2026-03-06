import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'package:nusta_md/main.dart';
import 'package:nusta_md/models/markdown_file.dart';
import 'package:nusta_md/services/bookmark_service.dart';
import 'package:nusta_md/utils/constants.dart';

void main() {
  late Directory tempDir;

  setUpAll(() async {
    tempDir = await Directory.systemTemp.createTemp('hive_test');
    Hive.init(tempDir.path);
    
    // Register adapters
    if (!Hive.isAdapterRegistered(0)) Hive.registerAdapter(MarkdownFileAdapter());
    if (!Hive.isAdapterRegistered(1)) Hive.registerAdapter(BookmarkAdapter());

    // Open boxes needed by the app
    await Hive.openBox(AppConstants.settingsBox);
    await Hive.openBox<MarkdownFile>(AppConstants.recentFilesBox);
    await Hive.openBox<Bookmark>(AppConstants.bookmarksBox);
  });

  tearDownAll(() async {
    await Hive.deleteFromDisk();
    await Hive.close();
  });

  testWidgets('App smoke test: Home screen loads correctly', (tester) async {
    // Pump the entire app via MDViewerApp
    await tester.pumpWidget(
      const ProviderScope(
        child: MDViewerApp(),
      ),
    );
    await tester.pumpAndSettle();

    // Verify app title is displayed in AppBar
    expect(find.text('MD Viewer'), findsOneWidget);

    // Verify FAB or Empty state text is visible
    expect(find.text('Welcome to MD Viewer'), findsOneWidget);
  });
}
