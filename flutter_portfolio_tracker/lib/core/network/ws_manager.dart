import 'dart:async';
import 'dart:convert';
import 'package:flutter_portfolio_tracker/core/network/api_constants.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class WsManager {
  WsManager({String? url}) : _uri = Uri.parse(url ?? ApiConstants.wsUrl);

  final Uri _uri;
  WebSocketChannel? _channel;

  final _controller = StreamController<Map<String, dynamic>>.broadcast();
  Stream<Map<String, dynamic>> get messages => _controller.stream;

  final _activeSubs = <Map<String, dynamic>>[];
  Timer? _reconnectTimer;
  int _reconnectAttempt = 0;
  bool _disposed = false;

  void connect() {
    if (_disposed) return;
    try {
      _channel = WebSocketChannel.connect(_uri);
      _channel!.stream.listen(
        _onRawMessage,
        onError: (_) => _scheduleReconnect(),
        onDone: _scheduleReconnect,
        cancelOnError: true,
      );
      _reconnectAttempt = 0;
      _resubscribeAll();
    } catch (_) {
      _scheduleReconnect();
    }
  }

  void subscribe(Map<String, dynamic> subscription) {
    final key = jsonEncode(subscription);
    final isNew = !_activeSubs.any((s) => jsonEncode(s) == key);
    if (isNew) {
      _activeSubs.add(subscription);
      _send({'method': 'subscribe', 'subscription': subscription});
    }
  }

  void unsubscribe(Map<String, dynamic> subscription) {
    final key = jsonEncode(subscription);
    final hadSub = _activeSubs.any((s) => jsonEncode(s) == key);
    if (!hadSub) return;
    _activeSubs.removeWhere((s) => jsonEncode(s) == key);
    _send({'method': 'unsubscribe', 'subscription': subscription});
  }

  void _onRawMessage(dynamic event) {
    try {
      final decoded = jsonDecode(event as String);
      if (decoded is Map<String, dynamic>) {
        _controller.add(decoded);
      }
    } catch (_) {
      // Silently ignore unparseable frames
    }
  }

  void _send(Map<String, dynamic> msg) {
    try {
      _channel?.sink.add(jsonEncode(msg));
    } catch (_) {
      // Channel may be closing
    }
  }

  void _resubscribeAll() {
    for (final sub in _activeSubs) {
      _send({'method': 'subscribe', 'subscription': sub});
    }
  }

  void _scheduleReconnect() {
    if (_disposed) return;
    _reconnectTimer?.cancel();
    final delaySec =
        (ApiConstants.wsInitialReconnectDelaySec << _reconnectAttempt)
            .clamp(ApiConstants.wsInitialReconnectDelaySec,
                ApiConstants.wsMaxReconnectDelaySec);
    _reconnectAttempt = (_reconnectAttempt + 1).clamp(0, 10);
    _reconnectTimer = Timer(Duration(seconds: delaySec), connect);
  }

  Future<void> dispose() async {
    _disposed = true;
    _reconnectTimer?.cancel();
    await _channel?.sink.close();
    await _controller.close();
  }
}
