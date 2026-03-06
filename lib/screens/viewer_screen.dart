import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/markdown_file.dart';
import '../providers/search_provider.dart';
import '../services/export_service.dart';
import '../services/markdown_service.dart';
import '../widgets/markdown_viewer_widget.dart';

class ViewerScreen extends ConsumerStatefulWidget {
  const ViewerScreen({super.key});

  @override
  ConsumerState<ViewerScreen> createState() => _ViewerScreenState();
}

class _ViewerScreenState extends ConsumerState<ViewerScreen> {
  final MarkdownService _markdownService = MarkdownService();
  final TextEditingController _searchController = TextEditingController();
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
      final processed = _markdownService.processContent(mdFile.content);
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

  @override
  Widget build(BuildContext context) {
    final mdFile =
        ModalRoute.of(context)?.settings.arguments as MarkdownFile?;
    final theme = Theme.of(context);
    final searchState = ref.watch(searchProvider);

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
          final exportService = ExportService();
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

        // Markdown content
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: MarkdownViewerWidget(content: _processedContent!),
          ),
        ),
      ],
    );
  }
}
