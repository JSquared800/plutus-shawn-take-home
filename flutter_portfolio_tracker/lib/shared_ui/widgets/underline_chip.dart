import 'package:flutter/material.dart';
import 'package:flutter_portfolio_tracker/app/theme/app_colors.dart';
import 'package:flutter_portfolio_tracker/app/theme/app_text_styles.dart';

/// A tappable text chip with an animated underline when selected.
/// Used by [DexFilterStrip] and [TimeframeSelector].
class UnderlineChip extends StatelessWidget {
  const UnderlineChip({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
    this.upperCase = false,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;
  final bool upperCase;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: AnimatedDefaultTextStyle(
          duration: const Duration(milliseconds: 150),
          style: AppTextStyles.chipText.copyWith(
            color: selected ? AppColors.textPrimary : AppColors.textMuted,
            decoration:
                selected ? TextDecoration.underline : TextDecoration.none,
            decorationColor: AppColors.textPrimary,
            decorationThickness: 1.8,
          ),
          child: Text(upperCase ? label.toUpperCase() : label),
        ),
      ),
    );
  }
}
