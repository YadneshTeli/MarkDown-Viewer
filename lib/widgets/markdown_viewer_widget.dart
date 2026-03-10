import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:markdown_widget/markdown_widget.dart';
import 'package:url_launcher/url_launcher.dart';

import '../providers/search_provider.dart';

/// A themed markdown viewer that adapts to light/dark mode.
/// Supports remote images, SVG badges, HTML tags, custom styling,
/// and in-content search highlighting.
class MarkdownViewerWidget extends ConsumerWidget {
  final String content;
  final ScrollController? scrollController;

  const MarkdownViewerWidget({
    super.key,
    required this.content,
    this.scrollController,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final searchState = ref.watch(searchProvider);
    final theme = Theme.of(context);

    // Build the markdown generator — with highlight builder when search is active
    MarkdownGenerator generator;
    if (searchState.isActive && searchState.query.isNotEmpty) {
      final highlightQuery = searchState.query;
      generator = MarkdownGenerator(
        richTextBuilder: (InlineSpan span) {
          return _highlightedRichText(span, highlightQuery, theme);
        },
      );
    } else {
      generator = MarkdownGenerator();
    }

    final config = isDark ? _darkConfig(context) : _lightConfig(context);

    final markdownChild = MarkdownWidget(
      data: content,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      config: config,
      markdownGenerator: generator,
    );

    if (scrollController != null) {
      return SingleChildScrollView(
        controller: scrollController,
        child: markdownChild,
      );
    }

    return MarkdownWidget(
      data: content,
      shrinkWrap: false,
      config: config,
      markdownGenerator: generator,
    );
  }

  // ─── Search highlighting via richTextBuilder ──────────────────────

  /// Intercepts each `Text.rich(textSpan)` created by the markdown renderer,
  /// walks the span tree, and injects highlight backgrounds for matching text.
  Widget _highlightedRichText(InlineSpan span, String query, ThemeData theme) {
    if (span is TextSpan) {
      final highlighted = _highlightSpan(span, query, theme);
      return Text.rich(highlighted);
    }
    return Text.rich(span);
  }

  /// Recursively walks a [TextSpan] tree and splits any leaf spans
  /// that contain the search [query] into highlighted / non-highlighted parts.
  TextSpan _highlightSpan(TextSpan span, String query, ThemeData theme) {
    // If this span has children, recurse into them
    if (span.children != null && span.children!.isNotEmpty) {
      final recursedChildren = span.children!.map((child) {
        if (child is TextSpan) {
          return _highlightSpan(child, query, theme);
        }
        return child;
      }).toList();

      // If the parent span also has text, convert it to highlighted children
      // and prepend to the children list
      if (span.text != null && span.text!.isNotEmpty) {
        final textSegments = _splitByQuery(span.text!, query);
        final textChildren = textSegments.map((seg) {
          if (seg.isMatch) {
            return TextSpan(
              text: seg.text,
              style: (span.style ?? const TextStyle()).copyWith(
                backgroundColor: Colors.yellow.withValues(alpha: 0.6),
                color: Colors.black,
              ),
            );
          }
          return TextSpan(text: seg.text, style: span.style);
        }).toList();

        return TextSpan(
          style: span.style,
          children: [...textChildren, ...recursedChildren],
        );
      }

      return TextSpan(
        style: span.style,
        children: recursedChildren,
      );
    }

    // Leaf span with text — split it to highlight matches
    if (span.text != null && span.text!.isNotEmpty) {
      final segments = _splitByQuery(span.text!, query);
      if (segments.length == 1 && !segments.first.isMatch) {
        return span; // No match, return unchanged
      }

      return TextSpan(
        children: segments.map((seg) {
          if (seg.isMatch) {
            return TextSpan(
              text: seg.text,
              style: (span.style ?? const TextStyle()).copyWith(
                backgroundColor: Colors.yellow.withValues(alpha: 0.6),
                color: Colors.black,
              ),
            );
          }
          return TextSpan(text: seg.text, style: span.style);
        }).toList(),
      );
    }

    return span;
  }

  /// Splits [text] into segments, marking which ones match the [query].
  List<_TextSegment> _splitByQuery(String text, String query) {
    final lowerText = text.toLowerCase();
    final lowerQuery = query.toLowerCase();
    final segments = <_TextSegment>[];

    int start = 0;
    while (true) {
      final matchIndex = lowerText.indexOf(lowerQuery, start);
      if (matchIndex == -1) {
        if (start < text.length) {
          segments.add(_TextSegment(text.substring(start), false));
        }
        break;
      }

      if (matchIndex > start) {
        segments.add(_TextSegment(text.substring(start, matchIndex), false));
      }

      segments.add(_TextSegment(
        text.substring(matchIndex, matchIndex + query.length),
        true,
      ));

      start = matchIndex + query.length;
    }

    if (segments.isEmpty) {
      segments.add(_TextSegment(text, false));
    }

    return segments;
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

  String _normalizeImageUrl(String url) {
    if (url.contains('img.shields.io') || url.contains('shields.io')) {
      return url.replaceFirst('.svg?', '.png?').replaceFirst(
          RegExp(r'\.svg$'), '.png');
    }
    return url;
  }

  bool _isSvgUrl(String url) {
    final lower = url.toLowerCase();
    if (lower.contains('shields.io')) return false;
    if (lower.endsWith('.svg') ||
        lower.contains('.svg?') ||
        lower.contains('.svg&')) {
      return true;
    }
    return false;
  }

  bool _isBadge(String url) {
    final lower = url.toLowerCase();
    return lower.contains('img.shields.io') ||
        lower.contains('badge') ||
        lower.contains('shields');
  }

  Widget _buildImage(
      String url, Map<String, String> attributes, ThemeData theme) {
    if (url.isEmpty) return const SizedBox.shrink();

    final normalizedUrl = _normalizeImageUrl(url);
    final isBadge = _isBadge(url);
    final padding = EdgeInsets.symmetric(
      vertical: isBadge ? 2 : 8,
      horizontal: isBadge ? 2 : 0,
    );

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

/// Helper class to represent a text segment — either matching or non-matching.
class _TextSegment {
  final String text;
  final bool isMatch;

  const _TextSegment(this.text, this.isMatch);
}
