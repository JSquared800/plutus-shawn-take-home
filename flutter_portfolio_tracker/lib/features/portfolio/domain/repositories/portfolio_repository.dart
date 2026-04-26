import 'package:flutter_portfolio_tracker/core/result/result.dart';
import 'package:flutter_portfolio_tracker/features/portfolio/domain/entities/portfolio_snapshot.dart';

abstract class PortfolioRepository {
  /// Fetches account summary + all non-zero open positions.
  /// May aggregate multiple clearinghouseState responses (one per supported DEX).
  Future<Result<PortfolioSnapshot>> fetchSnapshot(String address);
}
