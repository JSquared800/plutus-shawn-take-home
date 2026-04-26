import 'package:flutter_portfolio_tracker/core/network/api_constants.dart';
import 'package:flutter_portfolio_tracker/core/network/hyperliquid_info_client.dart';
import 'package:flutter_portfolio_tracker/core/result/result.dart';
import 'package:flutter_portfolio_tracker/features/market/data/dto/candle_dto.dart';
import 'package:flutter_portfolio_tracker/features/market/data/dto/meta_and_asset_ctxs_dto.dart';
import 'package:flutter_portfolio_tracker/features/market/data/dto/perp_annotation_dto.dart';

class HyperliquidRestService {
  HyperliquidRestService({HyperliquidInfoClient? client})
      : _client = client ?? HyperliquidInfoClient();

  final HyperliquidInfoClient _client;

  Future<Result<MetaAndAssetCtxsDto>> fetchMetaAndAssetCtxs(
      {String dex = ''}) async {
    final extras = <String, dynamic>{};
    if (dex.isNotEmpty) extras['dex'] = dex;
    final result = await _client.post(
      ApiConstants.typeMetaAndAssetCtxs,
      extras: extras,
    );
    return result.fold(
      ok: (data) {
        try {
          return Ok(MetaAndAssetCtxsDto.fromResponse(data as List<dynamic>));
        } catch (_) {
          return const Err(ParseFailure());
        }
      },
      err: Err.new,
    );
  }

  Future<Result<List<CandleDto>>> fetchCandleSnapshot({
    required String coin,
    required String interval,
    required int startTimeMs,
    required int endTimeMs,
  }) async {
    final result = await _client.post(
      ApiConstants.typeCandleSnapshot,
      extras: {
        'req': {
          'coin': coin,
          'interval': interval,
          'startTime': startTimeMs,
          'endTime': endTimeMs,
        },
      },
      useUiBase: true,
    );
    return result.fold(
      ok: (data) {
        try {
          final raw = (data as List<dynamic>).cast<Map<String, dynamic>>();
          return Ok(raw.map(CandleDto.fromJson).toList());
        } catch (_) {
          return const Err(ParseFailure());
        }
      },
      err: Err.new,
    );
  }

  Future<Result<PerpAnnotationDto>> fetchPerpAnnotation(String coin) async {
    final result = await _client.post(
      ApiConstants.typePerpAnnotation,
      extras: {'coin': coin},
      useUiBase: true,
    );
    return result.fold(
      ok: (data) {
        try {
          return Ok(PerpAnnotationDto.fromJson(data as Map<String, dynamic>));
        } catch (_) {
          return const Err(ParseFailure());
        }
      },
      err: Err.new,
    );
  }
}
