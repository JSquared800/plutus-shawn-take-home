import 'dart:async';
import 'package:flutter_portfolio_tracker/core/network/api_constants.dart';
import 'package:flutter_portfolio_tracker/core/network/ws_manager.dart';
import 'package:flutter_portfolio_tracker/features/market/data/dto/trade_dto.dart';

class HyperliquidWsService {
  HyperliquidWsService({WsManager? wsManager}) : _ws = wsManager ?? WsManager();

  final WsManager _ws;

  void connect() => _ws.connect();

  /// Subscribe to allMids and get a stream of { coin -> price } maps.
  Stream<Map<String, double>> allMidsStream() {
    _ws.subscribe({'type': ApiConstants.typeAllMids});
    return _ws.messages
        .where((msg) => msg['channel'] == ApiConstants.typeAllMids)
        .map((msg) {
      final data = msg['data'] as Map<String, dynamic>? ?? {};
      final mids = data['mids'] as Map<String, dynamic>? ?? {};
      return mids
          .map((k, v) => MapEntry(k, double.tryParse(v.toString()) ?? 0.0));
    });
  }

  /// Subscribe to trades for a specific coin.
  Stream<List<TradeDto>> tradesStream(String coin) {
    late final StreamSubscription<List<TradeDto>> innerSub;
    late final StreamController<List<TradeDto>> controller;
    controller = StreamController<List<TradeDto>>(
      onListen: () {
        innerSub = _ws.messages
            .where((msg) => msg['channel'] == 'trades')
            .map((msg) {
              final data = msg['data'];
              if (data is List) {
                return data
                    .cast<Map<String, dynamic>>()
                    .where((t) => (t['coin'] as String?) == coin)
                    .map(TradeDto.fromJson)
                    .toList();
              }
              return <TradeDto>[];
            })
            .where((list) => list.isNotEmpty)
            .listen(controller.add);

        _ws.subscribe({'type': 'trades', 'coin': coin});
      },
      onCancel: () async {
        await innerSub.cancel();
        _ws.unsubscribe({'type': 'trades', 'coin': coin});
      },
    );
    return controller.stream;
  }

  void unsubscribeTrades(String coin) {
    _ws.unsubscribe({'type': 'trades', 'coin': coin});
  }

  Future<void> dispose() => _ws.dispose();
}
