import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nusta_md/providers/search_provider.dart';

void main() {
  late ProviderContainer container;

  setUp(() {
    container = ProviderContainer();
  });

  tearDown(() {
    container.dispose();
  });

  group('SearchState', () {
    test('initial state is inactive with no matches', () {
      const state = SearchState();
      expect(state.isActive, isFalse);
      expect(state.query, isEmpty);
      expect(state.matches, isEmpty);
      expect(state.hasMatches, isFalse);
      expect(state.totalMatches, 0);
      expect(state.currentMatch, isNull);
      expect(state.currentMatchIndex, 0);
    });

    test('copyWith preserves unmodified fields', () {
      const state = SearchState(query: 'hello', isActive: true);
      final updated = state.copyWith(isActive: false);
      expect(updated.query, 'hello');
      expect(updated.isActive, isFalse);
    });
  });

  group('SearchNotifier', () {
    test('activate sets isActive to true', () {
      final notifier = container.read(searchProvider.notifier);
      notifier.activate();

      final state = container.read(searchProvider);
      expect(state.isActive, isTrue);
    });

    test('deactivate resets state completely', () {
      final notifier = container.read(searchProvider.notifier);
      notifier.activate();
      notifier.search('Hello world foo', 'o');
      notifier.deactivate();

      final state = container.read(searchProvider);
      expect(state.isActive, isFalse);
      expect(state.query, isEmpty);
      expect(state.matches, isEmpty);
      expect(state.currentMatchIndex, 0);
    });

    test('search with empty query clears results', () {
      final notifier = container.read(searchProvider.notifier);
      notifier.search('Hello world', 'world');
      expect(container.read(searchProvider).hasMatches, isTrue);

      notifier.search('Hello world', '');
      final state = container.read(searchProvider);
      expect(state.query, isEmpty);
      expect(state.matches, isEmpty);
    });

    test('search finds matches and sets currentMatchIndex to 0', () {
      final notifier = container.read(searchProvider.notifier);
      notifier.search('Hello world hello', 'hello');

      final state = container.read(searchProvider);
      expect(state.query, 'hello');
      expect(state.totalMatches, 2);
      expect(state.currentMatchIndex, 0);
      expect(state.hasMatches, isTrue);
    });

    test('nextMatch cycles forward through matches', () {
      final notifier = container.read(searchProvider.notifier);
      notifier.search('a b a c a', 'a');

      expect(container.read(searchProvider).totalMatches, 3);
      expect(container.read(searchProvider).currentMatchIndex, 0);

      notifier.nextMatch();
      expect(container.read(searchProvider).currentMatchIndex, 1);

      notifier.nextMatch();
      expect(container.read(searchProvider).currentMatchIndex, 2);

      // Wraps around
      notifier.nextMatch();
      expect(container.read(searchProvider).currentMatchIndex, 0);
    });

    test('previousMatch cycles backward through matches', () {
      final notifier = container.read(searchProvider.notifier);
      notifier.search('a b a c a', 'a');

      expect(container.read(searchProvider).currentMatchIndex, 0);

      // Wraps to last
      notifier.previousMatch();
      expect(container.read(searchProvider).currentMatchIndex, 2);

      notifier.previousMatch();
      expect(container.read(searchProvider).currentMatchIndex, 1);

      notifier.previousMatch();
      expect(container.read(searchProvider).currentMatchIndex, 0);
    });

    test('nextMatch does nothing when no matches', () {
      final notifier = container.read(searchProvider.notifier);
      notifier.search('hello', 'xyz');
      notifier.nextMatch();

      expect(container.read(searchProvider).currentMatchIndex, 0);
    });

    test('previousMatch does nothing when no matches', () {
      final notifier = container.read(searchProvider.notifier);
      notifier.search('hello', 'xyz');
      notifier.previousMatch();

      expect(container.read(searchProvider).currentMatchIndex, 0);
    });

    test('goToMatch jumps to specific index', () {
      final notifier = container.read(searchProvider.notifier);
      notifier.search('a b a c a d a', 'a');

      expect(container.read(searchProvider).totalMatches, 4);

      notifier.goToMatch(2);
      expect(container.read(searchProvider).currentMatchIndex, 2);

      notifier.goToMatch(0);
      expect(container.read(searchProvider).currentMatchIndex, 0);

      notifier.goToMatch(3);
      expect(container.read(searchProvider).currentMatchIndex, 3);
    });

    test('goToMatch ignores invalid indices', () {
      final notifier = container.read(searchProvider.notifier);
      notifier.search('a b a', 'a');

      notifier.goToMatch(1);
      expect(container.read(searchProvider).currentMatchIndex, 1);

      // Negative index — should not change
      notifier.goToMatch(-1);
      expect(container.read(searchProvider).currentMatchIndex, 1);

      // Out of bounds — should not change
      notifier.goToMatch(99);
      expect(container.read(searchProvider).currentMatchIndex, 1);
    });

    test('goToMatch does nothing when no matches', () {
      final notifier = container.read(searchProvider.notifier);
      notifier.search('hello', 'xyz');
      notifier.goToMatch(0);

      expect(container.read(searchProvider).currentMatchIndex, 0);
    });

    test('new search resets currentMatchIndex', () {
      final notifier = container.read(searchProvider.notifier);
      notifier.search('a b a c a', 'a');
      notifier.goToMatch(2);
      expect(container.read(searchProvider).currentMatchIndex, 2);

      // New search resets to 0
      notifier.search('a b a c a', 'b');
      expect(container.read(searchProvider).currentMatchIndex, 0);
    });
  });
}
