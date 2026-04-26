import 'package:equatable/equatable.dart';
import 'package:flutter_portfolio_tracker/features/portfolio/domain/entities/account_summary.dart';
import 'package:flutter_portfolio_tracker/features/portfolio/domain/entities/open_position.dart';

/// Combined result of one or more clearinghouseState API calls.
/// Portfolio data may be merged across multiple DEX responses.
class PortfolioSnapshot extends Equatable {
  const PortfolioSnapshot({
    required this.summary,
    required this.positions,
  });

  final AccountSummary summary;

  /// All positions with non-zero size, sorted by |positionValue| descending.
  final List<OpenPosition> positions;

  @override
  List<Object?> get props => [summary, positions];
}
