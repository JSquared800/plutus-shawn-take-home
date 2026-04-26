import 'package:equatable/equatable.dart';

class AssetTicker extends Equatable {
  const AssetTicker({
    required this.coin,
    required this.dex,
    required this.markPx,
    required this.prevDayPx,
    required this.change24hPct,
    required this.openInterest,
    required this.volume24h,
  });

  /// Raw coin name as returned by the API (e.g. "BTC", "ROBOT").
  final String coin;

  /// DEX identifier ("" for default HL, "vntl", "xyz", etc.).
  final String dex;

  final double markPx;
  final double prevDayPx;

  /// 24h price change as a percentage (e.g. 3.14 = +3.14%).
  final double change24hPct;
  final double openInterest;
  final double volume24h;

  bool get isPositive => change24hPct >= 0;
  bool get isDefaultDex => dex.isEmpty;

  @override
  List<Object?> get props => [
        coin,
        dex,
        markPx,
        prevDayPx,
        change24hPct,
        openInterest,
        volume24h,
      ];
}
