import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('material app smoke test stays renderable', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Center(
            child: Text('Praxis MVP Smoke Test'),
          ),
        ),
      ),
    );

    expect(find.text('Praxis MVP Smoke Test'), findsOneWidget);
  });
}
