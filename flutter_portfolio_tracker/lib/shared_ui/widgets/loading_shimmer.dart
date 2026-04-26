import 'package:flutter/material.dart';
import 'package:flutter_portfolio_tracker/app/theme/app_colors.dart';

/// Full-width shimmer block with [rows] stacked at [height] each.
class LoadingShimmer extends StatelessWidget {
  const LoadingShimmer({super.key, required this.height, required this.rows});

  final double height;
  final int rows;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (int i = 0; i < rows; i++) ...[
          ShimmerBox(
            width: double.infinity,
            height: height,
            borderRadius: BorderRadius.circular(10),
          ),
          if (i < rows - 1) const SizedBox(height: 8),
        ],
      ],
    );
  }
}

class ShimmerBox extends StatefulWidget {
  const ShimmerBox({
    super.key,
    required this.width,
    required this.height,
    this.borderRadius,
  });

  final double width;
  final double height;
  final BorderRadius? borderRadius;

  @override
  State<ShimmerBox> createState() => _ShimmerBoxState();
}

class _ShimmerBoxState extends State<ShimmerBox>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1200))
      ..repeat(reverse: true);
    _anim = Tween<double>(begin: 0.4, end: 0.85)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _anim,
      builder: (_, __) => Container(
        width: widget.width,
        height: widget.height,
        decoration: BoxDecoration(
          color: AppColors.bgSecondary.withValues(alpha: _anim.value),
          borderRadius: widget.borderRadius ?? BorderRadius.circular(6),
        ),
      ),
    );
  }
}

class MarketRowSkeleton extends StatelessWidget {
  const MarketRowSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          ShimmerBox(width: 36, height: 36, borderRadius: BorderRadius.all(Radius.circular(10))),
          SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ShimmerBox(width: 56, height: 12),
              SizedBox(height: 6),
              ShimmerBox(width: 80, height: 10),
            ],
          ),
          Spacer(),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              ShimmerBox(width: 72, height: 12),
              SizedBox(height: 6),
              ShimmerBox(width: 48, height: 10),
            ],
          ),
        ],
      ),
    );
  }
}
