import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../api_client.dart';
import '../api_config.dart';

const _uuid = Uuid();

/// Операции финансового API (баланс и транзакции загружаются отдельно в [financeSnapshotProvider]).
class FinanceApiService {
  FinanceApiService(this._dio);

  final Dio _dio;

  Future<Map<String, dynamic>> createTransaction({
    required int clientId,
    required double amount,
    required String description,
    String transactionType = 'payment',
    String? idempotencyKey,
  }) async {
    final key = idempotencyKey ?? _uuid.v4();
    final r = await _dio.post<Map<String, dynamic>>(
      ApiPaths.financeTransactionsPost,
      data: {
        'client_id': clientId,
        'amount': amount,
        'description': description,
        'idempotency_key': key,
        'transaction_type': transactionType,
      },
      options: Options(
        headers: {'Idempotency-Key': key},
      ),
    );
    final data = r.data;
    if (data == null) {
      throw Exception('Пустой ответ при проведении оплаты');
    }
    return data;
  }

  Future<Map<String, dynamic>> generateInvoice({
    required int clientId,
    required List<int> orderIds,
  }) async {
    final r = await _dio.post<Map<String, dynamic>>(
      ApiPaths.financeInvoiceGenerate,
      data: {
        'client_id': clientId,
        'order_ids': orderIds,
      },
    );
    final data = r.data;
    if (data == null) {
      throw Exception('Пустой ответ при формировании счёта');
    }
    return data;
  }
}

final financeApiServiceProvider = Provider<FinanceApiService>((ref) {
  return FinanceApiService(ref.watch(dioProvider));
});
