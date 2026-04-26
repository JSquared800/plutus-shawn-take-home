import 'package:flutter_portfolio_tracker/core/network/api_constants.dart';
import 'package:flutter_portfolio_tracker/core/network/hyperliquid_info_client.dart';
import 'package:flutter_portfolio_tracker/core/result/result.dart';
import 'package:flutter_portfolio_tracker/features/portfolio/data/dto/clearinghouse_state_dto.dart';

class PortfolioRestService {
  PortfolioRestService({HyperliquidInfoClient? client})
      : _client = client ?? HyperliquidInfoClient();

  final HyperliquidInfoClient _client;

  Future<Result<ClearinghouseStateDto>> fetchClearinghouseState(
    String address, {
    String dex = '',
  }) async {
    final extras = <String, dynamic>{'user': address};
    if (dex.isNotEmpty) extras['dex'] = dex;
    final result = await _client.post(
      ApiConstants.typeClearinghouseState,
      extras: extras,
    );
    return result.fold(
      ok: (data) {
        try {
          return Ok(ClearinghouseStateDto.fromJson(
              data as Map<String, dynamic>));
        } catch (_) {
          return const Err(ParseFailure());
        }
      },
      err: Err.new,
    );
  }
}
