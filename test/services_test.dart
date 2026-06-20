import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:nusta_md/models/markdown_file.dart';
import 'package:nusta_md/services/markdown_parser.dart';

void main() {
  group('MarkdownParser - Ordered List sequence numbers', () {
    test('parses and keeps the actual leading sequence numbers', () {
      final parser = MarkdownParser();
      final content = '''
5. Fifth item
6. Sixth item
10. Tenth item
''';
      final blocks = parser.parseBlocks(content);
      expect(blocks.length, 3);
      expect(blocks[0].type, MdBlockType.orderedListItem);
      expect(blocks[0].level, 5);
      expect(blocks[0].text, 'Fifth item');
      
      expect(blocks[1].type, MdBlockType.orderedListItem);
      expect(blocks[1].level, 6);
      expect(blocks[1].text, 'Sixth item');
      
      expect(blocks[2].type, MdBlockType.orderedListItem);
      expect(blocks[2].level, 10);
      expect(blocks[2].text, 'Tenth item');
    });
  });

  group('MarkdownParser - Setext Headings', () {
    test('parses Setext Level 1 headings underlined with ===', () {
      final parser = MarkdownParser();
      final content = '''
This is H1
======
''';
      final blocks = parser.parseBlocks(content);
      expect(blocks.length, 1);
      expect(blocks[0].type, MdBlockType.heading);
      expect(blocks[0].level, 1);
      expect(blocks[0].text, 'This is H1');
    });

    test('parses Setext Level 2 headings underlined with ---', () {
      final parser = MarkdownParser();
      final content = '''
This is H2
------
''';
      final blocks = parser.parseBlocks(content);
      expect(blocks.length, 1);
      expect(blocks[0].type, MdBlockType.heading);
      expect(blocks[0].level, 2);
      expect(blocks[0].text, 'This is H2');
    });

    test('does not confuse Setext Level 2 with a normal horizontal rule', () {
      final parser = MarkdownParser();
      final content = '''
Some Paragraph

---
''';
      final blocks = parser.parseBlocks(content);
      expect(blocks.length, 2);
      expect(blocks[0].type, MdBlockType.paragraph);
      expect(blocks[1].type, MdBlockType.hr);
    });
  });

  group('History Content Persistence Policy', () {
    late Directory tempDir;
    late Box<MarkdownFile> recentBox;

    setUpAll(() async {
      tempDir = await Directory.systemTemp.createTemp('nusta_md_test_');
      Hive.init(tempDir.path);
      // Register adapter if not already registered (avoid conflicts)
      try {
        Hive.registerAdapter(MarkdownFileAdapter());
      } catch (_) {}
      recentBox = await Hive.openBox<MarkdownFile>('recent_files');
    });

    tearDownAll(() async {
      await recentBox.close();
      await tempDir.delete(recursive: true);
    });

    test('keeps content only for temporary picker cache files', () {
      final stableFile = MarkdownFile(
        name: 'stable.md',
        path: '/users/documents/stable.md',
        size: 100,
        content: 'stable content',
        lastOpened: DateTime.now(),
      );

      final tempFile = MarkdownFile(
        name: 'temp.md',
        path: '/data/user/0/com.nustamd.app/cache/file_picker/temp.md',
        size: 100,
        content: 'temp content',
        lastOpened: DateTime.now(),
      );

      final stableCopy = stableFile.copyForHistory(
        keepContent: stableFile.path.contains('cache') ||
            stableFile.path.contains('tmp') ||
            stableFile.path.contains('temp'),
      );
      final tempCopy = tempFile.copyForHistory(
        keepContent: tempFile.path.contains('cache') ||
            tempFile.path.contains('tmp') ||
            tempFile.path.contains('temp'),
      );

      expect(stableCopy.content, isEmpty);
      expect(tempCopy.content, 'temp content');
    });
  });
}
