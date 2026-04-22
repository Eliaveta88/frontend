import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_client.dart';
import '../../../core/network/api_config.dart';
import '../../../core/network/dio_error_mapper.dart';

class FinanceSnapshot {
  const FinanceSnapshot({
    this.balance,
    this.transactions = const [],
    this.balanceError,
    this.transactionsError,
  });

  final Map<String, dynamic>? balance;
  final List<Map<String, dynamic>> transactions;
  final String? balanceError;
  final String? transactionsError;
}

final financeClientIdProvider = StateProvider<int>((ref) => 1);

final financeSnapshotProvider = FutureProvider.autoDispose<FinanceSnapshot>((ref) async {
  final clientId = ref.watch(financeClientIdProvider);
  final dio = ref.watch(dioProvider);

  Map<String, dynamic>? balance;
  String? balanceErr;

  try {
    final br = await dio.get<Map<String, dynamic>>(ApiPaths.financeBalance(clientId));
    if (br.statusCode == 200 && br.data != null) {
      balance = br.data;
    }
  } on DioException catch (e) {
    if (e.response?.statusCode == 404) {
      balanceErr = 'Счёт для клиента № $clientId не найден';
    } else {
      balanceErr = e.message ?? 'Ошибка баланса';
    }
  }

  List<Map<String, dynamic>> txs = [];
  String? txsErr;
  try {
    final tr = await dio.get<Map<String, dynamic>>(ApiPaths.financeTransactions(clientId));
    final data = tr.data;
    if (data != null) {
      final items = data['items'] as List<dynamic>? ?? [];
      txs = items.map((e) => Map<String, dynamic>.from(e as Map)).toList();
    }
  } catch (e) {
    txsErr = dioErrorMessage(e);
  }

  return FinanceSnapshot(
    balance: balance,
    transactions: txs,
    balanceError: balanceErr,
    transactionsError: txsErr,
  );
});
