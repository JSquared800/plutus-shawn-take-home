import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_portfolio_tracker/core/network/api_constants.dart';
import 'package:flutter_portfolio_tracker/features/market/domain/entities/asset_annotation.dart';
import 'package:flutter_portfolio_tracker/features/market/domain/entities/asset_ticker.dart';
import 'package:flutter_portfolio_tracker/features/market/domain/entities/candle.dart';
import 'package:flutter_portfolio_tracker/features/market/domain/repositories/market_repository.dart';
import 'package:flutter_portfolio_tracker/features/market/presentation/providers/market_providers.dart'
    show marketRepositoryProvider;

class AssetDetailState extends Equatable {
  const AssetDetailState({
    this.ticker,
    this.candles = const [],
    this.annotation,
    this.selectedInterval = ApiConstants.defaultCandleInterval,
    this.isLoadingCandles = false,
    this.isLoadingAnnotation = false,
    this.errorMessage,
  });

  final AssetTicker? ticker;
  final List<Candle> candles;
  final AssetAnnotation? annotation;
  final String selectedInterval;
  final bool isLoadingCandles;
  final bool isLoadingAnnotation;
  final String? errorMessage;

  AssetDetailState copyWith({
    AssetTicker? ticker,
    List<Candle>? candles,
    AssetAnnotation? annotation,
    String? selectedInterval,
    bool? isLoadingCandles,
    bool? isLoadingAnnotation,
    String? errorMessage,
    bool clearError = false,
  }) =>
      AssetDetailState(
        ticker: ticker ?? this.ticker,
        candles: candles ?? this.candles,
        annotation: annotation ?? this.annotation,
        selectedInterval: selectedInterval ?? this.selectedInterval,
        isLoadingCandles: isLoadingCandles ?? this.isLoadingCandles,
        isLoadingAnnotation: isLoadingAnnotation ?? this.isLoadingAnnotation,
        errorMessage:
            clearError ? null : (errorMessage ?? this.errorMessage),
      );

  @override
  List<Object?> get props => [
        ticker,
        candles,
        annotation,
        selectedInterval,
        isLoadingCandles,
        isLoadingAnnotation,
        errorMessage,
      ];
}

class AssetDetailViewModel extends StateNotifier<AssetDetailState> {
  /// [apiCoin] is the full identifier: "vntl:ROBOT" for non-HL or "BTC" for HL.
  AssetDetailViewModel(String apiCoin, this._repo)
      : _apiCoin = apiCoin,
        super(const AssetDetailState()) {
    _fetchTicker();
    _fetchCandles(ApiConstants.defaultCandleInterval);
    _fetchAnnotation();
    // Trades are now handled by the isolated tradesProvider family.
  }

  final String _apiCoin; // full canonical id: "vntl:ROBOT", "xyz:CL", or "BTC"
  final MarketRepository _repo;

  static const List<String> intervals = ['5m', '15m', '1h', '4h', '1d'];

  Future<void> _fetchAnnotation() async {
    state = state.copyWith(isLoadingAnnotation: true);
    final result = await _repo.fetchAnnotation(_apiCoin);
    result.fold(
      ok: (a) => state = state.copyWith(annotation: a, isLoadingAnnotation: false),
      err: (_) => state = state.copyWith(
        annotation: AssetAnnotation.empty(_apiCoin),
        isLoadingAnnotation: false,
      ),
    );
  }

  Future<void> _fetchTicker() async {
    final result = await _repo.fetchTicker(_apiCoin);
    result.fold(
      ok: (t) => state = state.copyWith(ticker: t),
      err: (f) => state = state.copyWith(errorMessage: f.message),
    );
  }

  Future<void> _fetchCandles(String interval) async {
    state = state.copyWith(isLoadingCandles: true, clearError: true);
    final now = DateTime.now().millisecondsSinceEpoch;
    final start = now - const Duration(days: 90).inMilliseconds;
    final result = await _repo.fetchCandles(
      coin: _apiCoin,
      interval: interval,
      startTimeMs: start,
      endTimeMs: now,
    );
    result.fold(
      ok: (candles) =>
          state = state.copyWith(candles: candles, isLoadingCandles: false),
      err: (f) =>
          state = state.copyWith(errorMessage: f.message, isLoadingCandles: false),
    );
  }

  void selectInterval(String interval) {
    if (interval == state.selectedInterval) return;
    state = state.copyWith(selectedInterval: interval, candles: const []);
    _fetchCandles(interval);
  }
}

/// Key is the full [apiCoin] ("vntl:ROBOT" or "BTC").
final assetDetailViewModelProvider = StateNotifierProvider.autoDispose.family<
    AssetDetailViewModel, AssetDetailState, String>((ref, apiCoin) {
  return AssetDetailViewModel(apiCoin, ref.watch(marketRepositoryProvider));
});
