import 'package:flutter_portfolio_tracker/core/network/dex_fan_out.dart';
import 'package:flutter_portfolio_tracker/core/result/result.dart';
import 'package:flutter_portfolio_tracker/features/portfolio/data/mappers/portfolio_mapper.dart';
import 'package:flutter_portfolio_tracker/features/portfolio/data/services/portfolio_rest_service.dart';
import 'package:flutter_portfolio_tracker/features/portfolio/domain/entities/account_summary.dart';
import 'package:flutter_portfolio_tracker/features/portfolio/domain/entities/open_position.dart';
import 'package:flutter_portfolio_tracker/features/portfolio/domain/entities/portfolio_snapshot.dart';
import 'package:flutter_portfolio_tracker/features/portfolio/domain/repositories/portfolio_repository.dart';

class PortfolioRepositoryImpl implements PortfolioRepository {
  PortfolioRepositoryImpl({required PortfolioRestService restService})
      : _rest = restService;

  final PortfolioRestService _rest;

  @override
  Future<Result<PortfolioSnapshot>> fetchSnapshot(String address) async {
    final fanOut = await DexFanOut.fetch(
      fetch: (dex) => _rest.fetchClearinghouseState(address, dex: dex),
    );

    final snapshots = fanOut.items
        .map((record) {
          final (dex, dto) = record;
          return PortfolioMapper.snapshotFromDto(dto, address, dex: dex);
        })
        .toList();

    if (snapshots.isEmpty) {
      return Err(UpstreamFailure(
          fanOut.defaultDexError ?? 'Failed to fetch portfolio'));
    }

    return Ok(_mergeSnapshots(address, snapshots));
  }

  PortfolioSnapshot _mergeSnapshots(
    String address,
    List<PortfolioSnapshot> snapshots,
  ) {
    var netEquity = 0.0;
    var withdrawable = 0.0;
    var totalMarginUsed = 0.0;
    var totalNtlPos = 0.0;
    final positions = <OpenPosition>[];

    for (final snapshot in snapshots) {
      final s = snapshot.summary;
      netEquity += s.netEquity;
      withdrawable += s.withdrawable;
      totalMarginUsed += s.totalMarginUsed;
      totalNtlPos += s.totalNtlPos;
      positions.addAll(snapshot.positions);
    }

    positions.sort((a, b) => b.positionValue.abs().compareTo(a.positionValue.abs()));

    final marginUsagePct =
        netEquity > 0 ? ((totalMarginUsed / netEquity) * 100).clamp(0.0, 100.0) : 0.0;

    return PortfolioSnapshot(
      summary: AccountSummary(
        walletAddress: address,
        netEquity: netEquity,
        withdrawable: withdrawable,
        totalMarginUsed: totalMarginUsed,
        totalNtlPos: totalNtlPos,
        marginUsagePct: marginUsagePct,
        fetchedAt: DateTime.now(),
      ),
      positions: positions,
    );
  }
}
