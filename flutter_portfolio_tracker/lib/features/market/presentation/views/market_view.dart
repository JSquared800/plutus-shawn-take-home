import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_portfolio_tracker/app/theme/app_colors.dart';
import 'package:flutter_portfolio_tracker/app/theme/app_text_styles.dart';
import 'package:flutter_portfolio_tracker/features/market/domain/entities/asset_ticker.dart';
import 'package:flutter_portfolio_tracker/features/market/presentation/view_models/market_view_model.dart';
import 'package:flutter_portfolio_tracker/features/market/presentation/widgets/asset_row.dart';
import 'package:flutter_portfolio_tracker/features/market/presentation/widgets/dex_filter_strip.dart';
import 'package:flutter_portfolio_tracker/features/market/presentation/widgets/top_gainers_strip.dart';
import 'package:flutter_portfolio_tracker/shared_ui/widgets/loading_shimmer.dart';
import 'package:flutter_portfolio_tracker/shared_ui/widgets/live_dot.dart';

class MarketView extends ConsumerStatefulWidget {
  const MarketView({super.key});

  @override
  ConsumerState<MarketView> createState() => _MarketViewState();
}

class _MarketViewState extends ConsumerState<MarketView> {
  final _searchCtrl = TextEditingController();
  final _scrollCtrl = ScrollController();

  @override
  void dispose() {
    _searchCtrl.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Use select so this build method only fires on snapshot/query/sort changes.
    // Live price ticks update individual AssetRow widgets directly via liveMidsProvider.
    final isLoading =
        ref.watch(marketViewModelProvider.select((s) => s.isLoading));
    final hasData = ref.watch(marketViewModelProvider.select((s) => s.hasData));
    final errorMessage =
        ref.watch(marketViewModelProvider.select((s) => s.errorMessage));
    final topGainers =
        ref.watch(marketViewModelProvider.select((s) => s.topGainers));
    final items =
        ref.watch(marketViewModelProvider.select((s) => s.filteredAndSorted));
    final selectedDex =
        ref.watch(marketViewModelProvider.select((s) => s.selectedDex));
    final vm = ref.read(marketViewModelProvider.notifier);

    return Scaffold(
      backgroundColor: AppColors.bgDeep,
      body: RefreshIndicator(
        color: AppColors.accent,
        backgroundColor: AppColors.bgSurface,
        onRefresh: vm.refresh,
        child: CustomScrollView(
          controller: _scrollCtrl,
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            _buildAppBar(isLoading),
            _buildSearchBar(vm),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.only(top: 8, bottom: 0),
                child: DexFilterStrip(
                  selectedDex: selectedDex,
                  onSelected: vm.selectDex,
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: TopGainersStrip(
                gainers: topGainers,
                isLoading: isLoading && !hasData,
                onGainerTap: (apiCoin) => context.go('/market/$apiCoin'),
              ),
            ),
            _buildListHeader(hasData, items.length),
            _buildList(isLoading, hasData, errorMessage, items, vm),
            const SliverToBoxAdapter(child: SizedBox(height: 24)),
          ],
        ),
      ),
    );
  }

  SliverAppBar _buildAppBar(bool isLoading) {
    return SliverAppBar(
      floating: true,
      snap: true,
      pinned: false,
      backgroundColor: AppColors.bgDeep,
      elevation: 0,
      scrolledUnderElevation: 0,
      title: Row(
        children: [
          const Text(
            'Markets',
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(width: 8),
          if (!isLoading) const LiveDot(),
        ],
      ),
      actions: [
        if (isLoading)
          const Padding(
            padding: EdgeInsets.only(right: 16),
            child: SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: AppColors.accent,
              ),
            ),
          ),
      ],
    );
  }

  SliverToBoxAdapter _buildSearchBar(MarketViewModel vm) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 0),
        child: TextField(
          controller: _searchCtrl,
          onChanged: vm.updateQuery,
          style: const TextStyle(
            fontFamily: 'Inter',
            fontSize: 14,
            color: AppColors.textPrimary,
          ),
          decoration: InputDecoration(
            hintText: 'Search assets…',
            prefixIcon: const Icon(Icons.search_rounded,
                size: 18, color: AppColors.textMuted),
            suffixIcon: ValueListenableBuilder<TextEditingValue>(
              valueListenable: _searchCtrl,
              builder: (_, v, __) => v.text.isNotEmpty
                  ? GestureDetector(
                      onTap: () {
                        _searchCtrl.clear();
                        vm.updateQuery('');
                      },
                      child: const Icon(Icons.close_rounded,
                          size: 16, color: AppColors.textMuted),
                    )
                  : const SizedBox.shrink(),
            ),
          ),
        ),
      ),
    );
  }

  SliverToBoxAdapter _buildListHeader(bool hasData, int count) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 6),
        child: Row(
          children: [
            const Text('ALL ASSETS', style: AppTextStyles.sectionLabel),
            if (hasData) ...[
              const SizedBox(width: 6),
              Text(
                '($count)',
                style: AppTextStyles.sectionLabel,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildList(
    bool isLoading,
    bool hasData,
    String? errorMessage,
    List<AssetTicker> items,
    MarketViewModel vm,
  ) {
    if (isLoading && !hasData) {
      return SliverList(
        delegate: SliverChildBuilderDelegate(
          (_, __) => const MarketRowSkeleton(),
          childCount: 12,
        ),
      );
    }

    if (errorMessage != null && !hasData) {
      return SliverToBoxAdapter(
        child: _buildError(errorMessage, vm),
      );
    }

    if (items.isEmpty) {
      return const SliverToBoxAdapter(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 48),
          child: Center(
            child: Text(
              'No assets match your search.',
              style: TextStyle(color: AppColors.textMuted),
            ),
          ),
        ),
      );
    }

    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, i) {
          final ticker = items[i];
          return RepaintBoundary(
            child: Column(
              children: [
                AssetRow(
                  key: ValueKey(ticker.coin),
                  ticker: ticker,
                  onTap: () => context.go('/market/${ticker.coin}'),
                ),
                if (i < items.length - 1) const Divider(height: 1, indent: 64),
              ],
            ),
          );
        },
        childCount: items.length,
      ),
    );
  }

  Widget _buildError(String message, MarketViewModel vm) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 64, horizontal: 24),
      child: Column(
        children: [
          const Icon(Icons.wifi_off_rounded,
              size: 48, color: AppColors.textMuted),
          const SizedBox(height: 16),
          Text(
            message,
            style: const TextStyle(color: AppColors.textMuted),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: vm.refresh,
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }
}
