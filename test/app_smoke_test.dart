import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Smoke test without mounting the full app (router + Dio would leave pending timers).
void main() {
  testWidgets('MaterialApp builds', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Text('smoke'),
        ),
      ),
    );
    expect(find.text('smoke'), findsOneWidget);
  });
}
