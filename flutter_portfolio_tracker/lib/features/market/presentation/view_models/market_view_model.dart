import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_portfolio_tracker/features/market/domain/entities/asset_ticker.dart';
import 'package:flutter_portfolio_tracker/features/market/domain/entities/market_snapshot.dart';
import 'package:flutter_portfolio_tracker/core/utils/sentinel.dart';
import 'package:flutter_portfolio_tracker/features/market/domain/repositories/market_repository.dart';
import 'package:flutter_portfolio_tracker/features/market/presentation/providers/market_providers.dart';

export 'package:flutter_portfolio_tracker/shared_ui/providers/live_mids_provider.dart'
    show liveMidsProvider;

enum SortField { name, price, change, volume }

class MarketViewState extends Equatable {
  const MarketViewState({
    this.snapshot,
    this.errorMessage,
    this.isLoading = false,
    this.sortField = SortField.volume,
    this.sortAscending = false,
    this.query = '',
    this.selectedDex, // null = All
  });

  final MarketSnapshot? snapshot;
  final String? errorMessage;
  final bool isLoading;
  final SortField sortField;
  final bool sortAscending;
  final String query;

  /// null = "All DEXes". Empty string = HL default DEX. "vntl" etc = specific DEX.
  final String? selectedDex;

  bool get hasData => snapshot != null && snapshot!.tickers.isNotEmpty;

  List<AssetTicker> get _dexFiltered {
    final src = snapshot?.tickers ?? const [];
    if (selectedDex == null) return src;
    return src.where((t) => t.dex == selectedDex).toList();
  }

  List<AssetTicker> get filteredAndSorted {
    final src = _dexFiltered;
    final q = query.trim().toLowerCase();
    final filtered = q.isEmpty
        ? src
        : src.where((t) => t.coin.toLowerCase().contains(q)).toList();

    final sorted = [...filtered];
    // Sort by snapshot prices only — no liveMids dependency → stable list order.
    sorted.sort((a, b) {
      int cmp;
      switch (sortField) {
        case SortField.name:
          cmp = a.coin.compareTo(b.coin);
        case SortField.price:
          cmp = a.markPx.compareTo(b.markPx);
        case SortField.change:
          cmp = a.change24hPct.compareTo(b.change24hPct);
        case SortField.volume:
          cmp = a.volume24h.compareTo(b.volume24h);
      }
      return sortAscending ? cmp : -cmp;
    });
    return sorted;
  }

  /// Top 5 assets by 24h change within the current DEX filter.
  List<AssetTicker> get topGainers {
    final src = _dexFiltered;
    if (src.isEmpty) return const [];
    final sorted = [...src]
      ..sort((a, b) => b.change24hPct.compareTo(a.change24hPct));
    return sorted.take(5).toList();
  }

  MarketViewState copyWith({
    MarketSnapshot? snapshot,
    String? errorMessage,
    bool? isLoading,
    SortField? sortField,
    bool? sortAscending,
    String? query,
    Object? selectedDex = copyWithSentinel,
    bool clearError = false,
  }) {
    return MarketViewState(
      snapshot: snapshot ?? this.snapshot,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      isLoading: isLoading ?? this.isLoading,
      sortField: sortField ?? this.sortField,
      sortAscending: sortAscending ?? this.sortAscending,
      query: query ?? this.query,
      selectedDex: selectedDex == copyWithSentinel ? this.selectedDex : selectedDex as String?,
    );
  }

  @override
  List<Object?> get props => [
        snapshot,
        errorMessage,
        isLoading,
        sortField,
        sortAscending,
        query,
        selectedDex,
      ];
}

class MarketViewModel extends StateNotifier<MarketViewState> {
  MarketViewModel(this._repo) : super(const MarketViewState()) {
    _fetchSnapshot();
  }

  final MarketRepository _repo;

  Future<void> _fetchSnapshot() async {
    state = state.copyWith(isLoading: true, clearError: true);
    final result = await _repo.fetchSnapshot();
    result.fold(
      ok: (snapshot) => state = state.copyWith(snapshot: snapshot, isLoading: false),
      err: (failure) =>
          state = state.copyWith(errorMessage: failure.message, isLoading: false),
    );
  }

  Future<void> refresh() => _fetchSnapshot();

  void updateQuery(String q) => state = state.copyWith(query: q);

  /// Pass null to show all DEXes, or a dex string (e.g. "", "vntl") to filter.
  void selectDex(String? dex) =>
      state = state.copyWith(selectedDex: dex);

  void setSort(SortField field) {
    if (state.sortField == field) {
      state = state.copyWith(sortAscending: !state.sortAscending);
    } else {
      state = state.copyWith(sortField: field, sortAscending: false);
    }
  }
}

final marketViewModelProvider =
    StateNotifierProvider<MarketViewModel, MarketViewState>((ref) {
  return MarketViewModel(ref.watch(marketRepositoryProvider));
});
