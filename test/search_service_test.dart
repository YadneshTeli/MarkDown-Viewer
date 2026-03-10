import 'package:flutter_test/flutter_test.dart';
import 'package:nusta_md/services/search_service.dart';

void main() {
  late SearchService searchService;

  setUp(() {
    searchService = SearchService();
  });

  group('SearchService.search', () {
    test('returns empty list for empty query', () {
      final results = searchService.search('Hello world', '');
      expect(results, isEmpty);
    });

    test('returns empty list for empty content', () {
      final results = searchService.search('', 'hello');
      expect(results, isEmpty);
    });

    test('returns empty list when no match is found', () {
      final results = searchService.search('Hello world', 'xyz');
      expect(results, isEmpty);
    });

    test('finds a single match', () {
      final results = searchService.search('Hello world', 'world');
      expect(results, hasLength(1));
      expect(results[0].matchText, 'world');
      expect(results[0].startIndex, 6);
      expect(results[0].endIndex, 11);
    });

    test('finds multiple matches', () {
      final results = searchService.search('foo bar foo baz foo', 'foo');
      expect(results, hasLength(3));
      expect(results[0].startIndex, 0);
      expect(results[1].startIndex, 8);
      expect(results[2].startIndex, 16);
    });

    test('search is case-insensitive', () {
      final results = searchService.search('Hello HELLO hello', 'hello');
      expect(results, hasLength(3));
      expect(results[0].matchText, 'Hello');
      expect(results[1].matchText, 'HELLO');
      expect(results[2].matchText, 'hello');
    });

    test('returns correct context around match', () {
      final content = 'A short text with a keyword in it.';
      final results = searchService.search(content, 'keyword');
      expect(results, hasLength(1));
      // Context should contain surrounding text
      expect(results[0].context, contains('keyword'));
      expect(results[0].context, contains('with a'));
    });

    test('handles overlapping positions correctly', () {
      // "aa" in "aaa" should find positions 0 and 1
      final results = searchService.search('aaa', 'aa');
      expect(results, hasLength(2));
      expect(results[0].startIndex, 0);
      expect(results[1].startIndex, 1);
    });

    test('handles query at the very beginning', () {
      final results = searchService.search('start of text', 'start');
      expect(results, hasLength(1));
      expect(results[0].startIndex, 0);
      expect(results[0].endIndex, 5);
    });

    test('handles query at the very end', () {
      final results = searchService.search('end of text', 'text');
      expect(results, hasLength(1));
      expect(results[0].startIndex, 7);
      expect(results[0].endIndex, 11);
    });
  });
}
