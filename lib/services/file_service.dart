import 'dart:io';
import 'package:file_picker/file_picker.dart';
import '../models/markdown_file.dart';
import '../utils/constants.dart';

class FileService {
  /// Opens the native file picker filtered to .md / .markdown files.
  /// Returns a [MarkdownFile] on success, or null if cancelled.
  Future<MarkdownFile?> pickMarkdownFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: AppConstants.allowedExtensions,
    );

    if (result == null || result.files.single.path == null) {
      return null;
    }

    final filePath = result.files.single.path!;
    return readMarkdownFile(filePath);
  }

  /// Reads a markdown file from the given [path].
  /// Throws if the file is too large or doesn't exist.
  Future<MarkdownFile> readMarkdownFile(String path) async {
    final file = File(path);

    if (!await file.exists()) {
      throw FileSystemException('File not found', path);
    }

    final fileSize = await file.length();
    if (fileSize > AppConstants.maxFileSizeBytes) {
      throw FileSystemException(
        'File too large (${(fileSize / (1024 * 1024)).toStringAsFixed(1)} MB). '
        'Maximum allowed is ${AppConstants.maxFileSizeBytes ~/ (1024 * 1024)} MB.',
        path,
      );
    }

    final content = await file.readAsString();
    return MarkdownFile.fromFile(file, content);
  }
}
