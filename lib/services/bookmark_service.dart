import 'package:hive/hive.dart';
import '../utils/constants.dart';

part 'bookmark_service.g.dart';

@HiveType(typeId: 1)
class Bookmark extends HiveObject {
  @HiveField(0)
  final String filePath;

  @HiveField(1)
  final String heading;

  @HiveField(2)
  final double scrollPosition;

  @HiveField(3)
  final DateTime createdAt;

  Bookmark({
    required this.filePath,
    required this.heading,
    required this.scrollPosition,
    required this.createdAt,
  });
}

class BookmarkService {
  Box<Bookmark> get _box => Hive.box<Bookmark>(AppConstants.bookmarksBox);

  /// Get all bookmarks for a specific file.
  List<Bookmark> getBookmarks(String filePath) {
    return _box.values.where((b) => b.filePath == filePath).toList()
      ..sort((a, b) => a.scrollPosition.compareTo(b.scrollPosition));
  }

  /// Add a bookmark.
  Future<void> addBookmark({
    required String filePath,
    required String heading,
    required double scrollPosition,
  }) async {
    // Avoid duplicates for same heading in same file
    final existing = _box.values.where(
      (b) => b.filePath == filePath && b.heading == heading,
    );
    if (existing.isNotEmpty) return;

    await _box.add(Bookmark(
      filePath: filePath,
      heading: heading,
      scrollPosition: scrollPosition,
      createdAt: DateTime.now(),
    ));
  }

  /// Remove a bookmark.
  Future<void> removeBookmark(Bookmark bookmark) async {
    await bookmark.delete();
  }

  /// Check if a heading is bookmarked for a file.
  bool isBookmarked(String filePath, String heading) {
    return _box.values.any(
      (b) => b.filePath == filePath && b.heading == heading,
    );
  }

  /// Clear all bookmarks for a file.
  Future<void> clearBookmarks(String filePath) async {
    final toDelete =
        _box.values.where((b) => b.filePath == filePath).toList();
    for (final b in toDelete) {
      await b.delete();
    }
  }
}
