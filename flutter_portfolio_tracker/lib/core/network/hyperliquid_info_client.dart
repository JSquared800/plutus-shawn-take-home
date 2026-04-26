import 'package:dio/dio.dart';
import 'package:flutter_portfolio_tracker/core/errors/app_failure.dart';
import 'package:flutter_portfolio_tracker/core/network/api_constants.dart';
import 'package:flutter_portfolio_tracker/core/network/http_client.dart';
import 'package:flutter_portfolio_tracker/core/result/result.dart';

/// Low-level POST wrapper for the Hyperliquid /info endpoint.
/// Both [HyperliquidRestService] and [PortfolioRestService] delegate here.
class HyperliquidInfoClient {
  HyperliquidInfoClient({Dio? dio}) : _dio = dio ?? buildDioClient();

  final Dio _dio;

  /// POST to the standard REST base or the UI base.
  /// [type] is the Hyperliquid request type string.
  /// [extras] are merged into the request body alongside 'type'.
  /// Set [useUiBase] to true for candle/annotation endpoints.
  Future<Result<dynamic>> post(
    String type, {
    Map<String, dynamic> extras = const {},
    bool useUiBase = false,
  }) async {
    final base =
        useUiBase ? ApiConstants.uiRestBaseUrl : ApiConstants.restBaseUrl;
    final body = <String, dynamic>{'type': type, ...extras};
    try {
      final resp = await _dio.post<dynamic>(
        '$base${ApiConstants.infoPath}',
        data: body,
      );
      return Ok(resp.data);
    } on DioException catch (e) {
      return Err(dioFailure(e));
    } catch (_) {
      return const Err(ParseFailure());
    }
  }
}
