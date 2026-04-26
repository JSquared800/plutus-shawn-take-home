import 'package:flutter_portfolio_tracker/core/network/api_constants.dart';
import 'package:flutter_portfolio_tracker/core/result/result.dart';

/// Result of a parallel DEX fan-out fetch.
typedef DexFanOutResult<T> = ({
  List<(String dex, T item)> items,
  String? defaultDexError,
});

/// Fetches [fetch] for every known DEX in parallel.
/// Default DEX (`dex == ''`) failure is captured; others fail silently.
abstract final class DexFanOut {
  static Future<DexFanOutResult<T>> fetch<T>({
    required Future<Result<T>> Function(String dex) fetch,
  }) async {
    final dexNames = ApiConstants.perpDexes.map((d) => d.$1).toList();
    final results = await Future.wait(dexNames.map(fetch));

    final items = <(String, T)>[];
    String? defaultDexError;

    for (var i = 0; i < results.length; i++) {
      final dex = dexNames[i];
      results[i].fold(
        ok: (item) => items.add((dex, item)),
        err: (failure) {
          if (dex.isEmpty) defaultDexError = failure.message;
        },
      );
    }

    return (items: items, defaultDexError: defaultDexError);
  }
}
