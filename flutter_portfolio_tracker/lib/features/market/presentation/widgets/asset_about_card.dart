import 'package:flutter/material.dart';
import 'package:flutter_portfolio_tracker/app/theme/app_colors.dart';
import 'package:flutter_portfolio_tracker/app/theme/app_text_styles.dart';
import 'package:flutter_portfolio_tracker/features/market/domain/entities/asset_annotation.dart';
import 'package:flutter_portfolio_tracker/shared_ui/widgets/hyper_card.dart';
import 'package:flutter_portfolio_tracker/shared_ui/widgets/loading_shimmer.dart';

class AssetAboutCard extends StatelessWidget {
  const AssetAboutCard({
    super.key,
    required this.annotation,
    this.isLoading = false,
  });

  final AssetAnnotation? annotation;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return HyperCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('ABOUT', style: AppTextStyles.sectionLabel),
              if (annotation?.category != null) ...[
                const Spacer(),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppColors.blueInfo.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                        color: AppColors.blueInfo.withValues(alpha: 0.30),
                        width: 1),
                  ),
                  child: Text(
                    annotation!.category!,
                    style:
                        AppTextStyles.chipText.copyWith(color: AppColors.blueInfo),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 10),
          if (isLoading)
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ShimmerBox(width: double.infinity, height: 12),
                SizedBox(height: 6),
                ShimmerBox(width: 220, height: 12),
                SizedBox(height: 6),
                ShimmerBox(width: 160, height: 12),
              ],
            )
          else
            Text(
              annotation?.description ?? 'No description available yet.',
              style: AppTextStyles.annotationBody,
            ),
        ],
      ),
    );
  }
}
