// ignore_for_file: deprecated_member_use, avoid_web_libraries_in_flutter

import 'dart:html' as html;
import 'dart:ui_web' as ui_web;

import 'package:flutter/widgets.dart';

class WebSvgHtmlImage extends StatefulWidget {
  const WebSvgHtmlImage({
    super.key,
    required this.url,
    required this.fallback,
  });

  final String url;
  final Widget fallback;

  @override
  State<WebSvgHtmlImage> createState() => _WebSvgHtmlImageState();
}

class _WebSvgHtmlImageState extends State<WebSvgHtmlImage> {
  static int _idCounter = 0;

  late final String _viewType;
  late final html.ImageElement _img;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _viewType = 'coin-svg-img-${_idCounter++}';

    _img = html.ImageElement()
      ..src = widget.url
      ..style.width = '100%'
      ..style.height = '100%'
      ..style.objectFit = 'cover'
      ..style.display = 'block';

    _img.onError.listen((_) {
      if (!mounted) return;
      setState(() => _hasError = true);
    });

    ui_web.platformViewRegistry.registerViewFactory(_viewType, (_) => _img);
  }

  @override
  void didUpdateWidget(WebSvgHtmlImage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.url != widget.url) {
      _hasError = false;
      _img.src = widget.url;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_hasError) return widget.fallback;
    return HtmlElementView(viewType: _viewType);
  }
}
