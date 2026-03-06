import 'dart:io';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';

class ExportService {
  /// Share the raw markdown content as a text file.
  Future<void> shareMarkdown({
    required String content,
    required String fileName,
  }) async {
    final tempDir = await getTemporaryDirectory();
    final file = File('${tempDir.path}/$fileName');
    await file.writeAsString(content);

    await Share.shareXFiles(
      [XFile(file.path)],
      subject: fileName,
    );
  }

  /// Copy markdown content to clipboard.
  Future<void> copyToClipboard(String content) async {
    await Clipboard.setData(ClipboardData(text: content));
  }
}
