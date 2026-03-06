import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:markdown_widget/markdown_widget.dart';
import 'package:url_launcher/url_launcher.dart';

/// A themed markdown viewer that adapts to light/dark mode.
/// Supports remote images, SVG badges, HTML tags, and custom styling.
class MarkdownViewerWidget extends StatelessWidget {
  final String content;

  const MarkdownViewerWidget({
    super.key,
    required this.content,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return MarkdownWidget(
      data: content,
      shrinkWrap: false,
      config: isDark ? _darkConfig(context) : _lightConfig(context),
    );
  }

  // ─── Shared image config used by both themes ────────────────────────

  ImgConfig _imgConfig(ThemeData theme) {
    return ImgConfig(
      errorBuilder: (url, alt, error) => _buildImageError(theme, alt),
      builder: (url, attributes) => _buildImage(url, attributes, theme),
    );
  }

  // ─── Light theme config ─────────────────────────────────────────────

  MarkdownConfig _lightConfig(BuildContext context) {
    final theme = Theme.of(context);
    return MarkdownConfig(
      configs: [
        H1Config(
          style: theme.textTheme.headlineLarge!.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.primary,
          ),
        ),
        H2Config(
          style: theme.textTheme.headlineMedium!.copyWith(
            fontWeight: FontWeight.w600,
            color: theme.colorScheme.primary.withValues(alpha: 0.85),
          ),
        ),
        H3Config(
          style: theme.textTheme.headlineSmall!.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        PConfig(
          textStyle: theme.textTheme.bodyLarge!.copyWith(height: 1.6),
        ),
        PreConfig(
          theme: {
            'root': TextStyle(
              color: const Color(0xFF24292E),
              backgroundColor: const Color(0xFFF6F8FA),
              fontSize: 14,
            ),
          },
          decoration: BoxDecoration(
            color: const Color(0xFFF6F8FA),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey.shade300),
          ),
        ),
        BlockquoteConfig(
          sideColor: theme.colorScheme.primary,
          textColor: theme.colorScheme.onSurface.withValues(alpha: 0.7),
        ),
        LinkConfig(
          style: TextStyle(
            color: theme.colorScheme.primary,
            decoration: TextDecoration.underline,
          ),
          onTap: _handleLinkTap,
        ),
        TableConfig(
          headerStyle: theme.textTheme.bodyMedium!
              .copyWith(fontWeight: FontWeight.bold),
          bodyStyle: theme.textTheme.bodyMedium!,
          border: TableBorder.all(color: Colors.grey.shade300, width: 1),
        ),
        _imgConfig(theme),
        HrConfig(color: Colors.grey.shade300, height: 1),
      ],
    );
  }

  // ─── Dark theme config ──────────────────────────────────────────────

