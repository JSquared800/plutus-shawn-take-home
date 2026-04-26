import 'package:flutter/material.dart';
import 'package:flutter_portfolio_tracker/app/theme/app_colors.dart';
import 'package:flutter_portfolio_tracker/app/theme/app_text_styles.dart';
import 'package:flutter_portfolio_tracker/features/portfolio/domain/entities/open_position.dart';
import 'package:flutter_portfolio_tracker/features/portfolio/presentation/widgets/position_card.dart';
import 'package:flutter_portfolio_tracker/shared_ui/widgets/loading_shimmer.dart';

/// Non-scrollable positions list rendered inside the parent CustomScrollView.
class OpenPositionsList extends StatelessWidget {
  const OpenPositionsList({
    super.key,
    required this.positions,
    required this.isLoading,
    this.errorMessage,
    this.onCoinTap,
  });

  final List<OpenPosition> positions;
  final bool isLoading;
  final String? errorMessage;
  final void Function(OpenPosition)? onCoinTap;

  @override
  Widget build(BuildContext context) {
    if (isLoading && positions.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(horizontal: 16),
        child: LoadingShimmer(height: 90, rows: 3),
      );
    }

    if (errorMessage != null) {
      return _ErrorState(message: errorMessage!);
    }

    if (positions.isEmpty) {
      return const _EmptyState(
        icon: Icons.inbox_outlined,
        message: 'No open positions',
      );
    }

    return Column(
      children: [
        for (final position in positions) ...[
          PositionCard(
            position: position,
            onCoinTap: onCoinTap == null ? null : () => onCoinTap!(position),
          ),
          const SizedBox(height: 8),
        ],
        const SizedBox(height: 8),
      ],
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.icon, required this.message});
  final IconData icon;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 40),
      child: Column(
        children: [
          Icon(icon, size: 40, color: AppColors.textMuted),
          const SizedBox(height: 12),
          Text(message, style: AppTextStyles.rowSecondary),
        ],
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.message});
  final String message;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Text(
        message,
        style: AppTextStyles.rowSecondary.copyWith(color: AppColors.negative),
        textAlign: TextAlign.center,
      ),
    );
  }
}
