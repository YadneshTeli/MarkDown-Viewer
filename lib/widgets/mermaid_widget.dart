import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_android/webview_flutter_android.dart';

class MermaidWidget extends StatefulWidget {
  final String diagram;
  const MermaidWidget({super.key, required this.diagram});

  @override
  State<MermaidWidget> createState() => _MermaidWidgetState();
}

class _MermaidWidgetState extends State<MermaidWidget> {
  late final WebViewController _controller;
  double _height = 120;
  bool _loaded = false;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(Colors.transparent)
      ..addJavaScriptChannel(
        'MermaidHeight',
        onMessageReceived: (msg) {
          final h = double.tryParse(msg.message) ?? 120;
          if (mounted) {
            setState(() => _height = h + 16);
          }
        },
      )
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageFinished: (_) {
            if (mounted) {
              setState(() => _loaded = true);
              _loadDiagram();
            }
          },
        ),
      );
    _initWebView();
  }

  Future<void> _initWebView() async {
    try {
      final tempDir = await getTemporaryDirectory();
      final mermaidDir = Directory('${tempDir.path}/mermaid');
      if (!await mermaidDir.exists()) {
        await mermaidDir.create(recursive: true);
      }

      final htmlFile = File('${mermaidDir.path}/template.html');
      final jsFile = File('${mermaidDir.path}/mermaid.min.js');

      final htmlBytes = await rootBundle.load('assets/mermaid/template.html');
      final jsBytes = await rootBundle.load('assets/mermaid/mermaid.min.js');

      // Copy template.html if it doesn't exist or size is incorrect
      if (!await htmlFile.exists() || await htmlFile.length() != htmlBytes.lengthInBytes) {
        await htmlFile.writeAsBytes(
          htmlBytes.buffer.asUint8List(htmlBytes.offsetInBytes, htmlBytes.lengthInBytes),
          flush: true,
        );
      }

      // Copy mermaid.min.js if it doesn't exist or size is incorrect
      if (!await jsFile.exists() || await jsFile.length() != jsBytes.lengthInBytes) {
        await jsFile.writeAsBytes(
          jsBytes.buffer.asUint8List(jsBytes.offsetInBytes, jsBytes.lengthInBytes),
          flush: true,
        );
      }

      if (_controller.platform is AndroidWebViewController) {
        final androidController = _controller.platform as AndroidWebViewController;
        await androidController.setAllowFileAccess(true);
      }

      await _controller.enableZoom(false);
      await _controller.loadRequest(Uri.parse('file://${htmlFile.path}'));
    } catch (e) {
      if (mounted) {
        setState(() {
          _height = 80;
          _loaded = true;
        });
      }
    }
  }

  @override
  void didUpdateWidget(covariant MermaidWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.diagram != widget.diagram) {
      _loadDiagram();
    }
  }

  void _loadDiagram() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final escaped = widget.diagram
        .replaceAll(r'\', r'\\')
        .replaceAll('`', r'\`');
    _controller.runJavaScript('renderGraph(`$escaped`, $isDark);');
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: SizedBox(
        height: _height,
        child: Stack(
          children: [
            WebViewWidget(controller: _controller),
            if (!_loaded)
              const Center(
                child: SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
            if (_loaded)
              Positioned(
                top: 8,
                right: 8,
                child: Material(
                  color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.8),
                  borderRadius: BorderRadius.circular(8),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(8),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          fullscreenDialog: true,
                          builder: (context) => MermaidFullScreenViewer(
                            diagram: widget.diagram,
                          ),
                        ),
                      );
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Icon(
                        Icons.fullscreen,
                        size: 20,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class MermaidFullScreenViewer extends StatefulWidget {
  final String diagram;
  const MermaidFullScreenViewer({super.key, required this.diagram});

  @override
  State<MermaidFullScreenViewer> createState() => _MermaidFullScreenViewerState();
}

class _MermaidFullScreenViewerState extends State<MermaidFullScreenViewer> {
  late final WebViewController _controller;
  bool _loaded = false;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(Colors.transparent)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageFinished: (_) async {
            await _controller.runJavaScript('setZoomEnabled(true);');
            _loadDiagram();
            if (mounted) {
              setState(() => _loaded = true);
            }
          },
        ),
      );
    _initWebView();
  }

  Future<void> _initWebView() async {
    try {
      final tempDir = await getTemporaryDirectory();
      final htmlFile = File('${tempDir.path}/mermaid/template.html');

      if (_controller.platform is AndroidWebViewController) {
        final androidController = _controller.platform as AndroidWebViewController;
        await androidController.setAllowFileAccess(true);
      }

      await _controller.enableZoom(true);
      await _controller.loadRequest(Uri.parse('file://${htmlFile.path}'));
    } catch (e) {
      if (mounted) {
        setState(() {
          _loaded = true;
        });
      }
    }
  }

  void _loadDiagram() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final escaped = widget.diagram
        .replaceAll(r'\', r'\\')
        .replaceAll('`', r'\`');
    _controller.runJavaScript('renderGraph(`$escaped`, $isDark);');
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Diagram Viewer'),
        actions: [
          IconButton(
            icon: const Icon(Icons.zoom_out),
            tooltip: 'Zoom Out',
            onPressed: () {
              _controller.runJavaScript('zoomOut();');
            },
          ),
          IconButton(
            icon: const Icon(Icons.center_focus_strong),
            tooltip: 'Reset View',
            onPressed: () {
              _controller.runJavaScript('resetZoom();');
            },
          ),
          IconButton(
            icon: const Icon(Icons.zoom_in),
            tooltip: 'Zoom In',
            onPressed: () {
              _controller.runJavaScript('zoomIn();');
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Stack(
        children: [
          SafeArea(
            child: WebViewWidget(controller: _controller),
          ),
          if (!_loaded)
            const Center(
              child: CircularProgressIndicator(),
            ),
        ],
      ),
    );
  }
}
