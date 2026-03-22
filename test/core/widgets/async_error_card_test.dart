import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:gastroroute_frontend/core/widgets/async_error_card.dart';

void main() {
  testWidgets('shows title and retry', (tester) async {
    var retried = false;
    final err = DioException(
      requestOptions: RequestOptions(path: '/'),
      type: DioExceptionType.badResponse,
      response: Response(
        requestOptions: RequestOptions(path: '/'),
        statusCode: 503,
        data: {'detail': 'Service down'},
      ),
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: AsyncErrorCard(
            error: err,
            title: 'Ошибка загрузки',
            onRetry: () => retried = true,
          ),
        ),
      ),
    );

    expect(find.text('Ошибка загрузки'), findsOneWidget);
    expect(find.text('Service down'), findsOneWidget);
    await tester.tap(find.text('Повторить'));
    expect(retried, isTrue);
  });

  testWidgets('optional hint', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: AsyncErrorCard(
            error: 'plain',
            title: 'Title',
            hint: 'Подсказка',
          ),
        ),
      ),
    );
    expect(find.text('Подсказка'), findsOneWidget);
  });
}
