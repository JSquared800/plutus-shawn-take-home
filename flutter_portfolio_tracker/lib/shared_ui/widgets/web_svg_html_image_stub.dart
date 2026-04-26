import 'package:flutter/widgets.dart';

class WebSvgHtmlImage extends StatelessWidget {
  const WebSvgHtmlImage({
    super.key,
    required this.url,
    required this.fallback,
  });

  final String url;
  final Widget fallback;

  @override
  Widget build(BuildContext context) => fallback;
}
