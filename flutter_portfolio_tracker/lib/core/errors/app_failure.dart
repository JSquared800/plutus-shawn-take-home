import 'package:equatable/equatable.dart';

sealed class AppFailure extends Equatable implements Exception {
  const AppFailure(this.message);
  final String message;

  @override
  List<Object?> get props => [message];
}

final class NetworkFailure extends AppFailure {
  const NetworkFailure([super.message = 'Network error. Please check your connection.']);
}

final class TimeoutFailure extends AppFailure {
  const TimeoutFailure([super.message = 'Request timed out.']);
}

final class RateLimitedFailure extends AppFailure {
  const RateLimitedFailure([super.message = 'Too many requests. Please slow down.']);
}

final class UpstreamFailure extends AppFailure {
  const UpstreamFailure([super.message = 'Server returned an unexpected response.']);
}

final class ParseFailure extends AppFailure {
  const ParseFailure([super.message = 'Failed to parse server response.']);
}
