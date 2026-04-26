import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_portfolio_tracker/app/theme/app_colors.dart';
import 'package:flutter_portfolio_tracker/app/theme/app_text_styles.dart';
import 'package:flutter_portfolio_tracker/features/market/domain/entities/asset_ticker.dart';
import 'package:flutter_portfolio_tracker/features/market/presentation/providers/market_providers.dart';
import 'package:flutter_portfolio_tracker/core/utils/num_formatters.dart';
import 'package:flutter_portfolio_tracker/shared_ui/widgets/coin_icon.dart';

class AssetRow extends ConsumerWidget {
  const AssetRow({
    super.key,
    required this.ticker,
    this.onTap,
  });

  final AssetTicker ticker;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Only this widget rebuilds when this specific coin's price changes.
    final livePrice = ref.watch(
      liveMidsProvider.select((mids) => mids[ticker.coin]),
    );
    final displayPx = livePrice ?? ticker.markPx;

    final changeColor =
        ticker.isPositive ? AppColors.positive : AppColors.negativeLight;
    final changeBg = ticker.isPositive
        ? AppColors.positive.withValues(alpha: 0.10)
        : AppColors.negative.withValues(alpha: 0.10);

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Row(
          children: [
            CoinIcon(apiCoin: ticker.coin, size: 36, circular: true),
            const SizedBox(width: 12),
            Expanded(
              flex: 3,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(ticker.coin,
                            style: AppTextStyles.rowPrimary,
                            overflow: TextOverflow.ellipsis),
                      ),
                      if (!ticker.isDefaultDex) ...[
                        const SizedBox(width: 5),
                        _DexBadge(dex: ticker.dex),
                      ],
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Vol ${NumFormatters.usdCompact(ticker.volume24h)}',
                    style: AppTextStyles.rowSecondary,
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  NumFormatters.price(displayPx),
                  style: AppTextStyles.rowPrice,
                ),
                const SizedBox(height: 4),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: changeBg,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    '${NumFormatters.changeSigned(ticker.change24hPct)}%',
                    style: AppTextStyles.rowChange.copyWith(color: changeColor),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _DexBadge extends StatelessWidget {
  const _DexBadge({required this.dex});
  final String dex;

  @override
  Widget build(BuildContext context) {
    return Text(
      dex.toUpperCase(),
      style: const TextStyle(
        fontFamily: 'Inter',
        fontSize: 11,
        fontWeight: FontWeight.w500,
        color: AppColors.textMuted,
        letterSpacing: 0.2,
      ),
    );
  }
}
