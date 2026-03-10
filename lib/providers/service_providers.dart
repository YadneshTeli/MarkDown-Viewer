import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/export_service.dart';
import '../services/file_service.dart';
import '../services/history_service.dart';
import '../services/markdown_service.dart';
import '../services/search_service.dart';

/// Single-instance provider for [ExportService].
final exportServiceProvider = Provider<ExportService>((ref) {
  return ExportService();
});

/// Single-instance provider for [FileService].
final fileServiceProvider = Provider<FileService>((ref) {
  return FileService();
});

/// Single-instance provider for [HistoryService].
final historyServiceProvider = Provider<HistoryService>((ref) {
  return HistoryService();
});

/// Single-instance provider for [MarkdownService].
final markdownServiceProvider = Provider<MarkdownService>((ref) {
  return MarkdownService();
});

/// Single-instance provider for [SearchService].
final searchServiceProvider = Provider<SearchService>((ref) {
  return SearchService();
});
