import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Framework can render a widget tree', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Text('OK'),
        ),
      ),
    );

    await tester.pump();
    expect(find.text('OK'), findsOneWidget);
  });
}
