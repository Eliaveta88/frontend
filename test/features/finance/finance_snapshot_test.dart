import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gastroroute_frontend/core/network/api_client.dart';
import 'package:gastroroute_frontend/features/finance/providers/finance_providers.dart';

Dio _dioFinanceBalanceOkTransactionsFail() {
  final dio = Dio(
    BaseOptions(baseUrl: 'http://localhost'),
  );
  dio.interceptors.add(
    InterceptorsWrapper(
      onRequest: (options, handler) {
        final path = options.path;
        if (path.contains('/balance')) {
          handler.resolve(
            Response<Map<String, dynamic>>(
              requestOptions: options,
              statusCode: 200,
              data: {
                'client_id': 1,
                'balance': '100.00',
                'currency': 'RUB',
                'credit_limit': '0',
              },
            ),
          );
          return;
        }
        if (path.contains('/transactions')) {
          handler.reject(
            DioException(
              requestOptions: options,
              type: DioExceptionType.badResponse,
              response: Response(requestOptions: options, statusCode: 503),
            ),
          );
          return;
        }
        handler.reject(
          DioException(requestOptions: options, message: 'unexpected path: $path'),
        );
      },
    ),
  );
  return dio;
}

void main() {
  test('financeSnapshotProvider captures balance but surfaces transactions error', () async {
    final container = ProviderContainer(
      overrides: [
        dioProvider.overrideWithValue(_dioFinanceBalanceOkTransactionsFail()),
      ],
    );
    addTearDown(container.dispose);

    final snap = await container.read(financeSnapshotProvider.future);
    expect(snap.balance, isNotNull);
    expect(snap.balance!['balance'], '100.00');
    expect(snap.balanceError, isNull);
    expect(snap.transactions, isEmpty);
    expect(snap.transactionsError, isNotNull);
    expect(snap.transactionsError!.isNotEmpty, isTrue);
  });
}
