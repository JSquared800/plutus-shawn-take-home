import 'package:equatable/equatable.dart';

enum LeverageType { isolated, cross }

/// A single open perpetual position on Hyperliquid.
class OpenPosition extends Equatable {
  const OpenPosition({
    required this.coin,
    this.dex = '',
    required this.size,
    required this.entryPx,
    required this.unrealizedPnl,
    required this.marginUsed,
    required this.positionValue,
    required this.returnOnEquity,
    required this.leverageValue,
    required this.leverageType,
    this.liquidationPx,
  });

  /// Coin symbol, e.g., 'BTC', 'ETH'.
  final String coin;
  final String dex;

  /// Signed size: positive = long, negative = short.
  final double size;

  /// Average entry price in USDC.
  final double entryPx;

  /// Unrealized PnL in USDC as reported by the API.
  /// This value includes funding accruals — do not recompute from live prices.
  final double unrealizedPnl;

  /// Margin currently locked for this position in USDC.
  final double marginUsed;

  /// Total notional value of the position in USDC.
  final double positionValue;

  /// Return on equity as a decimal fraction (e.g., 0.12 = 12%).
  final double returnOnEquity;

  final int leverageValue;
  final LeverageType leverageType;

  /// Estimated liquidation price; null if cross-margined with no risk.
  final double? liquidationPx;

  bool get isLong => size >= 0;
  double get absSize => size.abs();
  String get sideLabel => isLong ? 'LONG' : 'SHORT';
  bool get isPnlPositive => unrealizedPnl >= 0;

  @override
  List<Object?> get props => [
        coin,
        dex,
        size,
        entryPx,
        unrealizedPnl,
        marginUsed,
        positionValue,
        returnOnEquity,
        leverageValue,
        leverageType,
        liquidationPx,
      ];
}
