import 'package:hive/hive.dart';
import '../models/markdown_file.dart';
import '../utils/constants.dart';

class HistoryService {
  Box<MarkdownFile> get _box => Hive.box<MarkdownFile>(AppConstants.recentFilesBox);

  /// Get all recent files, sorted by lastOpened (most recent first).
  List<MarkdownFile> getRecentFiles() {
    final files = _box.values.toList();
    files.sort((a, b) => b.lastOpened.compareTo(a.lastOpened));
    return files;
  }

  /// Add or update a file in history.
  Future<void> addToHistory(MarkdownFile file) async {
    // Remove existing entry with same path (dedup)
    final existing = _box.values.where((f) => f.path == file.path).toList();
    for (final entry in existing) {
      await entry.delete();
    }

    // Add the new entry (without content to save space)
    final historyEntry = file.copyForHistory();
    await _box.add(historyEntry);

    // Trim to max size
    await _trimHistory();
  }

  /// Remove a specific file from history.
  Future<void> removeFromHistory(int index) async {
    final files = getRecentFiles();
    if (index >= 0 && index < files.length) {
      await files[index].delete();
    }
  }

  /// Clear all history.
  Future<void> clearHistory() async {
    await _box.clear();
  }

  /// Keep only the most recent entries.
  Future<void> _trimHistory() async {
    final files = getRecentFiles();
    if (files.length > AppConstants.maxRecentFiles) {
      final toRemove = files.sublist(AppConstants.maxRecentFiles);
      for (final file in toRemove) {
        await file.delete();
      }
    }
  }
}
