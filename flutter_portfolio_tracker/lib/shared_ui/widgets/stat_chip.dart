import 'package:flutter/material.dart';
import 'package:flutter_portfolio_tracker/app/theme/app_colors.dart';
import 'package:flutter_portfolio_tracker/app/theme/app_text_styles.dart';

class StatChip extends StatelessWidget {
  const StatChip({
    super.key,
    required this.label,
    required this.value,
    this.positive,
  });

  final String label;
  final String value;
  final bool? positive;

  @override
  Widget build(BuildContext context) {
    final Color textColor = positive == null
        ? AppColors.textPrimary
        : positive!
            ? AppColors.positive
            : AppColors.negativeLight;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.bgSecondary,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.borderSubtle, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label.toUpperCase(), style: AppTextStyles.sectionLabel),
          const SizedBox(height: 2),
          Text(value, style: AppTextStyles.chipText.copyWith(color: textColor)),
        ],
      ),
    );
  }
}
