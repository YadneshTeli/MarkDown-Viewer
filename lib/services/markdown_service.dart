class MarkdownService {
  /// Validates that the content is non-empty and suitable for rendering.
  /// Returns the processed content string.
  String processContent(String rawContent) {
    if (rawContent.trim().isEmpty) {
      throw FormatException('The markdown file is empty.');
    }
    return _stripFrontMatter(rawContent);
  }

  /// Strips YAML front-matter (--- delimited blocks at the start of the file).
  String _stripFrontMatter(String content) {
    final trimmed = content.trimLeft();
    if (!trimmed.startsWith('---')) return content;

    // Find the closing ---
    final endIndex = trimmed.indexOf('---', 3);
    if (endIndex == -1) return content;

    // Return everything after the front-matter block
    final afterFrontMatter = trimmed.substring(endIndex + 3).trimLeft();
    return afterFrontMatter.isEmpty ? content : afterFrontMatter;
  }
}
