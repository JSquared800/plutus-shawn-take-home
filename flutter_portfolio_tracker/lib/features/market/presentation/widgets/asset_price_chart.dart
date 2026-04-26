import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_portfolio_tracker/app/theme/app_colors.dart';
import 'package:flutter_portfolio_tracker/features/market/domain/entities/candle.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class AssetPriceChart extends StatefulWidget {
  const AssetPriceChart({
    super.key,
    required this.candles,
    this.height = 240,
  });

  final List<Candle> candles;
  final double height;

  @override
  State<AssetPriceChart> createState() => _AssetPriceChartState();
}

class _AssetPriceChartState extends State<AssetPriceChart> {
  // Deferred one frame after candles arrive so Syncfusion can lay out cleanly.
  bool _chartReady = false;

  @override
  void didUpdateWidget(AssetPriceChart oldWidget) {
    super.didUpdateWidget(oldWidget);
    final wasEmpty = oldWidget.candles.isEmpty;
    final isNowEmpty = widget.candles.isEmpty;

    if (isNowEmpty && !wasEmpty) {
      // Timeframe switch cleared candles — reset so spinner shows again.
      _chartReady = false;
    } else if (wasEmpty && !isNowEmpty && !_chartReady) {
      // Candles just arrived — defer one frame before showing chart.
      SchedulerBinding.instance.addPostFrameCallback((_) {
        if (mounted) setState(() => _chartReady = true);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.candles.isEmpty || !_chartReady) {
      return SizedBox(
        height: widget.height,
        child: const Center(
          child: CircularProgressIndicator(color: AppColors.accent),
        ),
      );
    }

    final candles = widget.candles;
    final start = DateTime.fromMillisecondsSinceEpoch(candles.first.timeMs);
    final end = DateTime.fromMillisecondsSinceEpoch(candles.last.timeMs);
    final span = end.difference(start).abs();
    final isIntraday = span <= const Duration(days: 2);

    return SizedBox(
      height: widget.height,
      child: SfCartesianChart(
        backgroundColor: Colors.transparent,
        plotAreaBackgroundColor: Colors.transparent,
        plotAreaBorderWidth: 0,
        zoomPanBehavior: ZoomPanBehavior(
          // Keep wheel scrolling for the page; use pinch/drag inside chart.
          enableMouseWheelZooming: false,
          enablePinching: true,
          enablePanning: true,
          enableSelectionZooming: true,
          enableDoubleTapZooming: true,
          zoomMode: ZoomMode.x,
        ),
        primaryXAxis: DateTimeAxis(
          isVisible: true,
          axisLine: const AxisLine(width: 0),
          majorTickLines: const MajorTickLines(size: 0),
          majorGridLines: const MajorGridLines(width: 0),
          edgeLabelPlacement: EdgeLabelPlacement.hide,
          maximumLabels: 2,
          intervalType: DateTimeIntervalType.auto,
          dateFormat: DateFormat(isIntraday ? 'HH:mm' : 'MMM d'),
          labelStyle: const TextStyle(
            fontFamily: 'Inter',
            fontSize: 10,
            color: AppColors.textMuted,
          ),
        ),
        primaryYAxis: NumericAxis(
          isVisible: true,
          axisLine: const AxisLine(width: 0),
          majorTickLines: const MajorTickLines(size: 0),
          majorGridLines: MajorGridLines(
            width: 0.6,
            color: AppColors.borderSubtle,
          ),
          maximumLabels: 3,
          opposedPosition: true,
          labelStyle: const TextStyle(
            fontFamily: 'Inter',
            fontSize: 10,
            color: AppColors.textMuted,
          ),
        ),
        tooltipBehavior: TooltipBehavior(
          enable: true,
          header: '',
          format: 'point.y',
          canShowMarker: false,
          color: AppColors.bgSurface,
          borderColor: AppColors.borderStrong,
          borderWidth: 1,
          textStyle: const TextStyle(
            fontFamily: 'Inter',
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        series: <CartesianSeries<Candle, DateTime>>[
          LineSeries<Candle, DateTime>(
            dataSource: candles,
            xValueMapper: (c, _) =>
                DateTime.fromMillisecondsSinceEpoch(c.timeMs),
            yValueMapper: (c, _) => c.close,
            color: AppColors.accent,
            width: 2,
            markerSettings: const MarkerSettings(isVisible: false),
            enableTooltip: true,
          ),
        ],
      ),
    );
  }
}
