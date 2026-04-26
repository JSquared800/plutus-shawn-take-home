class CandleDto {
  const CandleDto({
    required this.t,
    required this.o,
    required this.h,
    required this.l,
    required this.c,
    required this.v,
    required this.n,
  });

  factory CandleDto.fromJson(Map<String, dynamic> json) {
    return CandleDto(
      t: json['t'] as int? ?? 0,
      o: json['o'] as String? ?? '0',
      h: json['h'] as String? ?? '0',
      l: json['l'] as String? ?? '0',
      c: json['c'] as String? ?? '0',
      v: json['v'] as String? ?? '0',
      n: json['n'] as int? ?? 0,
    );
  }

  /// Open time (ms epoch)
  final int t;

  final String o;
  final String h;
  final String l;
  final String c;
  final String v;

  /// Number of trades
  final int n;
}
