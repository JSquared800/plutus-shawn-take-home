import 'package:equatable/equatable.dart';

class Candle extends Equatable {
  const Candle({
    required this.timeMs,
    required this.open,
    required this.high,
    required this.low,
    required this.close,
    required this.volume,
    required this.numTrades,
  });

  final int timeMs;
  final double open;
  final double high;
  final double low;
  final double close;
  final double volume;
  final int numTrades;

  @override
  List<Object?> get props =>
      [timeMs, open, high, low, close, volume, numTrades];
}
