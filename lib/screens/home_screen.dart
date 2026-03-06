import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/file_provider.dart';
import '../providers/theme_provider.dart';
import '../services/history_service.dart';
import '../widgets/file_list_widget.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen>
    with SingleTickerProviderStateMixin {
  bool _isLoading = false;
  late AnimationController _fadeController;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..forward();
    _fadeAnim = CurvedAnimation(parent: _fadeController, curve: Curves.easeIn);
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  Future<void> _pickFile() async {
    setState(() => _isLoading = true);
    try {
      final file = await ref.read(fileProvider.notifier).pickFile();
      if (file != null && mounted) {
        Navigator.pushNamed(context, '/viewer', arguments: file);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _openFromHistory(String path) async {
    setState(() => _isLoading = true);
    try {
      final file = await ref.read(fileProvider.notifier).openFromHistory(path);
      if (file != null && mounted) {
        Navigator.pushNamed(context, '/viewer', arguments: file);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Could not open file: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeMode = ref.watch(themeProvider);
    final themeNotifier = ref.read(themeProvider.notifier);
    final recentFiles = ref.watch(recentFilesProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.article_outlined,
              color: theme.colorScheme.primary,
              size: 28,
            ),
            const SizedBox(width: 8),
            const Text('MD Viewer'),
          ],
        ),
        actions: [
          if (recentFiles.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_sweep_outlined),
              tooltip: 'Clear history',
              onPressed: () async {
                final confirm = await showDialog<bool>(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: const Text('Clear History'),
                    content: const Text(
                        'Remove all recently opened files from history?'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(ctx, false),
                        child: const Text('Cancel'),
                      ),
                      FilledButton(
                        onPressed: () => Navigator.pop(ctx, true),
                        child: const Text('Clear'),
                      ),
                    ],
                  ),
                );
                if (confirm == true) {
                  await HistoryService().clearHistory();
                  ref.invalidate(recentFilesProvider);
                }
              },
            ),
          Tooltip(
            message: 'Theme: ${themeNotifier.label}',
            child: IconButton(
              icon: AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                transitionBuilder: (child, anim) =>
                    RotationTransition(turns: anim, child: child),
                child: Icon(
                  themeNotifier.icon,
                  key: ValueKey(themeMode),
                ),
              ),
              onPressed: () => themeNotifier.toggleTheme(),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            tooltip: 'Settings',
            onPressed: () => Navigator.pushNamed(context, '/settings'),
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : FadeTransition(
              opacity: _fadeAnim,
              child: recentFiles.isEmpty
                  ? _buildEmptyState(theme)
                  : _buildRecentFilesList(theme, recentFiles),
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _isLoading ? null : _pickFile,
        icon: const Icon(Icons.folder_open),
        label: const Text('Open File'),
        heroTag: 'openFile',
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  Widget _buildRecentFilesList(
      ThemeData theme, List<dynamic> recentFiles) {
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
            child: Text(
              'Recent Files',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
              ),
            ),
          ),
        ),
        SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, index) {
              final file = recentFiles[index];
              return FileListWidget(
                fileName: file.name,
                filePath: file.path,
                fileSize: file.formattedSize,
                timeAgo: file.timeAgo,
                onTap: () => _openFromHistory(file.path),
                onDelete: () async {
                  await HistoryService().removeFromHistory(index);
                  ref.invalidate(recentFilesProvider);
                },
              );
            },
            childCount: recentFiles.length,
          ),
        ),
        const SliverToBoxAdapter(
          child: SizedBox(height: 80), // Space for FAB
        ),
      ],
    );
  }

  Widget _buildEmptyState(ThemeData theme) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Animated icon
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.0, end: 1.0),
              duration: const Duration(milliseconds: 800),
              curve: Curves.elasticOut,
              builder: (context, value, child) {
                return Transform.scale(
                  scale: value,
                  child: child,
                );
              },
              child: Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color:
                      theme.colorScheme.primaryContainer.withValues(alpha: 0.3),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.description_outlined,
                  size: 56,
                  color: theme.colorScheme.primary.withValues(alpha: 0.7),
                ),
              ),
            ),
            const SizedBox(height: 32),

            Text(
              'Welcome to MD Viewer',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),

            Text(
              'Open a Markdown file to get started.\n'
              'Supports .md and .markdown files up to 5 MB.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 48),

            // Feature chips
            Wrap(
              spacing: 8,
              runSpacing: 8,
              alignment: WrapAlignment.center,
              children: [
                _featureChip(theme, Icons.code, 'Code Blocks'),
                _featureChip(theme, Icons.format_bold, 'Rich Text'),
                _featureChip(theme, Icons.link, 'Links'),
                _featureChip(theme, Icons.table_chart, 'Tables'),
                _featureChip(theme, Icons.format_quote, 'Quotes'),
                _featureChip(theme, Icons.image_outlined, 'Images'),
              ],
            ),
            const SizedBox(height: 80), // Space for FAB
          ],
        ),
      ),
    );
  }

  Widget _featureChip(ThemeData theme, IconData icon, String label) {
    return Chip(
      avatar: Icon(icon, size: 16, color: theme.colorScheme.primary),
      label: Text(label, style: theme.textTheme.labelSmall),
      backgroundColor:
          theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
      side: BorderSide.none,
      padding: const EdgeInsets.symmetric(horizontal: 4),
    );
  }
}
