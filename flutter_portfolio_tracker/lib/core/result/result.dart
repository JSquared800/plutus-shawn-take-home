import 'package:flutter_portfolio_tracker/core/errors/app_failure.dart';
export 'package:flutter_portfolio_tracker/core/errors/app_failure.dart';

sealed class Result<T> {
  const Result();

  bool get isOk => this is Ok<T>;
  bool get isErr => this is Err<T>;

  R fold<R>({
    required R Function(T value) ok,
    required R Function(AppFailure failure) err,
  }) =>
      switch (this) {
        Ok<T>(:final value) => ok(value),
        Err<T>(:final failure) => err(failure),
      };
}

final class Ok<T> extends Result<T> {
  const Ok(this.value);
  final T value;
}

final class Err<T> extends Result<T> {
  const Err(this.failure);
  final AppFailure failure;
}
