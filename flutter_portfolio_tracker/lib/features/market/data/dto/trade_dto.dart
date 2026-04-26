class TradeDto {
  const TradeDto({
    required this.coin,
    required this.side,
    required this.px,
    required this.sz,
    required this.time,
    required this.tid,
  });

  factory TradeDto.fromJson(Map<String, dynamic> json) {
    return TradeDto(
      coin: json['coin'] as String? ?? '',
      side: json['side'] as String? ?? 'B',
      px: json['px'] as String? ?? '0',
      sz: json['sz'] as String? ?? '0',
      time: json['time'] as int? ?? 0,
      tid: json['tid'] as int? ?? 0,
    );
  }

  final String coin;
  final String side;
  final String px;
  final String sz;
  final int time;
  final int tid;
}
