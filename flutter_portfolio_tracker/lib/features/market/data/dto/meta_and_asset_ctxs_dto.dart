/// Typed wrappers for the Hyperliquid `metaAndAssetCtxs` response.
///
/// The endpoint returns a 2-element list:
///   [0] = meta object  { universe: [{ name, ... }] }
///   [1] = array of assetCtx objects, index-aligned with universe
class UniverseItemDto {
  const UniverseItemDto({required this.name});

  factory UniverseItemDto.fromJson(Map<String, dynamic> json) {
    return UniverseItemDto(
      name: json['name'] as String? ?? '',
    );
  }

  final String name;
}

class AssetCtxDto {
  const AssetCtxDto({
    required this.dayNtlVlm,
    required this.openInterest,
    required this.prevDayPx,
    required this.markPx,
    this.midPx,
    this.oraclePx,
  });

  factory AssetCtxDto.fromJson(Map<String, dynamic> json) {
    return AssetCtxDto(
      dayNtlVlm: json['dayNtlVlm'] as String?,
      openInterest: json['openInterest'] as String?,
      prevDayPx: json['prevDayPx'] as String?,
      markPx: json['markPx'] as String?,
      midPx: json['midPx'] as String?,
      oraclePx: json['oraclePx'] as String?,
    );
  }

  final String? dayNtlVlm;
  final String? openInterest;
  final String? prevDayPx;
  final String? markPx;
  final String? midPx;
  final String? oraclePx;
}

class MetaAndAssetCtxsDto {
  const MetaAndAssetCtxsDto({
    required this.universe,
    required this.assetCtxs,
  });

  factory MetaAndAssetCtxsDto.fromResponse(List<dynamic> raw) {
    final meta = raw[0] as Map<String, dynamic>;
    final universeRaw = meta['universe'] as List<dynamic>;
    final ctxsRaw = raw[1] as List<dynamic>;

    return MetaAndAssetCtxsDto(
      universe: universeRaw
          .cast<Map<String, dynamic>>()
          .map(UniverseItemDto.fromJson)
          .toList(),
      assetCtxs: ctxsRaw
          .cast<Map<String, dynamic>>()
          .map(AssetCtxDto.fromJson)
          .toList(),
    );
  }

  final List<UniverseItemDto> universe;
  final List<AssetCtxDto> assetCtxs;
}
