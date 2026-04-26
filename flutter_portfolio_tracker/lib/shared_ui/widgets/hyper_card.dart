import 'package:flutter/material.dart';
import 'package:flutter_portfolio_tracker/app/theme/app_colors.dart';

class HyperCard extends StatelessWidget {
  const HyperCard({
    super.key,
    required this.child,
    this.padding,
    this.borderRadius,
    this.color,
    this.borderColor,
    this.onTap,
  });

  final Widget child;
  final EdgeInsetsGeometry? padding;
  final BorderRadius? borderRadius;
  final Color? color;
  final Color? borderColor;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final radius = borderRadius ?? BorderRadius.circular(14);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: padding ?? const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: color ?? AppColors.bgSurface,
          borderRadius: radius,
          border: Border.all(
            color: borderColor ?? AppColors.borderCard,
            width: 1,
          ),
        ),
        child: child,
      ),
    );
  }
}
