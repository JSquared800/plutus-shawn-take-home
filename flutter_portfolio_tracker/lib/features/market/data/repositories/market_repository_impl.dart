import 'dart:async';

import 'package:flutter_portfolio_tracker/core/network/dex_fan_out.dart';
import 'package:flutter_portfolio_tracker/core/result/result.dart';
import 'package:flutter_portfolio_tracker/features/market/data/mappers/market_mapper.dart';
import 'package:flutter_portfolio_tracker/features/market/data/services/hyperliquid_rest_service.dart';
import 'package:flutter_portfolio_tracker/features/market/data/services/hyperliquid_ws_service.dart';
import 'package:flutter_portfolio_tracker/features/market/domain/entities/asset_annotation.dart';
import 'package:flutter_portfolio_tracker/features/market/domain/entities/asset_ticker.dart';
import 'package:flutter_portfolio_tracker/features/market/domain/entities/candle.dart';
import 'package:flutter_portfolio_tracker/features/market/domain/entities/market_snapshot.dart';
import 'package:flutter_portfolio_tracker/features/market/domain/entities/trade.dart';
import 'package:flutter_portfolio_tracker/features/market/domain/repositories/market_repository.dart';

class MarketRepositoryImpl implements MarketRepository {
  MarketRepositoryImpl({
    required HyperliquidRestService restService,
    required HyperliquidWsService wsService,
  })  : _rest = restService,
        _ws = wsService;

  final HyperliquidRestService _rest;
  final HyperliquidWsService _ws;

  /// Fetches all known DEXes in parallel and merges into a single snapshot.
  @override
  Future<Result<MarketSnapshot>> fetchSnapshot() async {
    final fanOut = await DexFanOut.fetch(
      fetch: (dex) => _rest.fetchMetaAndAssetCtxs(dex: dex),
    );

    final allTickers = fanOut.items
        .expand((record) {
          final (dex, dto) = record;
          return MarketMapper.snapshotFromDto(dto, dex: dex).tickers;
        })
        .toList();

    if (allTickers.isEmpty) {
      return Err(UpstreamFailure(
          fanOut.defaultDexError ?? 'Failed to fetch market data'));
    }

    return Ok(MarketSnapshot(tickers: allTickers, fetchedAt: DateTime.now()));
  }

  @override
  Stream<Map<String, double>> midsStream() => _ws.allMidsStream();

  @override
  Future<Result<List<Candle>>> fetchCandles({
    required String coin,
    required String interval,
    required int startTimeMs,
    required int endTimeMs,
  }) async {
    final result = await _rest.fetchCandleSnapshot(
      coin: coin,
      interval: interval,
      startTimeMs: startTimeMs,
      endTimeMs: endTimeMs,
    );
    return result.fold(
      ok: (dtos) => Ok(dtos.map(MarketMapper.candleFromDto).toList()),
      err: Err.new,
    );
  }

  @override
  Stream<List<Trade>> tradesStream(String coin) {
    return _ws.tradesStream(coin).map(
      (list) => list.map(MarketMapper.tradeFromDto).toList(),
    );
  }

  @override
  void unsubscribeTrades(String coin) {
    _ws.unsubscribeTrades(coin);
  }

  @override
  Future<Result<AssetTicker>> fetchTicker(String apiCoin) async {
    final dex = apiCoin.contains(':') ? apiCoin.split(':').first : '';
    final result = await _rest.fetchMetaAndAssetCtxs(dex: dex);
    return result.fold(
      ok: (dto) {
        final idx = dto.universe.indexWhere((u) => u.name == apiCoin);
        if (idx == -1 || idx >= dto.assetCtxs.length) {
          return const Err(UpstreamFailure('Coin not found in universe'));
        }
        return Ok(MarketMapper.tickerFromCtx(
          coin: apiCoin,
          dex: dex,
          ctx: dto.assetCtxs[idx],
        ));
      },
      err: Err.new,
    );
  }

  @override
  Future<Result<AssetAnnotation>> fetchAnnotation(String coin) async {
    final result = await _rest.fetchPerpAnnotation(coin);
    return result.fold(
      ok: (dto) => Ok(AssetAnnotation(
        coin: coin,
        description: dto.description?.trim() ?? '',
        category: dto.category,
      )),
      err: (_) => Ok(AssetAnnotation.empty(coin)),
    );
  }
}
