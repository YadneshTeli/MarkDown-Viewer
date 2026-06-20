import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

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
      )
      ..loadFlutterAsset('assets/mermaid/template.html');
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
    return SizedBox(
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
        ],
      ),
    );
  }
}
