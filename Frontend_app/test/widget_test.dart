import 'package:flutter_test/flutter_test.dart';
import 'package:hillguard/main.dart';

void main() {
  testWidgets('HillGuard Smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const HillGuardApp());
    expect(find.text('HillGuard'), findsNothing); // smoke test placeholder
  });
}
