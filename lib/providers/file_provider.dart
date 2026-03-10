import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/markdown_file.dart';
import '../services/file_service.dart';
import '../services/history_service.dart';
import 'service_providers.dart';

/// Manages the currently loaded file.
class FileNotifier extends AsyncNotifier<MarkdownFile?> {
  late final FileService _fileService;
  late final HistoryService _historyService;

  @override
  Future<MarkdownFile?> build() async {
    _fileService = ref.read(fileServiceProvider);
    _historyService = ref.read(historyServiceProvider);
    return null; // No file loaded initially
  }

  /// Pick a markdown file from device storage.
  Future<MarkdownFile?> pickFile() async {
    state = const AsyncLoading();
    try {
      final file = await _fileService.pickMarkdownFile();
      if (file != null) {
        await _historyService.addToHistory(file);
        state = AsyncData(file);
      } else {
        // User cancelled — restore previous state
        state = const AsyncData(null);
      }
      return file;
    } catch (e, st) {
      state = AsyncError(e, st);
      return null;
    }
  }

  /// Open a file from history by path.
  /// Falls back to stored content if the file no longer exists on disk
  /// (Android file_picker uses temporary cache paths).
  Future<MarkdownFile?> openFromHistory(String path) async {
    state = const AsyncLoading();
    try {
      // Try reading from disk first
      final file = await _fileService.readMarkdownFile(path);
      await _historyService.addToHistory(file);
      state = AsyncData(file);
      return file;
    } catch (_) {
      // File no longer on disk — use stored content from history
      try {
        final historyEntry = _historyService.getRecentFiles().firstWhere(
              (f) => f.path == path,
            );
        if (historyEntry.content.isNotEmpty) {
          historyEntry.lastOpened = DateTime.now();
          await historyEntry.save();
          state = AsyncData(historyEntry);
          return historyEntry;
        }
        state = AsyncError(
          'File not found and no stored content available.',
          StackTrace.current,
        );
        return null;
      } catch (e, st) {
        state = AsyncError(e, st);
        return null;
      }
    }
  }

  /// Clear the current file.
  void clearFile() {
    state = const AsyncData(null);
  }

  /// Open a file directly from [path] — used when launched via "Open with".
  Future<MarkdownFile?> openFromPath(String path) async {
    state = const AsyncLoading();
    try {
      final file = await _fileService.readMarkdownFile(path);
      await _historyService.addToHistory(file);
      state = AsyncData(file);
      return file;
    } catch (e, st) {
      state = AsyncError(e, st);
      return null;
    }
  }
}

final fileProvider = AsyncNotifierProvider<FileNotifier, MarkdownFile?>(
  FileNotifier.new,
);

/// Provider for recent files list.
final recentFilesProvider = Provider<List<MarkdownFile>>((ref) {
  // Watch the file provider to refresh when files are opened
  ref.watch(fileProvider);
  final historyService = ref.read(historyServiceProvider);
  return historyService.getRecentFiles();
});
