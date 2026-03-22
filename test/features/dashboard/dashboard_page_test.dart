import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:gastroroute_frontend/core/network/api_client.dart';
import 'package:gastroroute_frontend/features/dashboard/pages/dashboard_page.dart';

import '../../support/fake_dashboard_dio.dart';

void main() {
  testWidgets('DashboardPage loads KPIs from mocked Dio', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          dioProvider.overrideWithValue(createFakeDashboardDio()),
        ],
        child: const MaterialApp(
          home: Scaffold(
            body: DashboardPage(),
          ),
        ),
      ),
    );

    await tester.pump();
    await tester.pumpAndSettle();

    expect(find.textContaining('Часть данных не загрузилась'), findsNothing);
    expect(find.text('Дашборд'), findsOneWidget);
    expect(find.text('42'), findsWidgets);
    expect(find.text('7'), findsWidgets);
    expect(find.text('2'), findsWidgets);
    expect(find.textContaining('1 500'), findsWidgets);

    await tester.drag(find.byType(Scrollable).first, const Offset(0, -800));
    await tester.pumpAndSettle();

    expect(find.textContaining('Пока нет событий'), findsOneWidget);
    expect(find.textContaining('Всего заказов в системе: 99'), findsOneWidget);
  });
}
