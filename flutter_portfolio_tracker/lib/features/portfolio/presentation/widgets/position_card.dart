import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_portfolio_tracker/app/theme/app_colors.dart';
import 'package:flutter_portfolio_tracker/app/theme/app_text_styles.dart';
import 'package:flutter_portfolio_tracker/core/utils/num_formatters.dart';
import 'package:flutter_portfolio_tracker/shared_ui/providers/live_mids_provider.dart';
import 'package:flutter_portfolio_tracker/features/portfolio/domain/entities/open_position.dart';
import 'package:flutter_portfolio_tracker/shared_ui/widgets/hyper_card.dart';

/// Card showing a single open perpetual position.
/// Watches [liveMidsProvider] with .select() to update the mark price column
/// without rebuilding the entire list. uPnL is kept as the API snapshot value.
class PositionCard extends ConsumerWidget {
  const PositionCard({
    super.key,
    required this.position,
    this.onCoinTap,
  });

  final OpenPosition position;
  final VoidCallback? onCoinTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final liveMark = ref.watch(
      liveMidsProvider.select((m) => m[position.coin]),
    );
    final displayMarkPx = liveMark ?? position.entryPx;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: HyperCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _CardHeader(
              position: position,
              onCoinTap: onCoinTap,
            ),
            const SizedBox(height: 10),
            _MetricsRow(
              position: position,
              liveMarkPx: displayMarkPx,
            ),
            if (position.liquidationPx != null) ...[
              const SizedBox(height: 8),
              _LiquidationRow(liqPx: position.liquidationPx!),
            ],
          ],
        ),
      ),
    );
  }
}

class _CardHeader extends StatelessWidget {
  const _CardHeader({
    required this.position,
    this.onCoinTap,
  });
  final OpenPosition position;
  final VoidCallback? onCoinTap;

  @override
  Widget build(BuildContext context) {
    final sideColor =
        position.isLong ? AppColors.accent : AppColors.negative;

    return Row(
      children: [
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: onCoinTap,
          child: Text(
            position.coin,
            style: AppTextStyles.rowPrimary.copyWith(
              color: onCoinTap == null ? null : AppColors.accent,
              decoration:
                  onCoinTap == null ? TextDecoration.none : TextDecoration.underline,
              decorationColor: AppColors.accent,
            ),
          ),
        ),
        const SizedBox(width: 8),
        _Badge(
          label: position.sideLabel,
          color: sideColor,
        ),
        const SizedBox(width: 6),
        _Badge(
          label: NumFormatters.leverage(
            position.leverageValue,
            isolated: position.leverageType == LeverageType.isolated,
          ),
          color: AppColors.textMuted,
        ),
        const Spacer(),
        Text(
          NumFormatters.pctSigned(position.returnOnEquity * 100),
          style: AppTextStyles.rowPrimary.copyWith(
            color: position.isPnlPositive ? AppColors.accent : AppColors.negative,
          ),
        ),
      ],
    );
  }
}

class _MetricsRow extends StatelessWidget {
  const _MetricsRow({
    required this.position,
    required this.liveMarkPx,
  });

  final OpenPosition position;
  final double liveMarkPx;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _MetricCell(
            label: 'SIZE',
            value: NumFormatters.size(position.absSize),
          ),
        ),
        Expanded(
          child: _MetricCell(
            label: 'ENTRY',
            value: NumFormatters.usdPrice(position.entryPx),
          ),
        ),
        Expanded(
          child: _MetricCell(
            label: 'MARK',
            value: NumFormatters.usdPrice(liveMarkPx),
            valueColor: AppColors.accent,
          ),
        ),
        Expanded(
          child: _MetricCell(
            label: 'uPNL',
            value: NumFormatters.usd(position.unrealizedPnl),
            valueColor: position.isPnlPositive
                ? AppColors.accent
                : AppColors.negative,
          ),
        ),
      ],
    );
  }
}

class _LiquidationRow extends StatelessWidget {
  const _LiquidationRow({required this.liqPx});
  final double liqPx;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Text('LIQ: ', style: AppTextStyles.rowSecondary),
        Text(
          NumFormatters.usdPrice(liqPx),
          style: AppTextStyles.rowSecondary
              .copyWith(color: AppColors.negative),
        ),
      ],
    );
  }
}

class _MetricCell extends StatelessWidget {
  const _MetricCell({
    required this.label,
    required this.value,
    this.valueColor,
  });

  final String label;
  final String value;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTextStyles.sectionLabel),
        const SizedBox(height: 2),
        Text(
          value,
          style: AppTextStyles.rowSecondary.copyWith(
            color: valueColor ?? AppColors.textPrimary,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}

class _Badge extends StatelessWidget {
  const _Badge({required this.label, required this.color});
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color.withValues(alpha: 0.3), width: 0.5),
      ),
      child: Text(
        label,
        style: AppTextStyles.chipText.copyWith(color: color),
      ),
    );
  }
}
