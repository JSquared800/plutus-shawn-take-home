import 'package:flutter_portfolio_tracker/core/result/result.dart';
import 'package:flutter_portfolio_tracker/features/market/domain/entities/asset_annotation.dart';
import 'package:flutter_portfolio_tracker/features/market/domain/entities/asset_ticker.dart';
import 'package:flutter_portfolio_tracker/features/market/domain/entities/candle.dart';
import 'package:flutter_portfolio_tracker/features/market/domain/entities/market_snapshot.dart';
import 'package:flutter_portfolio_tracker/features/market/domain/entities/trade.dart';

abstract class MarketRepository {
  /// Fetches a full snapshot of all perpetuals (meta + asset contexts).
  Future<Result<MarketSnapshot>> fetchSnapshot();

  /// Returns live mark-price updates as they arrive from the WebSocket.
  Stream<Map<String, double>> midsStream();

  /// Fetches historical candle data for [coin] at [interval].
  Future<Result<List<Candle>>> fetchCandles({
    required String coin,
    required String interval,
    required int startTimeMs,
    required int endTimeMs,
  });

  /// Returns a stream of trade batches for [coin] via WebSocket.
  /// Each event is a full batch from one WebSocket frame — process as a unit
  /// to avoid N state writes per frame.
  Stream<List<Trade>> tradesStream(String coin);

  /// Unsubscribes trades for [coin] from the WebSocket.
  void unsubscribeTrades(String coin);

  /// Fetches the latest mark price for a single asset. [apiCoin] is the full
  /// canonical identifier ("xyz:CL", "vntl:ROBOT", or "BTC" for HL default).
  Future<Result<AssetTicker>> fetchTicker(String apiCoin);

  /// Fetches the perp annotation (description + category) for [coin].
  Future<Result<AssetAnnotation>> fetchAnnotation(String coin);
}
