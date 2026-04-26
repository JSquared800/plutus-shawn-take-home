import 'package:flutter/material.dart';
import 'package:flutter_portfolio_tracker/core/network/api_constants.dart';
import 'package:flutter_portfolio_tracker/shared_ui/widgets/underline_chip.dart';

class DexFilterStrip extends StatelessWidget {
  const DexFilterStrip({
    super.key,
    required this.selectedDex,
    required this.onSelected,
  });

  /// null = All. Empty string = HL. Other = specific DEX name.
  final String? selectedDex;
  final void Function(String? dex) onSelected;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 34,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
        children: [
          UnderlineChip(
            label: 'All',
            selected: selectedDex == null,
            onTap: () => onSelected(null),
          ),
          const SizedBox(width: 16),
          ...ApiConstants.perpDexes.map((dex) {
            return Padding(
              padding: const EdgeInsets.only(right: 16),
              child: UnderlineChip(
                label: dex.$2,
                selected: selectedDex == dex.$1,
                onTap: () => onSelected(dex.$1),
              ),
            );
          }),
        ],
      ),
    );
  }
}

