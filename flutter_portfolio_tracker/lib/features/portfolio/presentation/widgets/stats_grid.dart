import 'package:flutter/material.dart';
import 'package:flutter_portfolio_tracker/app/theme/app_colors.dart';
import 'package:flutter_portfolio_tracker/app/theme/app_text_styles.dart';
import 'package:flutter_portfolio_tracker/core/utils/num_formatters.dart';
import 'package:flutter_portfolio_tracker/features/portfolio/domain/entities/account_summary.dart';
import 'package:flutter_portfolio_tracker/features/portfolio/domain/entities/open_position.dart';
import 'package:flutter_portfolio_tracker/shared_ui/widgets/hyper_card.dart';

/// Single-row strip of 4 key account stats: Withdrawable, Total uPNL, Margin Used, Positions.
class StatsGrid extends StatelessWidget {
  const StatsGrid({
    super.key,
    required this.summary,
    required this.positions,
  });

  final AccountSummary summary;
  final List<OpenPosition> positions;

  @override
  Widget build(BuildContext context) {
    final totalUPnl =
        positions.fold<double>(0, (sum, p) => sum + p.unrealizedPnl);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(
            child: _StatTile(
              label: 'WITHDRAWABLE',
              value: NumFormatters.usd(summary.withdrawable),
              valueColor: AppColors.textPrimary,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _StatTile(
              label: 'TOTAL uPNL',
              value: NumFormatters.usd(totalUPnl),
              valueColor: totalUPnl >= 0
                  ? AppColors.accent
                  : AppColors.negative,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _StatTile(
              label: 'MARGIN USED',
              value: NumFormatters.usd(summary.totalMarginUsed),
              valueColor: AppColors.textPrimary,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _StatTile(
              label: 'POSITIONS',
              value: '${positions.length}',
              valueColor: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatTile extends StatelessWidget {
  const _StatTile({
    required this.label,
    required this.value,
    required this.valueColor,
  });

  final String label;
  final String value;
  final Color valueColor;

  @override
  Widget build(BuildContext context) {
    return HyperCard(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: AppTextStyles.sectionLabel),
          const SizedBox(height: 4),
          Text(
            value,
            style: AppTextStyles.rowPrimary
                .copyWith(color: valueColor, fontSize: 12),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
