import 'package:flutter/material.dart';

/// A reusable list tile widget for displaying file entries.
class FileListWidget extends StatelessWidget {
  final String fileName;
  final String filePath;
  final String fileSize;
  final String timeAgo;
  final VoidCallback onTap;
  final VoidCallback? onDelete;

  const FileListWidget({
    super.key,
    required this.fileName,
    required this.filePath,
    required this.fileSize,
    required this.timeAgo,
    required this.onTap,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // File icon
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: theme.colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.description_outlined,
                  color: theme.colorScheme.primary,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),

              // File info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      fileName,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '$fileSize  •  $timeAgo',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                      ),
                    ),
                  ],
                ),
              ),

              // Delete button
              if (onDelete != null)
                IconButton(
                  icon: Icon(
                    Icons.close,
                    size: 18,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
                  ),
                  onPressed: onDelete,
                  tooltip: 'Remove from history',
                ),

              // Chevron
              Icon(
                Icons.chevron_right,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.3),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
