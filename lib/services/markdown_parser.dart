/// Represents a type of parsed markdown block.
enum MdBlockType { heading, paragraph, code, listItem, orderedListItem, blockquote, hr }

/// A single parsed markdown block with its type, text content, and optional level.
class MdBlock {
  final MdBlockType type;
  final String text;
  final int level; // heading level (1-6) or ordered list number

  const MdBlock(this.type, this.text, {this.level = 1});
}

/// Parses raw markdown into a list of [MdBlock]s for structured rendering.
class MarkdownParser {
  /// Parse markdown content into structured blocks.
  List<MdBlock> parseBlocks(String content) {
    final lines = content.split('\n');
    final blocks = <MdBlock>[];
    int i = 0;

    while (i < lines.length) {
      final line = lines[i];

      // Fenced code block (``` or ~~~)
      if (line.trimLeft().startsWith('```') || line.trimLeft().startsWith('~~~')) {
        final fence = line.trimLeft().substring(0, 3);
        final codeLines = <String>[];
        i++; // skip opening fence
        while (i < lines.length && !lines[i].trimLeft().startsWith(fence)) {
          codeLines.add(lines[i]);
          i++;
        }
        if (i < lines.length) i++; // skip closing fence
        blocks.add(MdBlock(MdBlockType.code, codeLines.join('\n')));
        continue;
      }

      // Heading (# ... ######)
      final headingMatch = RegExp(r'^(#{1,6})\s+(.+)$').firstMatch(line);
      if (headingMatch != null) {
        final level = headingMatch.group(1)!.length;
        final text = headingMatch.group(2)!;
        blocks.add(MdBlock(MdBlockType.heading, text, level: level));
        i++;
        continue;
      }

      // Horizontal rule (---, ***, ___)
      if (RegExp(r'^(\s*[-*_]\s*){3,}$').hasMatch(line)) {
        blocks.add(MdBlock(MdBlockType.hr, ''));
        i++;
        continue;
      }

      // Blockquote (> ...)
      if (line.trimLeft().startsWith('>')) {
        final quoteLines = <String>[];
        while (i < lines.length && lines[i].trimLeft().startsWith('>')) {
          quoteLines.add(lines[i].trimLeft().replaceFirst(RegExp(r'^>\s?'), ''));
          i++;
        }
        blocks.add(MdBlock(MdBlockType.blockquote, quoteLines.join('\n')));
        continue;
      }

      // Unordered list item (- or * or +)
      if (RegExp(r'^\s*[-*+]\s+').hasMatch(line)) {
        final listItems = <String>[];
        while (i < lines.length && RegExp(r'^\s*[-*+]\s+').hasMatch(lines[i])) {
          listItems.add(lines[i].replaceFirst(RegExp(r'^\s*[-*+]\s+'), ''));
          i++;
        }
        for (final item in listItems) {
          blocks.add(MdBlock(MdBlockType.listItem, item));
        }
        continue;
      }

      // Ordered list item (1. or 1) ...)
      if (RegExp(r'^\s*\d+[.)]\s+').hasMatch(line)) {
        final listItems = <String>[];
        while (i < lines.length && RegExp(r'^\s*\d+[.)]\s+').hasMatch(lines[i])) {
          listItems.add(lines[i].replaceFirst(RegExp(r'^\s*\d+[.)]\s+'), ''));
          i++;
        }
        int num = 1;
        for (final item in listItems) {
          blocks.add(MdBlock(MdBlockType.orderedListItem, item, level: num));
          num++;
        }
        continue;
      }

      // Empty line
      if (line.trim().isEmpty) {
        i++;
        continue;
      }

      // Regular paragraph
      final paraLines = <String>[];
      while (i < lines.length &&
          lines[i].trim().isNotEmpty &&
          !lines[i].trimLeft().startsWith('#') &&
          !lines[i].trimLeft().startsWith('>') &&
          !lines[i].trimLeft().startsWith('```') &&
          !lines[i].trimLeft().startsWith('~~~') &&
          !RegExp(r'^\s*[-*+]\s+').hasMatch(lines[i]) &&
          !RegExp(r'^\s*\d+[.)]\s+').hasMatch(lines[i]) &&
          !RegExp(r'^(\s*[-*_]\s*){3,}$').hasMatch(lines[i])) {
        paraLines.add(lines[i]);
        i++;
      }
      if (paraLines.isNotEmpty) {
        blocks.add(MdBlock(MdBlockType.paragraph, paraLines.join(' ')));
      } else {
        // Fallback: line didn't match any pattern — treat as single-line paragraph
        blocks.add(MdBlock(MdBlockType.paragraph, line));
        i++;
      }
    }

    return blocks;
  }
}
