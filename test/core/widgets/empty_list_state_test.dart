import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:gastroroute_frontend/core/widgets/empty_list_state.dart';

void main() {
  testWidgets('shows title, message and action', (tester) async {
    var tapped = false;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: EmptyListState(
            icon: Icons.inbox_outlined,
            title: 'Пусто',
            message: 'Нет данных',
            actionLabel: 'Обновить',
            onAction: () => tapped = true,
          ),
        ),
      ),
    );

    expect(find.text('Пусто'), findsOneWidget);
    expect(find.text('Нет данных'), findsOneWidget);
    expect(find.text('Обновить'), findsOneWidget);

    await tester.tap(find.text('Обновить'));
    expect(tapped, isTrue);
  });

  testWidgets('works without action', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: EmptyListState(
            icon: Icons.search_off,
            title: 'Нет',
          ),
        ),
      ),
    );
    expect(find.byType(FilledButton), findsNothing);
  });
}
