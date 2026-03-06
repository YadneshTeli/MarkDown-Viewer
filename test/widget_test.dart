import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:nusta_md/screens/home_screen.dart';
import 'package:nusta_md/utils/theme.dart';


void main() {
  testWidgets('Home screen displays app title and FAB', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          theme: AppTheme.light,
          darkTheme: AppTheme.dark,
          home: const HomeScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Verify app title
    expect(find.text('MD Viewer'), findsOneWidget);

    // Verify FAB
    expect(find.text('Open File'), findsOneWidget);
    expect(find.byIcon(Icons.folder_open), findsOneWidget);

    // Verify empty state
    expect(find.text('Welcome to MD Viewer'), findsOneWidget);
  });
}
