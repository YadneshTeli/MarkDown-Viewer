import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/markdown_file.dart';
import '../providers/search_provider.dart';
import '../providers/service_providers.dart';
import '../widgets/markdown_viewer_widget.dart';

class ViewerScreen extends ConsumerStatefulWidget {
  const ViewerScreen({super.key});

  @override
  ConsumerState<ViewerScreen> createState() => _ViewerScreenState();
}

class _ViewerScreenState extends ConsumerState<ViewerScreen> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  String? _processedContent;
  String? _error;
  bool _isProcessing = true;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_processedContent == null && _error == null) {
      _processContent();
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _processContent() {
    final mdFile =
        ModalRoute.of(context)?.settings.arguments as MarkdownFile?;

    if (mdFile == null) {
      setState(() {
        _error = 'No file data received.';
        _isProcessing = false;
      });
      return;
    }

    try {
      final markdownService = ref.read(markdownServiceProvider);
      final processed = markdownService.processContent(mdFile.content);
      setState(() {
        _processedContent = processed;
        _isProcessing = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isProcessing = false;
      });
    }
  }

  /// Scroll the markdown view to the approximate position of the given match.
  void _scrollToMatch(SearchState searchState) {
    if (_processedContent == null || !searchState.hasMatches) return;
    if (!_scrollController.hasClients) return;

    final match = searchState.currentMatch;
    if (match == null) return;

    // Estimate scroll position based on character offset ratio
    final contentLength = _processedContent!.length;
    if (contentLength == 0) return;

    final ratio = match.startIndex / contentLength;
    final maxScroll = _scrollController.position.maxScrollExtent;
    final targetOffset = (ratio * maxScroll).clamp(0.0, maxScroll);

    _scrollController.animateTo(
      targetOffset,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    final mdFile =
        ModalRoute.of(context)?.settings.arguments as MarkdownFile?;
    final theme = Theme.of(context);
    final searchState = ref.watch(searchProvider);

    // Listen for match index changes and scroll to match
    ref.listen<SearchState>(searchProvider, (previous, next) {
      if (next.hasMatches &&
          (previous?.currentMatchIndex != next.currentMatchIndex ||
              previous?.query != next.query)) {
        // Post-frame callback so the scroll extent is up to date
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _scrollToMatch(next);
        });
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: searchState.isActive
            ? _buildSearchBar(theme)
            : Text(
                mdFile?.name ?? 'Viewer',
                style: const TextStyle(fontSize: 16),
              ),
        actions: searchState.isActive
            ? _buildSearchActions(theme, searchState)
            : _buildDefaultActions(theme, mdFile),
      ),
      body: _buildBody(theme),
    );
  }

  Widget _buildSearchBar(ThemeData theme) {
    return TextField(
      controller: _searchController,
      autofocus: true,
      decoration: InputDecoration(
        hintText: 'Search in document...',
        border: InputBorder.none,
        filled: false,
        hintStyle: TextStyle(
          color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
        ),
      ),
      style: theme.textTheme.bodyLarge,
      onChanged: (query) {
        if (_processedContent != null) {
          ref.read(searchProvider.notifier).search(_processedContent!, query);
        }
      },
    );
  }

  List<Widget> _buildSearchActions(ThemeData theme, SearchState searchState) {
    return [
      if (searchState.hasMatches)
        Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Text(
              '${searchState.currentMatchIndex + 1}/${searchState.totalMatches}',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
          ),
        ),
      IconButton(
        icon: const Icon(Icons.keyboard_arrow_up),
        tooltip: 'Previous match',
        onPressed: searchState.hasMatches
            ? () => ref.read(searchProvider.notifier).previousMatch()
            : null,
      ),
      IconButton(
        icon: const Icon(Icons.keyboard_arrow_down),
        tooltip: 'Next match',
        onPressed: searchState.hasMatches
            ? () => ref.read(searchProvider.notifier).nextMatch()
            : null,
      ),
      IconButton(
        icon: const Icon(Icons.close),
        tooltip: 'Close search',
        onPressed: () {
          _searchController.clear();
          ref.read(searchProvider.notifier).deactivate();
        },
      ),
    ];
  }

  List<Widget> _buildDefaultActions(ThemeData theme, MarkdownFile? mdFile) {
    return [
      if (mdFile != null)
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Chip(
            avatar: const Icon(Icons.storage, size: 14),
            label: Text(
              mdFile.formattedSize,
              style: theme.textTheme.labelSmall,
            ),
            visualDensity: VisualDensity.compact,
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
        ),
      IconButton(
        icon: const Icon(Icons.search),
        tooltip: 'Search',
        onPressed: () => ref.read(searchProvider.notifier).activate(),
      ),
      PopupMenuButton<String>(
        icon: const Icon(Icons.more_vert),
        onSelected: (value) async {
          if (mdFile == null) return;
          final exportService = ref.read(exportServiceProvider);
          try {
            if (value == 'Share') {
              await exportService.shareMarkdown(
                content: _processedContent ?? mdFile.content,
                fileName: mdFile.name,
              );
            } else if (value == 'Export PDF') {
              await exportService.exportToPdf(
                content: _processedContent ?? mdFile.content,
                fileName: mdFile.name,
              );
            }
          } catch (e) {
            // Guard against async gaps
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Export failed: $e')),
              );
            }
          }
        },
        itemBuilder: (context) => [
          const PopupMenuItem(
            value: 'Share',
            child: ListTile(
              leading: Icon(Icons.share),
              title: Text('Share'),
              dense: true,
            ),
          ),
          const PopupMenuItem(
            value: 'Export PDF',
            child: ListTile(
              leading: Icon(Icons.picture_as_pdf),
              title: Text('Export PDF'),
              dense: true,
            ),
          ),
        ],
      ),
    ];
  }

  Widget _buildBody(ThemeData theme) {
    if (_isProcessing) {
      return const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Rendering markdown…'),
          ],
        ),
      );
    }

    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.error_outline,
                size: 64,
                color: theme.colorScheme.error,
              ),
              const SizedBox(height: 16),
              Text(
                'Failed to render',
                style: theme.textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              Text(
                _error!,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.arrow_back),
                label: const Text('Go Back'),
              ),
            ],
          ),
        ),
      );
    }

    final searchState = ref.watch(searchProvider);

    return Column(
      children: [
        // Search results info bar
        if (searchState.isActive && searchState.query.isNotEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            color: theme.colorScheme.surfaceContainerHighest,
            child: Text(
              searchState.hasMatches
                  ? 'Found ${searchState.totalMatches} match${searchState.totalMatches == 1 ? '' : 'es'} for "${searchState.query}"'
                  : 'No matches for "${searchState.query}"',
              style: theme.textTheme.bodySmall?.copyWith(
                color: searchState.hasMatches
                    ? theme.colorScheme.primary
                    : theme.colorScheme.error,
              ),
            ),
          ),

        // Search results panel with highlighted context snippets
        if (searchState.isActive && searchState.hasMatches)
          _buildSearchResultsPanel(theme, searchState),

        // Markdown content
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: MarkdownViewerWidget(
              content: _processedContent!,
              scrollController: _scrollController,
            ),
          ),
        ),
      ],
    );
  }

  /// Builds a compact, scrollable list of search result snippets with
  /// the matched text highlighted. Tapping a result navigates to it.
  Widget _buildSearchResultsPanel(ThemeData theme, SearchState searchState) {
    return Container(
      constraints: const BoxConstraints(maxHeight: 160),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLow,
        border: Border(
          bottom: BorderSide(
            color: theme.colorScheme.outlineVariant,
            width: 1,
          ),
        ),
      ),
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(vertical: 4),
        shrinkWrap: true,
        itemCount: searchState.matches.length,
        separatorBuilder: (_, _) => Divider(
          height: 1,
          indent: 16,
          endIndent: 16,
          color: theme.colorScheme.outlineVariant.withValues(alpha: 0.4),
        ),
        itemBuilder: (context, index) {
          final match = searchState.matches[index];
          final isCurrent = index == searchState.currentMatchIndex;

          return Material(
            color: isCurrent
                ? theme.colorScheme.primaryContainer.withValues(alpha: 0.5)
                : Colors.transparent,
            child: InkWell(
              onTap: () {
                ref.read(searchProvider.notifier).goToMatch(index);
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: Row(
                  children: [
                    // Match number indicator
                    Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: isCurrent
                            ? theme.colorScheme.primary
                            : theme.colorScheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        '${index + 1}',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: isCurrent
                              ? theme.colorScheme.onPrimary
                              : theme.colorScheme.onSurface,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Context snippet with highlighted match
                    Expanded(
                      child: _buildHighlightedContext(
                        theme,
                        match.context,
                        searchState.query,
                        isCurrent,
                      ),
                    ),
                    if (isCurrent)
                      Icon(
                        Icons.chevron_right,
                        size: 18,
                        color: theme.colorScheme.primary,
                      ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  /// Renders a context string with matching query text highlighted.
  Widget _buildHighlightedContext(
    ThemeData theme,
    String contextText,
    String query,
    bool isCurrent,
  ) {
    final lowerContext = contextText.toLowerCase();
    final lowerQuery = query.toLowerCase();
    final spans = <TextSpan>[];

    int start = 0;
    while (true) {
      final matchIndex = lowerContext.indexOf(lowerQuery, start);
      if (matchIndex == -1) {
        // Add the remaining text
        if (start < contextText.length) {
          spans.add(TextSpan(
            text: contextText.substring(start),
          ));
        }
        break;
      }

      // Add text before match
      if (matchIndex > start) {
        spans.add(TextSpan(
          text: contextText.substring(start, matchIndex),
        ));
      }

      // Add highlighted match
      spans.add(TextSpan(
        text: contextText.substring(matchIndex, matchIndex + query.length),
        style: TextStyle(
          backgroundColor: isCurrent
              ? theme.colorScheme.primary.withValues(alpha: 0.3)
              : theme.colorScheme.tertiary.withValues(alpha: 0.25),
          color: isCurrent
              ? theme.colorScheme.primary
              : theme.colorScheme.onSurface,
          fontWeight: FontWeight.bold,
        ),
      ));

      start = matchIndex + query.length;
    }

    return RichText(
      text: TextSpan(
        style: theme.textTheme.bodySmall?.copyWith(
          color: theme.colorScheme.onSurface.withValues(alpha: 0.8),
        ),
        children: spans,
      ),
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
    );
  }
}
