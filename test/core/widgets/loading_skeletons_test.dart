import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:gastroroute_frontend/core/widgets/loading_skeletons.dart';

void main() {
  testWidgets('TableLoadingSkeleton builds', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: TableLoadingSkeleton(columnCount: 4, rowCount: 3),
        ),
      ),
    );
    expect(find.byType(Card), findsOneWidget);
  });

  testWidgets('DashboardLoadingSkeleton builds', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: DashboardLoadingSkeleton(),
        ),
      ),
    );
    expect(find.byType(Card), findsWidgets);
  });

  testWidgets('FinanceLoadingSkeleton builds', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(child: FinanceLoadingSkeleton()),
        ),
      ),
    );
    expect(find.byType(Card), findsWidgets);
  });
}
