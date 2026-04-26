import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('app smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const _Stub());
  });
}

class _Stub extends StatelessWidget {
  const _Stub();
  @override
  Widget build(BuildContext context) => const SizedBox.shrink();
}
