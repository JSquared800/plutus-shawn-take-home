import 'package:equatable/equatable.dart';
import 'asset_ticker.dart';

class MarketSnapshot extends Equatable {
  const MarketSnapshot({
    required this.tickers,
    required this.fetchedAt,
  });

  final List<AssetTicker> tickers;
  final DateTime fetchedAt;

  @override
  List<Object?> get props => [tickers, fetchedAt];
}
