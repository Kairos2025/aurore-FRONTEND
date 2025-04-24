import 'package:flutter_test/flutter_test.dart';
import 'package:aurore_school/main.dart';

void main() {
  testWidgets('AuroreApp builds without crashing', (WidgetTester tester) async {
    await tester.pumpWidget(const AuroreApp());
    expect(find.text('Aurore School'), findsOneWidget);
  });
}
