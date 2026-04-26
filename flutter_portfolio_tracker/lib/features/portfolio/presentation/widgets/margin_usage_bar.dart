import 'package:flutter/material.dart';
import 'package:flutter_portfolio_tracker/app/theme/app_colors.dart';
import 'package:flutter_portfolio_tracker/app/theme/app_text_styles.dart';
import 'package:flutter_portfolio_tracker/core/utils/num_formatters.dart';
import 'package:flutter_portfolio_tracker/shared_ui/widgets/hyper_card.dart';

/// Linear margin utilization bar with percentage label.
/// Color transitions from accent → warning → negative as usage rises.
class MarginUsageBar extends StatelessWidget {
  const MarginUsageBar({
    super.key,
    required this.usagePct,
    required this.usedUsdc,
    required this.equityUsdc,
  });

  final double usagePct;
  final double usedUsdc;
  final double equityUsdc;

  Color get _barColor {
    if (usagePct >= 80) return AppColors.negative;
    if (usagePct >= 50) return AppColors.warning;
    return AppColors.accent;
  }

  @override
  Widget build(BuildContext context) {
    final fraction = (usagePct / 100).clamp(0.0, 1.0);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: HyperCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('MARGIN UTILIZATION', style: AppTextStyles.sectionLabel),
                Text(
                  NumFormatters.pct(usagePct),
                  style: AppTextStyles.rowPrimary.copyWith(color: _barColor),
                ),
              ],
            ),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: fraction,
                minHeight: 6,
                backgroundColor: AppColors.borderSubtle,
                valueColor: AlwaysStoppedAnimation<Color>(_barColor),
              ),
            ),
            const SizedBox(height: 6),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Used: ${NumFormatters.usd(usedUsdc)}',
                  style: AppTextStyles.rowSecondary,
                ),
                Text(
                  'Equity: ${NumFormatters.usd(equityUsdc)}',
                  style: AppTextStyles.rowSecondary,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
