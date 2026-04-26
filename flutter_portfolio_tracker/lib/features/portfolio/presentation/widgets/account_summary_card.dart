import 'package:flutter/material.dart';
import 'package:flutter_portfolio_tracker/app/theme/app_text_styles.dart';
import 'package:flutter_portfolio_tracker/core/utils/num_formatters.dart';
import 'package:flutter_portfolio_tracker/features/portfolio/domain/entities/account_summary.dart';
import 'package:flutter_portfolio_tracker/shared_ui/widgets/hyper_card.dart';
import 'package:flutter_portfolio_tracker/shared_ui/widgets/live_dot.dart';

/// Hero card showing wallet address + net account equity.
class AccountSummaryCard extends StatelessWidget {
  const AccountSummaryCard({super.key, required this.summary});

  final AccountSummary summary;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: HyperCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const LiveDot(),
                const SizedBox(width: 6),
                Text(
                  NumFormatters.shortAddress(summary.walletAddress),
                  style: AppTextStyles.sectionLabel,
                ),
                const Spacer(),
                const Text(
                  'ACCOUNT',
                  style: AppTextStyles.sectionLabel,
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              NumFormatters.usd(summary.netEquity),
              style: AppTextStyles.heroValue,
            ),
            const SizedBox(height: 4),
            const Text(
              'NET EQUITY',
              style: AppTextStyles.sectionLabel,
            ),
          ],
        ),
      ),
    );
  }
}
