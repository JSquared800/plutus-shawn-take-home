import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_portfolio_tracker/app/theme/app_colors.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_portfolio_tracker/shared_ui/widgets/web_svg_html_image_stub.dart'
    if (dart.library.html)
        'package:flutter_portfolio_tracker/shared_ui/widgets/web_svg_html_image_web.dart';

class CoinIcon extends StatelessWidget {
  const CoinIcon({
    super.key,
    required this.apiCoin,
    this.size = 28,
    this.circular = false,
  });

  final String apiCoin;
  final double size;
  final bool circular;

  static const _baseUrl = 'https://app.hyperliquid.xyz/coins';

  @override
  Widget build(BuildContext context) {
    final borderRadius = circular ? size / 2 : 10.0;
    final iconUrl = '$_baseUrl/$apiCoin.svg';
    final fallback = _FallbackLabel(
      apiCoin: apiCoin,
      circular: circular,
    );

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: AppColors.genericIconBg,
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(color: AppColors.genericIconBdr, width: 1),
      ),
      clipBehavior: Clip.antiAlias,
      child: kIsWeb
          ? WebSvgHtmlImage(url: iconUrl, fallback: fallback)
          : SvgPicture.network(
              iconUrl,
              fit: BoxFit.cover,
              placeholderBuilder: (_) => const SizedBox.shrink(),
              errorBuilder: (_, __, ___) => fallback,
            ),
    );
  }
}

class _FallbackLabel extends StatelessWidget {
  const _FallbackLabel({required this.apiCoin, required this.circular});

  final String apiCoin;
  final bool circular;

  @override
  Widget build(BuildContext context) {
    final rawLabel = apiCoin.contains(':') ? apiCoin.split(':').last : apiCoin;
    final label = rawLabel.length > 3 ? rawLabel.substring(0, 3) : rawLabel;

    return Center(
      child: Text(
        label,
        style: TextStyle(
          fontFamily: 'Inter',
          fontSize: circular ? 9 : 10,
          fontWeight: FontWeight.w700,
          color: AppColors.genericIconFg,
          letterSpacing: 0.2,
        ),
      ),
    );
  }
}
