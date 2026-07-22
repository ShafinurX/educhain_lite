import 'package:flutter_test/flutter_test.dart';
import 'package:educhain_lite/main.dart';

void main() {
  testWidgets('EduChain smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const EduChainApp());
  });
}
