import 'package:flutter_test/flutter_test.dart';
import 'package:jikgam_app/main.dart';

void main() {
  testWidgets('App launches', (WidgetTester tester) async {
    await tester.pumpWidget(const JikgamApp());
    expect(find.text('직감'), findsOneWidget);
  });
}
