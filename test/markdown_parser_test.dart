import 'package:flutter_test/flutter_test.dart';
import 'package:nusta_md/services/markdown_parser.dart';

void main() {
  late MarkdownParser parser;

  setUp(() {
    parser = MarkdownParser();
  });

  group('MarkdownParser.parseBlocks', () {
    test('parses empty content', () {
      final blocks = parser.parseBlocks('');
      expect(blocks, isEmpty);
    });

    test('parses a simple paragraph', () {
      final blocks = parser.parseBlocks('Hello world.');
      expect(blocks, hasLength(1));
      expect(blocks[0].type, MdBlockType.paragraph);
      expect(blocks[0].text, 'Hello world.');
    });

    test('joins multi-line paragraphs into single block', () {
      final blocks = parser.parseBlocks('Line one\nLine two\nLine three');
      expect(blocks, hasLength(1));
      expect(blocks[0].type, MdBlockType.paragraph);
      expect(blocks[0].text, 'Line one Line two Line three');
    });

    test('separates paragraphs by empty lines', () {
      final blocks = parser.parseBlocks('First paragraph.\n\nSecond paragraph.');
      expect(blocks, hasLength(2));
      expect(blocks[0].type, MdBlockType.paragraph);
      expect(blocks[0].text, 'First paragraph.');
      expect(blocks[1].type, MdBlockType.paragraph);
      expect(blocks[1].text, 'Second paragraph.');
    });

    // ─── Headings ─────────────────────────────────────────────────────

    test('parses H1 heading', () {
      final blocks = parser.parseBlocks('# Hello');
      expect(blocks, hasLength(1));
      expect(blocks[0].type, MdBlockType.heading);
      expect(blocks[0].text, 'Hello');
      expect(blocks[0].level, 1);
    });

    test('parses H2 through H6 headings', () {
      final md = '## H2\n### H3\n#### H4\n##### H5\n###### H6';
      final blocks = parser.parseBlocks(md);
      expect(blocks, hasLength(5));
      for (int i = 0; i < 5; i++) {
        expect(blocks[i].type, MdBlockType.heading);
        expect(blocks[i].level, i + 2);
      }
    });

    test('does not treat # without space as heading', () {
      final blocks = parser.parseBlocks('#NoSpace');
      expect(blocks, hasLength(1));
      expect(blocks[0].type, MdBlockType.paragraph);
    });

    // ─── Code Blocks ──────────────────────────────────────────────────

    test('parses fenced code block with backticks', () {
      final md = '```\nconst x = 1;\nconsole.log(x);\n```';
      final blocks = parser.parseBlocks(md);
      expect(blocks, hasLength(1));
      expect(blocks[0].type, MdBlockType.code);
      expect(blocks[0].text, 'const x = 1;\nconsole.log(x);');
    });

    test('parses fenced code block with tildes', () {
      final md = '~~~\nprint("hello")\n~~~';
      final blocks = parser.parseBlocks(md);
      expect(blocks, hasLength(1));
      expect(blocks[0].type, MdBlockType.code);
      expect(blocks[0].text, 'print("hello")');
    });

    test('parses fenced code block with language tag', () {
      final md = '```dart\nvoid main() {}\n```';
      final blocks = parser.parseBlocks(md);
      expect(blocks, hasLength(1));
      expect(blocks[0].type, MdBlockType.code);
      expect(blocks[0].text, 'void main() {}');
    });

    // ─── Lists ────────────────────────────────────────────────────────

    test('parses unordered list items with dash', () {
      final md = '- Item 1\n- Item 2\n- Item 3';
      final blocks = parser.parseBlocks(md);
      expect(blocks, hasLength(3));
      for (final block in blocks) {
        expect(block.type, MdBlockType.listItem);
      }
      expect(blocks[0].text, 'Item 1');
      expect(blocks[1].text, 'Item 2');
      expect(blocks[2].text, 'Item 3');
    });

    test('parses unordered list items with asterisk', () {
      final md = '* Apple\n* Banana';
      final blocks = parser.parseBlocks(md);
      expect(blocks, hasLength(2));
      expect(blocks[0].type, MdBlockType.listItem);
      expect(blocks[0].text, 'Apple');
      expect(blocks[1].text, 'Banana');
    });

    test('parses unordered list items with plus', () {
      final md = '+ First\n+ Second';
      final blocks = parser.parseBlocks(md);
      expect(blocks, hasLength(2));
      expect(blocks[0].type, MdBlockType.listItem);
    });

    test('parses ordered list items with period', () {
      final md = '1. First\n2. Second\n3. Third';
      final blocks = parser.parseBlocks(md);
      expect(blocks, hasLength(3));
      for (final block in blocks) {
        expect(block.type, MdBlockType.orderedListItem);
      }
      expect(blocks[0].text, 'First');
      expect(blocks[0].level, 1);
      expect(blocks[1].text, 'Second');
      expect(blocks[1].level, 2);
      expect(blocks[2].text, 'Third');
      expect(blocks[2].level, 3);
    });

    test('parses ordered list items with parenthesis', () {
      final md = '1) Alpha\n2) Beta';
      final blocks = parser.parseBlocks(md);
      expect(blocks, hasLength(2));
      expect(blocks[0].type, MdBlockType.orderedListItem);
      expect(blocks[0].text, 'Alpha');
    });

    // ─── Blockquotes ──────────────────────────────────────────────────

    test('parses single-line blockquote', () {
      final blocks = parser.parseBlocks('> This is a quote');
      expect(blocks, hasLength(1));
      expect(blocks[0].type, MdBlockType.blockquote);
      expect(blocks[0].text, 'This is a quote');
    });

    test('parses multi-line blockquote', () {
      final md = '> Line one\n> Line two';
      final blocks = parser.parseBlocks(md);
      expect(blocks, hasLength(1));
      expect(blocks[0].type, MdBlockType.blockquote);
      expect(blocks[0].text, 'Line one\nLine two');
    });

    // ─── Horizontal Rules ─────────────────────────────────────────────

    test('parses --- as horizontal rule', () {
      final blocks = parser.parseBlocks('---');
      expect(blocks, hasLength(1));
      expect(blocks[0].type, MdBlockType.hr);
    });

    test('parses *** as horizontal rule', () {
      final blocks = parser.parseBlocks('***');
      expect(blocks, hasLength(1));
      expect(blocks[0].type, MdBlockType.hr);
    });

    test('parses ___ as horizontal rule', () {
      final blocks = parser.parseBlocks('___');
      expect(blocks, hasLength(1));
      expect(blocks[0].type, MdBlockType.hr);
    });

    // ─── Mixed Content ────────────────────────────────────────────────

    test('parses a realistic markdown document', () {
      final md = '''# Title

This is a paragraph.

## Section

- Item A
- Item B

> A quote

```
code();
```

---

1. First
2. Second''';

      final blocks = parser.parseBlocks(md);

      // Verify block types in order
      expect(blocks[0].type, MdBlockType.heading);
      expect(blocks[0].level, 1);
      expect(blocks[0].text, 'Title');

      expect(blocks[1].type, MdBlockType.paragraph);
      expect(blocks[1].text, 'This is a paragraph.');

      expect(blocks[2].type, MdBlockType.heading);
      expect(blocks[2].level, 2);

      expect(blocks[3].type, MdBlockType.listItem);
      expect(blocks[3].text, 'Item A');

      expect(blocks[4].type, MdBlockType.listItem);
      expect(blocks[4].text, 'Item B');

      expect(blocks[5].type, MdBlockType.blockquote);
      expect(blocks[5].text, 'A quote');

      expect(blocks[6].type, MdBlockType.code);
      expect(blocks[6].text, 'code();');

      expect(blocks[7].type, MdBlockType.hr);

      expect(blocks[8].type, MdBlockType.orderedListItem);
      expect(blocks[8].text, 'First');

      expect(blocks[9].type, MdBlockType.orderedListItem);
      expect(blocks[9].text, 'Second');
    });

    test('handles empty lines between blocks', () {
      final md = '# Title\n\n\n\nParagraph after many blanks';
      final blocks = parser.parseBlocks(md);
      expect(blocks, hasLength(2));
      expect(blocks[0].type, MdBlockType.heading);
      expect(blocks[1].type, MdBlockType.paragraph);
    });
  });
}
