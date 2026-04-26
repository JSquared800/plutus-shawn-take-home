abstract final class ApiConstants {
  static const String restBaseUrl = 'https://api.hyperliquid.xyz';
  static const String uiRestBaseUrl = 'https://api-ui.hyperliquid.xyz';
  static const String wsUrl = 'wss://api.hyperliquid.xyz/ws';
  static const String infoPath = '/info';

  // Request type strings
  static const String typeAllMids = 'allMids';
  static const String typeMetaAndAssetCtxs = 'metaAndAssetCtxs';
  static const String typeCandleSnapshot = 'candleSnapshot';
  static const String typeRecentTrades = 'recentTrades';
  static const String typePerpAnnotation = 'perpAnnotation';
  static const String typeClearinghouseState = 'clearinghouseState';
  static const String typeUserRole = 'userRole';

  // Timeouts
  static const int sendTimeoutMs = 8000;
  static const int receiveTimeoutMs = 12000;

  // WebSocket reconnect
  static const int wsMaxReconnectDelaySec = 16;
  static const int wsInitialReconnectDelaySec = 1;

  // Candle config
  static const int candleMaxPoints = 5000;
  static const String defaultCandleInterval = '15m';

  // Known perp DEXes — (apiName, displayLabel) ordered for filter tabs.
  // Empty string is the default Hyperliquid DEX.
  static const List<(String, String)> perpDexes = [
    ('', 'HL'),
    ('xyz', 'XYZ'),
    ('vntl', 'Ventuals'),
    ('hyna', 'HyENA'),
    ('km', 'KM'),
    ('flx', 'FLX'),
    ('cash', 'Cash'),
    ('para', 'Para'),
  ];

  // Trades list cap
  static const int tradesListMaxLength = 100;
}
