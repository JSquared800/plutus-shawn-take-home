abstract final class DecimalParser {
  static double toDouble(dynamic value, {double fallback = 0.0}) {
    if (value == null) return fallback;
    if (value is double) return value.isFinite ? value : fallback;
    if (value is int) return value.toDouble();
    final str = value.toString().trim();
    if (str.isEmpty) return fallback;
    final n = double.tryParse(str);
    return (n != null && n.isFinite) ? n : fallback;
  }

  static double? toDoubleOrNull(dynamic value) {
    if (value == null) return null;
    if (value is double) return value.isFinite ? value : null;
    if (value is int) return value.toDouble();
    final str = value.toString().trim();
    if (str.isEmpty) return null;
    final n = double.tryParse(str);
    return (n != null && n.isFinite) ? n : null;
  }

  /// Compute 24h percentage change safely.
  /// Returns null if prevDay is zero or either input is unparseable.
  static double? pctChange(dynamic markPx, dynamic prevDayPx) {
    final mark = toDoubleOrNull(markPx);
    final prev = toDoubleOrNull(prevDayPx);
    if (mark == null || prev == null || prev == 0) return null;
    return ((mark - prev) / prev) * 100;
  }
}
