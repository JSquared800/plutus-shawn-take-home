import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_portfolio_tracker/features/market/domain/repositories/market_repository.dart';
import 'package:flutter_portfolio_tracker/features/market/presentation/providers/market_providers.dart'
    show marketRepositoryProvider;

// Keeping liveMids in its own provider means a price tick never touches
// MarketViewState or the list sort order. AssetRow widgets use
// `ref.watch(liveMidsProvider.select((m) => m[coin]))` so only the rows
// whose price actually changed get rebuilt.

class LiveMidsNotifier extends StateNotifier<Map<String, double>> {
  LiveMidsNotifier(MarketRepository repo) : super(const {}) {
    _sub = repo.midsStream().listen(_onMids);
  }

  StreamSubscription<Map<String, double>>? _sub;
  Map<String, double> _pending = {};
  Timer? _timer;

  void _onMids(Map<String, double> mids) {
    _pending = {..._pending, ...mids};
    _timer ??= Timer(const Duration(milliseconds: 500), _flush);
  }

  void _flush() {
    _timer = null;
    if (_pending.isNotEmpty && mounted) {
      state = {...state, ..._pending};
      _pending = {};
    }
  }

  @override
  void dispose() {
    _sub?.cancel();
    _timer?.cancel();
    super.dispose();
  }
}

final liveMidsProvider =
    StateNotifierProvider<LiveMidsNotifier, Map<String, double>>((ref) {
  return LiveMidsNotifier(ref.watch(marketRepositoryProvider));
});
