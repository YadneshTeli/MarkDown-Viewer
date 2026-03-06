class SearchResult {
  final int startIndex;
  final int endIndex;
  final String matchText;
  final String context;

  const SearchResult({
    required this.startIndex,
    required this.endIndex,
    required this.matchText,
    required this.context,
  });
}

class SearchService {
  /// Performs case-insensitive search and returns all match positions.
  List<SearchResult> search(String content, String query) {
    if (query.isEmpty || content.isEmpty) return [];

    final results = <SearchResult>[];
    final lowerContent = content.toLowerCase();
    final lowerQuery = query.toLowerCase();

    int searchFrom = 0;
    while (true) {
      final index = lowerContent.indexOf(lowerQuery, searchFrom);
      if (index == -1) break;

      // Extract surrounding context (up to 40 chars before and after)
      final contextStart = (index - 40).clamp(0, content.length);
      final contextEnd = (index + query.length + 40).clamp(0, content.length);
      final context = content.substring(contextStart, contextEnd).trim();

      results.add(SearchResult(
        startIndex: index,
        endIndex: index + query.length,
        matchText: content.substring(index, index + query.length),
        context: context,
      ));

      searchFrom = index + 1;
    }

    return results;
  }
}
