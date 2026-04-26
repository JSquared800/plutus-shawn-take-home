import 'package:intl/intl.dart';

/// Centralised numeric formatters for all portfolio (and shared) display strings.
/// Import this file; never instantiate NumberFormat inline in widget files.
abstract final class NumFormatters {
  static final _usd2 = NumberFormat.currency(symbol: r'$', decimalDigits: 2);
  static final _usd4 = NumberFormat.currency(symbol: r'$', decimalDigits: 4);
  static final _price = NumberFormat('#,##0.####', 'en_US');
  static final _priceCoarse = NumberFormat('#,##0.##', 'en_US');
  static final _compact = NumberFormat.compact(locale: 'en_US');
  static final _change = NumberFormat('+0.00;-0.00', 'en_US');
  static final _size = NumberFormat('0.0####', 'en_US');
  static final _time = DateFormat('HH:mm:ss');

  /// '$12,345.67'
  static String usd(double value) => _usd2.format(value);

  /// '$12,345.6789' — for per-unit prices
  static String usdPrice(double value) {
    if (value >= 1000) return _usd2.format(value);
    if (value >= 1) return _usd4.format(value);
    // Sub-dollar assets: up to 6 significant decimal places
    return NumberFormat.currency(
      symbol: r'$',
      decimalDigits: 6,
    ).format(value);
  }

  /// '+3.45%' or '-1.23%' — always shows sign
  static String pctSigned(double value) {
    final sign = value >= 0 ? '+' : '';
    return '$sign${value.toStringAsFixed(2)}%';
  }

  /// '3.45%' — unsigned, for margin usage bar
  static String pct(double value) => '${value.toStringAsFixed(2)}%';

  /// Size with adaptive decimal places: crypto quantities
  static String size(double value, {int decimals = 4}) =>
      value.toStringAsFixed(decimals);

  /// Leverage label: '10×' or '10× iso'
  static String leverage(int value, {bool isolated = false}) =>
      isolated ? '$value× iso' : '$value×';

  /// Abbreviated wallet address: '0x1234…abcd'
  static String shortAddress(String address) {
    if (address.length < 10) return address;
    return '${address.substring(0, 6)}…${address.substring(address.length - 4)}';
  }

  /// '#,##0.####' — 4dp price with thousand separator
  static String price(double value) => '\$${_price.format(value)}';

  /// '#,##0.##' — 2dp price used in compact cards
  static String priceCoarse(double value) => '\$${_priceCoarse.format(value)}';

  /// Compact number without currency: '1.23M'
  static String compact(double value) => _compact.format(value);

  /// Compact USD: '\$1.23M'
  static String usdCompact(double value) => '\$${_compact.format(value)}';

  /// '+3.45' or '-1.23' (no % symbol — caller appends)
  static String changeSigned(double value) => _change.format(value);

  /// '0.0####' crypto size
  static String cryptoSize(double value) => _size.format(value);

  /// 'HH:mm:ss' from epoch ms
  static String tradeTime(int timeMs) =>
      _time.format(DateTime.fromMillisecondsSinceEpoch(timeMs));
}