  MarkdownConfig _darkConfig(BuildContext context) {
    final theme = Theme.of(context);
    return MarkdownConfig(
      configs: [
        H1Config(
          style: theme.textTheme.headlineLarge!.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.primary,
          ),
        ),
        H2Config(
          style: theme.textTheme.headlineMedium!.copyWith(
            fontWeight: FontWeight.w600,
            color: theme.colorScheme.primary.withValues(alpha: 0.9),
          ),
        ),
        H3Config(
          style: theme.textTheme.headlineSmall!.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        PConfig(
          textStyle: theme.textTheme.bodyLarge!.copyWith(height: 1.6),
        ),
        PreConfig(
          theme: {
            'root': TextStyle(
              color: const Color(0xFFE1E4E8),
              backgroundColor: const Color(0xFF2D2D2D),
              fontSize: 14,
            ),
          },
          decoration: BoxDecoration(
            color: const Color(0xFF2D2D2D),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey.shade700),
          ),
        ),
        BlockquoteConfig(
          sideColor: theme.colorScheme.primary,
          textColor: theme.colorScheme.onSurface.withValues(alpha: 0.7),
        ),
        LinkConfig(
          style: TextStyle(
            color: theme.colorScheme.primary,
            decoration: TextDecoration.underline,
          ),
          onTap: _handleLinkTap,
        ),
        TableConfig(
          headerStyle: theme.textTheme.bodyMedium!
              .copyWith(fontWeight: FontWeight.bold),
          bodyStyle: theme.textTheme.bodyMedium!,
          border: TableBorder.all(color: Colors.grey.shade700, width: 1),
        ),
        _imgConfig(theme),
        HrConfig(color: Colors.grey.shade700, height: 1),
      ],
    );
  }

  // ─── Image handling ─────────────────────────────────────────────────

  /// Converts shields.io SVG URLs to PNG for proper raster rendering.
  /// shields.io supports .svg, .png, .json — just swap the extension.
  String _normalizeImageUrl(String url) {
    if (url.contains('img.shields.io') || url.contains('shields.io')) {
      // Replace .svg with .png in the path (before query params)
      return url.replaceFirst('.svg?', '.png?').replaceFirst(
          RegExp(r'\.svg$'), '.png');
    }
    return url;
  }

  /// Determines whether a URL points to a true SVG (not shields.io).
  bool _isSvgUrl(String url) {
    final lower = url.toLowerCase();
    // shields.io is handled separately via PNG conversion
    if (lower.contains('shields.io')) return false;
    if (lower.endsWith('.svg') ||
        lower.contains('.svg?') ||
        lower.contains('.svg&')) {
      return true;
    }
    return false;
  }

  /// Detects if the image is a small inline badge.
  bool _isBadge(String url) {
    final lower = url.toLowerCase();
    return lower.contains('img.shields.io') ||
        lower.contains('badge') ||
        lower.contains('shields');
  }

  /// Builds the appropriate image widget based on URL type.
  Widget _buildImage(
      String url, Map<String, String> attributes, ThemeData theme) {
    if (url.isEmpty) return const SizedBox.shrink();

    final normalizedUrl = _normalizeImageUrl(url);
    final isBadge = _isBadge(url);
    final padding = EdgeInsets.symmetric(
      vertical: isBadge ? 2 : 8,
      horizontal: isBadge ? 2 : 0,
    );

    // True SVG files (not shields.io) — render with flutter_svg
    if (_isSvgUrl(normalizedUrl)) {
      return Padding(
        padding: padding,
        child: SvgPicture.network(
          normalizedUrl,
          height: isBadge ? 28 : null,
          fit: isBadge ? BoxFit.contain : BoxFit.fitWidth,
          placeholderBuilder: (context) => _buildLoadingIndicator(isBadge),
        ),
      );
    }

    // Raster image (PNG, JPG, or shields.io converted to PNG)
    return Padding(
      padding: padding,
      child: Image.network(
        normalizedUrl,
        fit: isBadge ? BoxFit.contain : BoxFit.fitWidth,
        height: isBadge ? 28 : null,
        loadingBuilder: (context, child, progress) {
          if (progress == null) return child;
          return _buildLoadingIndicator(isBadge);
        },
        errorBuilder: (context, error, stackTrace) {
          return _buildImageError(theme, attributes['alt'] ?? '');
        },
      ),
    );
  }

  Widget _buildLoadingIndicator(bool isBadge) {
    return SizedBox(
      height: isBadge ? 28 : 80,
      child: const Center(
        child: SizedBox(
          width: 14,
          height: 14,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      ),
    );
  }

  /// Shows a styled fallback chip when an image fails to load.
  Widget _buildImageError(ThemeData theme, String alt) {
    if (alt.isNotEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 2),
        child: Chip(
          avatar: Icon(Icons.image_not_supported,
              size: 14, color: theme.colorScheme.onSurfaceVariant),
          label: Text(
            alt,
            style: theme.textTheme.labelSmall
                ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
          ),
          backgroundColor: theme.colorScheme.surfaceContainerHighest,
          visualDensity: VisualDensity.compact,
          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          side: BorderSide.none,
          padding: EdgeInsets.zero,
        ),
      );
    }
    return const SizedBox.shrink();
  }

  void _handleLinkTap(String url) async {
    final uri = Uri.tryParse(url);
    if (uri != null && await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }
}
