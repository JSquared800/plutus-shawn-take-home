import 'package:equatable/equatable.dart';

enum TradeSide { buy, sell }

class Trade extends Equatable {
  const Trade({
    required this.coin,
    required this.side,
    required this.px,
    required this.sz,
    required this.timeMs,
    required this.tid,
  });

  final String coin;
  final TradeSide side;
  final double px;
  final double sz;
  final int timeMs;
  final int tid;

  bool get isBuy => side == TradeSide.buy;

  @override
  List<Object?> get props => [coin, side, px, sz, timeMs, tid];
}
