import 'package:flutter/material.dart';
import 'package:flutter_portfolio_tracker/shared_ui/widgets/underline_chip.dart';

class TimeframeSelector extends StatelessWidget {
  const TimeframeSelector({
    super.key,
    required this.intervals,
    required this.selected,
    required this.onSelected,
  });

  final List<String> intervals;
  final String selected;
  final void Function(String) onSelected;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 34,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: intervals.length,
        separatorBuilder: (_, __) => const SizedBox(width: 16),
        itemBuilder: (context, i) {
          final interval = intervals[i];
          return UnderlineChip(
            label: interval,
            selected: interval == selected,
            onTap: () => onSelected(interval),
            upperCase: true,
          );
        },
      ),
    );
  }
}
