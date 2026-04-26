import 'package:equatable/equatable.dart';

/// Immutable snapshot of an account's financial state from clearinghouseState.
class AccountSummary extends Equatable {
  const AccountSummary({
    required this.walletAddress,
    required this.netEquity,
    required this.withdrawable,
    required this.totalMarginUsed,
    required this.totalNtlPos,
    required this.marginUsagePct,
    required this.fetchedAt,
  });

  /// The wallet address this summary belongs to.
  final String walletAddress;

  /// Total account value in USDC (marginSummary.accountValue).
  final double netEquity;

  /// Maximum immediately withdrawable USDC.
  final double withdrawable;

  /// Total margin currently locked across all positions in USDC.
  final double totalMarginUsed;

  /// Total notional position value (sum of |position| × mark) in USDC.
  final double totalNtlPos;

  /// Margin utilization as a 0–100 percentage:
  /// (totalMarginUsed / netEquity) × 100
  final double marginUsagePct;

  /// UTC timestamp of when this summary was fetched from the API.
  final DateTime fetchedAt;

  @override
  List<Object?> get props => [
        walletAddress,
        netEquity,
        withdrawable,
        totalMarginUsed,
        totalNtlPos,
        marginUsagePct,
        fetchedAt,
      ];
}
