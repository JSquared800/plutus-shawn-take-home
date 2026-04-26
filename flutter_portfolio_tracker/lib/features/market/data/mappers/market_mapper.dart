import 'package:flutter_portfolio_tracker/core/utils/decimal_parser.dart';
import 'package:flutter_portfolio_tracker/features/market/data/dto/candle_dto.dart';
import 'package:flutter_portfolio_tracker/features/market/data/dto/meta_and_asset_ctxs_dto.dart';
import 'package:flutter_portfolio_tracker/features/market/data/dto/trade_dto.dart';
import 'package:flutter_portfolio_tracker/features/market/domain/entities/asset_ticker.dart';
import 'package:flutter_portfolio_tracker/features/market/domain/entities/candle.dart';
import 'package:flutter_portfolio_tracker/features/market/domain/entities/market_snapshot.dart';
import 'package:flutter_portfolio_tracker/features/market/domain/entities/trade.dart';

abstract final class MarketMapper {
  static MarketSnapshot snapshotFromDto(MetaAndAssetCtxsDto dto,
      {String dex = ''}) {
    final tickers = <AssetTicker>[];

    for (var i = 0; i < dto.universe.length; i++) {
      if (i >= dto.assetCtxs.length) break;
      final meta = dto.universe[i];
      final ctx = dto.assetCtxs[i];
      final px = ctx.markPx ?? ctx.midPx ?? ctx.oraclePx;

      if (meta.name.isEmpty) continue;

      tickers.add(AssetTicker(
        coin: meta.name,
        dex: dex,
        markPx: DecimalParser.toDouble(px),
        prevDayPx: DecimalParser.toDouble(ctx.prevDayPx),
        change24hPct:
            DecimalParser.pctChange(px, ctx.prevDayPx) ?? 0.0,
        openInterest: DecimalParser.toDouble(ctx.openInterest),
        volume24h: DecimalParser.toDouble(ctx.dayNtlVlm),
      ));
    }

    return MarketSnapshot(tickers: tickers, fetchedAt: DateTime.now());
  }

  static AssetTicker tickerFromCtx({
    required String coin,
    required String dex,
    required AssetCtxDto ctx,
  }) {
    final px = ctx.markPx ?? ctx.midPx ?? ctx.oraclePx;
    return AssetTicker(
      coin: coin,
      dex: dex,
      markPx: DecimalParser.toDouble(px),
      prevDayPx: DecimalParser.toDouble(ctx.prevDayPx),
      change24hPct:
          DecimalParser.pctChange(px, ctx.prevDayPx) ?? 0.0,
      openInterest: DecimalParser.toDouble(ctx.openInterest),
      volume24h: DecimalParser.toDouble(ctx.dayNtlVlm),
    );
  }

  static Candle candleFromDto(CandleDto dto) {
    return Candle(
      timeMs: dto.t,
      open: DecimalParser.toDouble(dto.o),
      high: DecimalParser.toDouble(dto.h),
      low: DecimalParser.toDouble(dto.l),
      close: DecimalParser.toDouble(dto.c),
      volume: DecimalParser.toDouble(dto.v),
      numTrades: dto.n,
    );
  }

  static Trade tradeFromDto(TradeDto dto) {
    return Trade(
      coin: dto.coin,
      side: dto.side == 'B' ? TradeSide.buy : TradeSide.sell,
      px: DecimalParser.toDouble(dto.px),
      sz: DecimalParser.toDouble(dto.sz),
      timeMs: dto.time,
      tid: dto.tid,
    );
  }
}
