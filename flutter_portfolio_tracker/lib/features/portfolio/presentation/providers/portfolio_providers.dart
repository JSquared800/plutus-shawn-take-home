import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_portfolio_tracker/features/portfolio/data/repositories/portfolio_repository_impl.dart';
import 'package:flutter_portfolio_tracker/features/portfolio/data/services/portfolio_rest_service.dart';
import 'package:flutter_portfolio_tracker/features/portfolio/domain/repositories/portfolio_repository.dart';
import 'package:flutter_portfolio_tracker/features/portfolio/presentation/view_models/portfolio_view_model.dart';

final portfolioRestServiceProvider = Provider<PortfolioRestService>(
  (_) => PortfolioRestService(),
);

final portfolioRepositoryProvider = Provider<PortfolioRepository>((ref) {
  return PortfolioRepositoryImpl(
    restService: ref.watch(portfolioRestServiceProvider),
  );
});

final portfolioViewModelProvider =
    StateNotifierProvider<PortfolioViewModel, PortfolioViewState>((ref) {
  return PortfolioViewModel(ref.watch(portfolioRepositoryProvider));
});
