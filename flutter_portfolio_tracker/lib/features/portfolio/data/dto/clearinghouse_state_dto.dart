class ClearinghouseStateDto {
  const ClearinghouseStateDto({
    required this.marginSummary,
    required this.withdrawable,
    required this.assetPositions,
  });

  factory ClearinghouseStateDto.fromJson(Map<String, dynamic> json) {
    return ClearinghouseStateDto(
      marginSummary: MarginSummaryDto.fromJson(
        json['marginSummary'] as Map<String, dynamic>? ?? {},
      ),
      withdrawable: (json['withdrawable'] as String?) ?? '0',
      assetPositions: (json['assetPositions'] as List<dynamic>? ?? [])
          .cast<Map<String, dynamic>>()
          .map(AssetPositionWrapperDto.fromJson)
          .toList(),
    );
  }

  final MarginSummaryDto marginSummary;
  final String withdrawable;
  final List<AssetPositionWrapperDto> assetPositions;
}

class MarginSummaryDto {
  const MarginSummaryDto({
    required this.accountValue,
    required this.totalMarginUsed,
    required this.totalNtlPos,
  });

  factory MarginSummaryDto.fromJson(Map<String, dynamic> json) =>
      MarginSummaryDto(
        accountValue: (json['accountValue'] as String?) ?? '0',
        totalMarginUsed: (json['totalMarginUsed'] as String?) ?? '0',
        totalNtlPos: (json['totalNtlPos'] as String?) ?? '0',
      );

  final String accountValue;
  final String totalMarginUsed;
  final String totalNtlPos;
}

class AssetPositionWrapperDto {
  const AssetPositionWrapperDto({required this.position});

  factory AssetPositionWrapperDto.fromJson(Map<String, dynamic> json) =>
      AssetPositionWrapperDto(
        position: PositionDto.fromJson(
          json['position'] as Map<String, dynamic>? ?? {},
        ),
      );

  final PositionDto position;
}

class PositionDto {
  const PositionDto({
    required this.coin,
    required this.szi,
    this.entryPx,
    required this.unrealizedPnl,
    required this.marginUsed,
    required this.positionValue,
    required this.returnOnEquity,
    required this.leverage,
    this.liquidationPx,
  });

  factory PositionDto.fromJson(Map<String, dynamic> json) => PositionDto(
        coin: (json['coin'] as String?) ?? '',
        szi: (json['szi'] as String?) ?? '0',
        entryPx: json['entryPx'] as String?,
        unrealizedPnl: (json['unrealizedPnl'] as String?) ?? '0',
        marginUsed: (json['marginUsed'] as String?) ?? '0',
        positionValue: (json['positionValue'] as String?) ?? '0',
        returnOnEquity: (json['returnOnEquity'] as String?) ?? '0',
        leverage: LeverageDto.fromJson(
          json['leverage'] as Map<String, dynamic>? ?? {},
        ),
        liquidationPx: json['liquidationPx'] as String?,
      );

  final String coin;
  final String szi;
  final String? entryPx;
  final String unrealizedPnl;
  final String marginUsed;
  final String positionValue;
  final String returnOnEquity;
  final LeverageDto leverage;
  final String? liquidationPx;
}

class LeverageDto {
  const LeverageDto({
    required this.value,
    required this.type,
  });

  factory LeverageDto.fromJson(Map<String, dynamic> json) => LeverageDto(
        value: (json['value'] as int?) ?? 1,
        type: (json['type'] as String?) ?? 'cross',
      );

  final int value;

  /// 'isolated' or 'cross'.
  final String type;
}
