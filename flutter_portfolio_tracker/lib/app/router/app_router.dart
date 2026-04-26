import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_portfolio_tracker/features/market/presentation/views/market_view.dart';
import 'package:flutter_portfolio_tracker/features/market/presentation/views/asset_detail_view.dart';
import 'package:flutter_portfolio_tracker/features/portfolio/presentation/views/portfolio_view.dart';
import 'package:flutter_portfolio_tracker/app/theme/app_colors.dart';

abstract final class AppRoutes {
  static const market = '/market';
  static const portfolio = '/portfolio';
}

final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: AppRoutes.market,
    routes: [
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) =>
            _AppShell(navigationShell: navigationShell),
        branches: [
          StatefulShellBranch(routes: [
            GoRoute(
              path: AppRoutes.market,
              builder: (context, state) => const MarketView(),
              routes: [
                GoRoute(
                  path: ':coin',
                  builder: (context, state) {
                    final coin = state.pathParameters['coin'] ?? 'BTC';
                    return AssetDetailView(coin: coin);
                  },
                ),
              ],
            ),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
              path: AppRoutes.portfolio,
              builder: (context, state) => const PortfolioView(),
            ),
          ]),
        ],
      ),
    ],
  );
});

class _AppShell extends StatelessWidget {
  const _AppShell({required this.navigationShell});
  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgDeep,
      body: navigationShell,
      bottomNavigationBar: _BottomNav(
        currentIndex: navigationShell.currentIndex,
        onTap: navigationShell.goBranch,
      ),
    );
  }
}

class _BottomNav extends StatelessWidget {
  const _BottomNav({required this.currentIndex, required this.onTap});
  final int currentIndex;
  final void Function(int) onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.bgDeep,
        border: Border(
          top: BorderSide(color: AppColors.borderSubtle, width: 0.5),
        ),
      ),
      child: BottomNavigationBar(
        currentIndex: currentIndex,
        onTap: onTap,
        backgroundColor: Colors.transparent,
        elevation: 0,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.show_chart_rounded, size: 22),
            label: 'Markets',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_balance_wallet_outlined, size: 22),
            label: 'Portfolio',
          ),
        ],
      ),
    );
  }
}
