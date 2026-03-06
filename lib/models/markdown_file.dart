import 'dart:io';
import 'package:hive/hive.dart';

part 'markdown_file.g.dart';

@HiveType(typeId: 0)
class MarkdownFile extends HiveObject {
  @HiveField(0)
  final String name;

  @HiveField(1)
  final String path;

  @HiveField(2)
  final int size;

  @HiveField(3)
  String content;

  @HiveField(4)
  DateTime lastOpened;

  MarkdownFile({
    required this.name,
    required this.path,
    required this.size,
    required this.content,
    required this.lastOpened,
  });

  /// Create a MarkdownFile from a file path and its content.
  factory MarkdownFile.fromFile(File file, String content) {
    final fileName = file.path.split(Platform.pathSeparator).last;
    return MarkdownFile(
      name: fileName,
      path: file.path,
      size: content.length,
      content: content,
      lastOpened: DateTime.now(),
    );
  }

  /// Create a copy for history storage (preserves content for reopening).
  MarkdownFile copyForHistory() {
    return MarkdownFile(
      name: name,
      path: path,
      size: size,
      content: content, // Keep content — file_picker cache paths are temporary
      lastOpened: DateTime.now(),
    );
  }

  /// Human-readable file size string.
  String get formattedSize {
    if (size < 1024) return '$size B';
    if (size < 1024 * 1024) return '${(size / 1024).toStringAsFixed(1)} KB';
    return '${(size / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  /// Time-ago string for lastOpened.
  String get timeAgo {
    final diff = DateTime.now().difference(lastOpened);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return '${lastOpened.day}/${lastOpened.month}/${lastOpened.year}';
  }
}
