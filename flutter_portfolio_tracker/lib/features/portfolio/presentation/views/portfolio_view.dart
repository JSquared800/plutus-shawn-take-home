import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_portfolio_tracker/app/theme/app_colors.dart';
import 'package:flutter_portfolio_tracker/app/theme/app_text_styles.dart';
import 'package:flutter_portfolio_tracker/features/portfolio/presentation/providers/portfolio_providers.dart';
import 'package:flutter_portfolio_tracker/features/portfolio/presentation/widgets/account_summary_card.dart';
import 'package:flutter_portfolio_tracker/features/portfolio/presentation/widgets/address_input_row.dart';
import 'package:flutter_portfolio_tracker/features/portfolio/presentation/widgets/margin_usage_bar.dart';
import 'package:flutter_portfolio_tracker/features/portfolio/presentation/widgets/open_positions_list.dart';
import 'package:flutter_portfolio_tracker/features/portfolio/presentation/widgets/stats_grid.dart';
import 'package:flutter_portfolio_tracker/shared_ui/widgets/loading_shimmer.dart';
import 'package:flutter_portfolio_tracker/shared_ui/widgets/section_header.dart';

class PortfolioView extends ConsumerWidget {
  const PortfolioView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(portfolioViewModelProvider);
    final vm = ref.read(portfolioViewModelProvider.notifier);

    return Scaffold(
      backgroundColor: AppColors.bgDeep,
      body: SafeArea(
        child: RefreshIndicator(
          color: AppColors.accent,
          backgroundColor: AppColors.bgSecondary,
          onRefresh: vm.refresh,
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              // ── Page header ───────────────────────────────────────────
              SliverToBoxAdapter(
                child: SectionHeader(
                  title: 'PORTFOLIO',
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                  trailing: state.hasData && !state.isSnapshotLoading
                      ? _RefreshBadge(onTap: vm.refresh)
                      : null,
                ),
              ),

              // ── Address input ─────────────────────────────────────────
              SliverToBoxAdapter(
                child: AddressInputRow(
                  onLoad: vm.loadAddress,
                  isLoading: state.isSnapshotLoading,
                  // Show inline errors whenever no data is displayed yet
                  // (validation errors or initial load failures).
                  errorText: (!state.hasData && !state.isSnapshotLoading)
                      ? state.snapshotError
                      : null,
                  initialAddress: state.loadedAddress,
                  onClear: state.hasData ? vm.clearAddress : null,
                ),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: 16)),

              // ── Blank state ───────────────────────────────────────────
              if (state.isBlank)
                const SliverFillRemaining(
                  hasScrollBody: false,
                  child: _BlankState(),
                ),

              // ── Loading skeleton (initial load) ───────────────────────
              if (state.isSnapshotLoading && !state.hasData)
                const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      children: [
                        LoadingShimmer(height: 80, rows: 1),
                        SizedBox(height: 8),
                        LoadingShimmer(height: 60, rows: 2),
                        SizedBox(height: 8),
                        LoadingShimmer(height: 24, rows: 1),
                      ],
                    ),
                  ),
                ),

              // ── Snapshot error (when no prior data) ───────────────────
              if (!state.isSnapshotLoading &&
                  state.snapshotError != null &&
                  !state.hasData)
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: _ErrorState(
                    message: state.snapshotError!,
                    onRetry: vm.refresh,
                  ),
                ),

              // ── Loaded data ───────────────────────────────────────────
              if (state.hasData) ...[
                // Account summary hero
                SliverToBoxAdapter(
                  child: AccountSummaryCard(summary: state.accountSummary!),
                ),

                const SliverToBoxAdapter(child: SizedBox(height: 8)),

                // 2×2 stats grid
                SliverToBoxAdapter(
                  child: StatsGrid(
                    summary: state.accountSummary!,
                    positions: state.positions,
                  ),
                ),

                const SliverToBoxAdapter(child: SizedBox(height: 8)),

                // Margin utilization bar
                SliverToBoxAdapter(
                  child: MarginUsageBar(
                    usagePct: state.accountSummary!.marginUsagePct,
                    usedUsdc: state.accountSummary!.totalMarginUsed,
                    equityUsdc: state.accountSummary!.netEquity,
                  ),
                ),

                const SliverToBoxAdapter(child: SizedBox(height: 16)),

                const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: Text('POSITIONS', style: AppTextStyles.sectionLabel),
                  ),
                ),
                const SliverToBoxAdapter(child: SizedBox(height: 8)),

                // Positions content
                SliverToBoxAdapter(
                  child: OpenPositionsList(
                    positions: state.positions,
                    isLoading: state.isSnapshotLoading,
                    errorMessage: state.snapshotError,
                    onCoinTap: (position) => context.go('/market/${position.coin}'),
                  ),
                ),
              ],

              const SliverToBoxAdapter(child: SizedBox(height: 24)),
            ],
          ),
        ),
      ),
    );
  }
}

class _BlankState extends StatelessWidget {
  const _BlankState();

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(
          Icons.account_balance_wallet_outlined,
          size: 56,
          color: AppColors.textMuted,
        ),
        const SizedBox(height: 16),
        const Text(
          'Enter a wallet address to load portfolio',
          style: AppTextStyles.rowSecondary,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 6),
        Text(
          'Supports any Hyperliquid perp account',
          style: AppTextStyles.rowSecondary
              .copyWith(color: AppColors.textMuted.withValues(alpha: 0.6)),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.message, required this.onRetry});
  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.error_outline, size: 48, color: AppColors.negative),
        const SizedBox(height: 16),
        Text(
          message,
          style:
              AppTextStyles.rowSecondary.copyWith(color: AppColors.negative),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 16),
        GestureDetector(
          onTap: onRetry,
          child: Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
            decoration: BoxDecoration(
              color: AppColors.bgSecondary,
              borderRadius: BorderRadius.circular(10),
              border:
                  Border.all(color: AppColors.borderSubtle, width: 1),
            ),
            child: Text(
              'RETRY',
              style: AppTextStyles.chipText
                  .copyWith(color: AppColors.textPrimary),
            ),
          ),
        ),
      ],
    );
  }
}

class _RefreshBadge extends StatelessWidget {
  const _RefreshBadge({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: const Icon(
        Icons.refresh_rounded,
        size: 18,
        color: AppColors.textMuted,
      ),
    );
  }
}
