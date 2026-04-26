import 'package:flutter/material.dart';
import 'package:flutter_portfolio_tracker/app/theme/app_colors.dart';
import 'package:flutter_portfolio_tracker/app/theme/app_text_styles.dart';
import 'package:flutter_portfolio_tracker/core/utils/num_formatters.dart';
import 'package:flutter_portfolio_tracker/features/market/domain/entities/trade.dart';

// Row height kept constant so the fixed-height ListView can be sized exactly.
const double _kTradeRowHeight = 34.0;

class TradesTable extends StatelessWidget {
  const TradesTable({super.key, required this.trades});
  final List<Trade> trades;

  @override
  Widget build(BuildContext context) {
    if (trades.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 24),
        child: Center(
          child: Text('Waiting for trades...', style: TextStyle(color: AppColors.textMuted)),
        ),
      );
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          child: Row(
            children: [
              Expanded(child: Text('PRICE', style: AppTextStyles.tradeTableHeader)),
              Expanded(
                child: Text(
                  'SIZE',
                  style: AppTextStyles.tradeTableHeader,
                  textAlign: TextAlign.center,
                ),
              ),
              Expanded(
                child: Text(
                  'TIME',
                  style: AppTextStyles.tradeTableHeader,
                  textAlign: TextAlign.right,
                ),
              ),
            ],
          ),
        ),
        const Divider(height: 1),
        // Fixed height avoids shrinkWrap double-layout and enables virtualization.
        SizedBox(
          height: trades.length * _kTradeRowHeight,
          child: ListView.builder(
            itemCount: trades.length,
            itemExtent: _kTradeRowHeight,
            itemBuilder: (context, i) {
              final t = trades[i];
              // RepaintBoundary isolates each row's paint phase.
              return RepaintBoundary(
                key: ValueKey(t.tid),
                child: _TradeRow(trade: t),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _TradeRow extends StatelessWidget {
  const _TradeRow({required this.trade});
  final Trade trade;

  @override
  Widget build(BuildContext context) {
    final color =
        trade.isBuy ? AppColors.positive : AppColors.negativeLight;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
      child: Row(
        children: [
          Expanded(
            child: Text(
              NumFormatters.price(trade.px),
              style: AppTextStyles.tradeCell.copyWith(color: color),
            ),
          ),
          Expanded(
            child: Text(
              NumFormatters.cryptoSize(trade.sz),
              style: AppTextStyles.tradeCell.copyWith(color: AppColors.textPrimary),
              textAlign: TextAlign.center,
            ),
          ),
          Expanded(
            child: Text(
              NumFormatters.tradeTime(trade.timeMs),
              style: AppTextStyles.tradeCell.copyWith(color: AppColors.textMuted),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }
}
