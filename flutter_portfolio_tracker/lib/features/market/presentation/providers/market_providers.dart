import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_portfolio_tracker/core/network/api_constants.dart';
import 'package:flutter_portfolio_tracker/features/market/data/repositories/market_repository_impl.dart';
import 'package:flutter_portfolio_tracker/features/market/data/services/hyperliquid_rest_service.dart';
import 'package:flutter_portfolio_tracker/features/market/data/services/hyperliquid_ws_service.dart';
import 'package:flutter_portfolio_tracker/features/market/domain/entities/trade.dart';
import 'package:flutter_portfolio_tracker/features/market/domain/repositories/market_repository.dart';

export 'package:flutter_portfolio_tracker/shared_ui/providers/live_mids_provider.dart';

final hyperliquidRestServiceProvider = Provider<HyperliquidRestService>(
  (_) => HyperliquidRestService(),
);

final hyperliquidWsServiceProvider = Provider<HyperliquidWsService>((ref) {
  final ws = HyperliquidWsService();
  ws.connect();
  ref.onDispose(ws.dispose);
  return ws;
});

final marketRepositoryProvider = Provider<MarketRepository>((ref) {
  return MarketRepositoryImpl(
    restService: ref.watch(hyperliquidRestServiceProvider),
    wsService: ref.watch(hyperliquidWsServiceProvider),
  );
});

// ── Recent trades — isolated from AssetDetailViewModel ───────────────────────
//
// Each trade batch from the WebSocket is a List<Trade> (one WS frame = one
// state write). The provider is keyed by apiCoin so each detail screen gets
// its own independent notifier that is disposed when the screen is popped.

class TradesNotifier extends StateNotifier<List<Trade>> {
  TradesNotifier(String apiCoin, MarketRepository repo)
      : _apiCoin = apiCoin,
        _repo = repo,
        super(const []) {
    _sub = _repo.tradesStream(_apiCoin).listen(_onBatch);
  }

  static const int _maxTrades = ApiConstants.tradesListMaxLength;
  final String _apiCoin;
  final MarketRepository _repo;
  StreamSubscription<List<Trade>>? _sub;

  void _onBatch(List<Trade> batch) {
    if (!mounted) return;
    // Newest trades prepended; batch is already newest-first from the WS.
    final updated = [...batch.reversed, ...state];
    state = updated.length > _maxTrades
        ? updated.sublist(0, _maxTrades)
        : updated;
  }

  @override
  void dispose() {
    _sub?.cancel();
    _repo.unsubscribeTrades(_apiCoin);
    super.dispose();
  }
}

/// Key is the full apiCoin ("vntl:ROBOT" or "BTC").
/// Automatically disposed when the AssetDetailView is popped.
final tradesProvider = StateNotifierProvider.family<
    TradesNotifier, List<Trade>, String>((ref, apiCoin) {
  return TradesNotifier(apiCoin, ref.watch(marketRepositoryProvider));
});
