import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_portfolio_tracker/app/theme/app_colors.dart';
import 'package:flutter_portfolio_tracker/app/theme/app_text_styles.dart';
import 'package:flutter_portfolio_tracker/features/market/domain/entities/asset_ticker.dart';
import 'package:flutter_portfolio_tracker/features/market/presentation/providers/market_providers.dart';
import 'package:flutter_portfolio_tracker/core/utils/num_formatters.dart';
import 'package:flutter_portfolio_tracker/shared_ui/widgets/coin_icon.dart';
import 'package:flutter_portfolio_tracker/shared_ui/widgets/loading_shimmer.dart';

class TopGainersStrip extends StatelessWidget {
  const TopGainersStrip({
    super.key,
    required this.gainers,
    this.isLoading = false,
    this.onGainerTap,
  });

  final List<AssetTicker> gainers;
  final bool isLoading;
  final void Function(String coin)? onGainerTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 10),
          child: Row(
            children: [
              const Text('TOP GAINERS (24H)', style: AppTextStyles.sectionLabel),
              const SizedBox(width: 6),
              Container(
                width: 6,
                height: 6,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.positive,
                ),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 116,
          child: isLoading
              ? _BuildLoadingStrip()
              : ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: gainers.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 10),
                  itemBuilder: (context, i) => _GainerCard(
                    ticker: gainers[i],
                    onTap: () => onGainerTap?.call(gainers[i].coin),
                  ),
                ),
        ),
      ],
    );
  }
}

class _BuildLoadingStrip extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: 5,
      separatorBuilder: (_, __) => const SizedBox(width: 10),
      itemBuilder: (_, __) => const ShimmerBox(
        width: 110,
        height: 116,
        borderRadius: BorderRadius.all(Radius.circular(12)),
      ),
    );
  }
}

class _GainerCard extends ConsumerWidget {
  const _GainerCard({required this.ticker, required this.onTap});
  final AssetTicker ticker;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final livePrice = ref.watch(
      liveMidsProvider.select((mids) => mids[ticker.coin]),
    );
    final displayPx = livePrice ?? ticker.markPx;
    final changeColor = ticker.isPositive ? AppColors.positive : AppColors.negativeLight;
    final changeBg = ticker.isPositive
        ? AppColors.positive.withValues(alpha: 0.12)
        : AppColors.negative.withValues(alpha: 0.12);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 110,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.bgSurface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.borderCard, width: 1),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            CoinIcon(apiCoin: ticker.coin, size: 28, circular: true),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  ticker.coin,
                  style: AppTextStyles.rowPrimary.copyWith(fontSize: 12),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  NumFormatters.priceCoarse(displayPx),
                  style: AppTextStyles.rowPrice.copyWith(fontSize: 11),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                  decoration: BoxDecoration(
                    color: changeBg,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    '${NumFormatters.changeSigned(ticker.change24hPct)}%',
                    style: AppTextStyles.rowChange.copyWith(
                      fontSize: 10,
                      color: changeColor,
                    ),
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
