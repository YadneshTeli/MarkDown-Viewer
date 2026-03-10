import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/search_service.dart';
import 'service_providers.dart';

class SearchState {
  final String query;
  final List<SearchResult> matches;
  final int currentMatchIndex;
  final bool isActive;

  const SearchState({
    this.query = '',
    this.matches = const [],
    this.currentMatchIndex = 0,
    this.isActive = false,
  });

  int get totalMatches => matches.length;
  bool get hasMatches => matches.isNotEmpty;

  SearchResult? get currentMatch {
    if (matches.isEmpty || currentMatchIndex >= matches.length) return null;
    return matches[currentMatchIndex];
  }

  SearchState copyWith({
    String? query,
    List<SearchResult>? matches,
    int? currentMatchIndex,
    bool? isActive,
  }) {
    return SearchState(
      query: query ?? this.query,
      matches: matches ?? this.matches,
      currentMatchIndex: currentMatchIndex ?? this.currentMatchIndex,
      isActive: isActive ?? this.isActive,
    );
  }
}

class SearchNotifier extends Notifier<SearchState> {
  late final SearchService _searchService;

  @override
  SearchState build() {
    _searchService = ref.read(searchServiceProvider);
    return const SearchState();
  }

  /// Start search mode.
  void activate() {
    state = state.copyWith(isActive: true);
  }

  /// Close search mode and clear results.
  void deactivate() {
    state = const SearchState();
  }

  /// Perform search on content.
  void search(String content, String query) {
    if (query.isEmpty) {
      state = state.copyWith(query: '', matches: [], currentMatchIndex: 0);
      return;
    }

    final results = _searchService.search(content, query);
    state = state.copyWith(
      query: query,
      matches: results,
      currentMatchIndex: results.isEmpty ? 0 : 0,
    );
  }

  /// Move to next match.
  void nextMatch() {
    if (!state.hasMatches) return;
    final next = (state.currentMatchIndex + 1) % state.totalMatches;
    state = state.copyWith(currentMatchIndex: next);
  }

  /// Move to previous match.
  void previousMatch() {
    if (!state.hasMatches) return;
    final prev = state.currentMatchIndex == 0
        ? state.totalMatches - 1
        : state.currentMatchIndex - 1;
    state = state.copyWith(currentMatchIndex: prev);
  }

  /// Jump to a specific match by index.
  void goToMatch(int index) {
    if (!state.hasMatches) return;
    if (index < 0 || index >= state.totalMatches) return;
    state = state.copyWith(currentMatchIndex: index);
  }
}

final searchProvider = NotifierProvider<SearchNotifier, SearchState>(
  SearchNotifier.new,
);
