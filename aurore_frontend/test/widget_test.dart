import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import '../lib/main.dart';

void main() {
  testWidgets('AuroreApp loads LoadingScreen', (WidgetTester tester) async {
    await tester.pumpWidget(const AuroreApp());
    await tester.pump(); // Allow async loading
    expect(find.text('Loading Aurore School...'), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });
}
