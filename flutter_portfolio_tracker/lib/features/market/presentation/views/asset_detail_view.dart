import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_portfolio_tracker/app/theme/app_colors.dart';
import 'package:flutter_portfolio_tracker/app/theme/app_text_styles.dart';
import 'package:flutter_portfolio_tracker/features/market/presentation/providers/market_providers.dart';
import 'package:flutter_portfolio_tracker/features/market/presentation/view_models/asset_detail_view_model.dart';
import 'package:flutter_portfolio_tracker/features/market/presentation/widgets/asset_about_card.dart';
import 'package:flutter_portfolio_tracker/features/market/presentation/widgets/asset_price_chart.dart';
import 'package:flutter_portfolio_tracker/features/market/presentation/widgets/timeframe_selector.dart';
import 'package:flutter_portfolio_tracker/features/market/presentation/widgets/trades_table.dart';
import 'package:flutter_portfolio_tracker/core/utils/num_formatters.dart';
import 'package:flutter_portfolio_tracker/shared_ui/widgets/coin_icon.dart';
import 'package:flutter_portfolio_tracker/shared_ui/widgets/live_dot.dart';
import 'package:flutter_portfolio_tracker/shared_ui/widgets/stat_chip.dart';

class AssetDetailView extends ConsumerWidget {
  const AssetDetailView({super.key, required this.coin});
  final String coin;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // coin is the full apiCoin key ("vntl:ROBOT" or "BTC").
    final displayName = coin.contains(':') ? coin.split(':').last : coin;

    final state = ref.watch(assetDetailViewModelProvider(coin));
    final vm = ref.read(assetDetailViewModelProvider(coin).notifier);

    // Live price from the shared throttled mid-prices provider.
    final livePrice = ref.watch(liveMidsProvider.select((m) => m[coin]));
    final displayPrice = livePrice ?? state.ticker?.markPx ?? 0.0;

    final ticker = state.ticker;
    final hasDescription =
        (state.annotation?.description.trim().isNotEmpty ?? false);
    final shouldShowAbout = state.isLoadingAnnotation || hasDescription;

    return Scaffold(
      backgroundColor: AppColors.bgDeep,
      appBar: AppBar(
        backgroundColor: AppColors.bgDeep,
        leading: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () => Navigator.of(context).maybePop(),
          child: const Padding(
            padding: EdgeInsets.all(12),
            child: Icon(
              Icons.arrow_back,
              color: AppColors.textPrimary,
            ),
          ),
        ),
        title: Row(
          children: [
            CoinIcon(apiCoin: coin, size: 24, circular: true),
            const SizedBox(width: 8),
            Text(displayName, style: AppTextStyles.assetDetailSymbol),
            const SizedBox(width: 8),
            const LiveDot(),
          ],
        ),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Price and stats header.
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
              child: Row(
                children: [
                  Text(
                    NumFormatters.price(displayPrice),
                    style: AppTextStyles.heroValue,
                  ),
                  if (ticker != null) ...[
                    const SizedBox(width: 14),
                    StatChip(
                      label: 'OI',
                      value: NumFormatters.usdCompact(ticker.openInterest),
                    ),
                    const SizedBox(width: 8),
                    StatChip(
                      label: 'Vol 24h',
                      value: NumFormatters.usdCompact(ticker.volume24h),
                    ),
                    const SizedBox(width: 8),
                    StatChip(
                      label: '24h Chg',
                      value: '${NumFormatters.changeSigned(ticker.change24hPct)}%',
                      positive: ticker.isPositive,
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 16),
            if (shouldShowAbout) ...[
              // About / annotation card
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: AssetAboutCard(
                  annotation: state.annotation,
                  isLoading: state.isLoadingAnnotation,
                ),
              ),
              const SizedBox(height: 20),
            ],
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: AssetPriceChart(candles: state.candles),
            ),
            const SizedBox(height: 12),
            TimeframeSelector(
              intervals: AssetDetailViewModel.intervals,
              selected: state.selectedInterval,
              onSelected: vm.selectInterval,
            ),
            const SizedBox(height: 24),
            const Padding(
              padding: EdgeInsets.fromLTRB(16, 0, 16, 8),
              child: Text('RECENT TRADES', style: AppTextStyles.sectionLabel),
            ),
            // Trades are isolated in their own provider so updates here never
            // cause the candle chart or stats sections above to rebuild.
            Consumer(
              builder: (context, ref, _) {
                final trades = ref.watch(tradesProvider(coin));
                return TradesTable(trades: trades);
              },
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}
