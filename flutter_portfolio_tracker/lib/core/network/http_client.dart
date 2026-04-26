import 'package:dio/dio.dart';
import 'package:flutter_portfolio_tracker/core/errors/app_failure.dart';
import 'package:flutter_portfolio_tracker/core/network/api_constants.dart';

Dio buildDioClient() {
  return Dio(BaseOptions(
    connectTimeout: const Duration(milliseconds: ApiConstants.sendTimeoutMs),
    sendTimeout: const Duration(milliseconds: ApiConstants.sendTimeoutMs),
    receiveTimeout: const Duration(milliseconds: ApiConstants.receiveTimeoutMs),
    headers: const {'Content-Type': 'application/json'},
  ));
}

AppFailure dioFailure(DioException e) {
  return switch (e.type) {
    DioExceptionType.connectionTimeout ||
    DioExceptionType.sendTimeout ||
    DioExceptionType.receiveTimeout =>
      const TimeoutFailure(),
    DioExceptionType.badResponse => switch (e.response?.statusCode) {
        429 => const RateLimitedFailure(),
        _ => const UpstreamFailure(),
      },
    DioExceptionType.connectionError => const NetworkFailure(),
    _ => NetworkFailure(e.message ?? 'Unknown network error'),
  };
}
