import 'package:flutter_portfolio_tracker/core/utils/decimal_parser.dart';
import 'package:flutter_portfolio_tracker/features/portfolio/data/dto/clearinghouse_state_dto.dart';
import 'package:flutter_portfolio_tracker/features/portfolio/domain/entities/account_summary.dart';
import 'package:flutter_portfolio_tracker/features/portfolio/domain/entities/open_position.dart';
import 'package:flutter_portfolio_tracker/features/portfolio/domain/entities/portfolio_snapshot.dart';

abstract final class PortfolioMapper {
  /// Maps a ClearinghouseStateDto into a PortfolioSnapshot (summary + positions).
  /// [address] is the wallet address for context in AccountSummary.
  static PortfolioSnapshot snapshotFromDto(
    ClearinghouseStateDto dto,
    String address,
    {required String dex}
  ) {
    final accountValue =
        DecimalParser.toDouble(dto.marginSummary.accountValue);
    final totalMarginUsed =
        DecimalParser.toDouble(dto.marginSummary.totalMarginUsed);
    final marginUsagePct =
        accountValue > 0 ? (totalMarginUsed / accountValue) * 100 : 0.0;

    final summary = AccountSummary(
      walletAddress: address,
      netEquity: accountValue,
      withdrawable: DecimalParser.toDouble(dto.withdrawable),
      totalMarginUsed: totalMarginUsed,
      totalNtlPos: DecimalParser.toDouble(dto.marginSummary.totalNtlPos),
      marginUsagePct: marginUsagePct.clamp(0.0, 100.0),
      fetchedAt: DateTime.now(),
    );

    // Filter out zero-size positions and sort by absolute notional value desc.
    final positions = dto.assetPositions
        .map((w) => w.position)
        .where((p) => DecimalParser.toDouble(p.szi) != 0.0)
        .map((p) => _positionFromDto(p, dex: dex))
        .toList()
      ..sort((a, b) => b.positionValue.abs().compareTo(a.positionValue.abs()));

    return PortfolioSnapshot(summary: summary, positions: positions);
  }

  static OpenPosition _positionFromDto(PositionDto dto, {required String dex}) {
    return OpenPosition(
      coin: dto.coin,
      dex: dex,
      size: DecimalParser.toDouble(dto.szi),
      entryPx: DecimalParser.toDouble(dto.entryPx),
      unrealizedPnl: DecimalParser.toDouble(dto.unrealizedPnl),
      marginUsed: DecimalParser.toDouble(dto.marginUsed),
      positionValue: DecimalParser.toDouble(dto.positionValue),
      returnOnEquity: DecimalParser.toDouble(dto.returnOnEquity),
      leverageValue: dto.leverage.value,
      leverageType: dto.leverage.type == 'isolated'
          ? LeverageType.isolated
          : LeverageType.cross,
      liquidationPx: DecimalParser.toDoubleOrNull(dto.liquidationPx),
    );
  }
}
