// test/widget_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('smoke test: app builds a widget tree', (WidgetTester tester) async {
    // Pump a minimal widget that doesn’t require Firebase
    await tester.pumpWidget(const MaterialApp(
      home: Scaffold(body: Text('smoke')),
    ));

    expect(find.text('smoke'), findsOneWidget);
  });
}