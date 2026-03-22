import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/network/dio_error_mapper.dart';
import '../data/order_models.dart';
import '../providers/orders_providers.dart';

class OrderDetailPage extends ConsumerWidget {
  const OrderDetailPage({super.key, required this.id});

  final String id;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final parsed = int.tryParse(id);
    if (parsed == null) {
      return ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Text('Некорректный номер заказа: $id', style: theme.textTheme.titleMedium),
        ],
      );
    }

    final async = ref.watch(orderDetailProvider(parsed));

    return async.when(
      data: (order) => _OrderDetailBody(order: order),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => ListView(
        padding: const EdgeInsets.all(24),
        children: [
          SelectableText(
            'Ошибка загрузки заказа: ${dioErrorMessage(e)}',
            style: TextStyle(color: colors.error),
          ),
        ],
      ),
    );
  }
}

class _OrderDetailBody extends StatelessWidget {
  const _OrderDetailBody({required this.order});

  final OrderDetail order;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        Row(
          children: [
            IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => Navigator.of(context).maybePop(),
            ),
            const SizedBox(width: 8),
            Text('Заказ #${order.id}', style: theme.textTheme.headlineMedium),
            const SizedBox(width: 12),
            Chip(
              label: Text(order.status, style: TextStyle(color: colors.primary, fontSize: 12)),
              backgroundColor: colors.primaryContainer,
              side: BorderSide.none,
              visualDensity: VisualDensity.compact,
            ),
          ],
        ),
        const SizedBox(height: 24),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 2,
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Состав заказа', style: theme.textTheme.titleMedium),
                      const SizedBox(height: 16),
                      DataTable(
                        columns: const [
                          DataColumn(label: Text('Товар')),
                          DataColumn(label: Text('Кол-во'), numeric: true),
                          DataColumn(label: Text('Цена'), numeric: true),
                          DataColumn(label: Text('Сумма'), numeric: true),
                        ],
                        rows: [
                          for (final (i, line) in order.items.indexed)
                            DataRow(
                              color: AppTheme.dataRowStripe(i, colors),
                              cells: [
                                DataCell(Text(line.productName)),
                                DataCell(Text(line.quantity.toString())),
                                DataCell(Text('₽ ${line.unitPrice.toStringAsFixed(0)}')),
                                DataCell(Text('₽ ${line.total.toStringAsFixed(0)}')),
                              ],
                            ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Align(
                        alignment: Alignment.centerRight,
                        child: Text(
                          'Итого: ${order.formattedTotal}',
                          style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                children: [
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Клиент', style: theme.textTheme.titleMedium),
                          const SizedBox(height: 12),
                          _InfoRow(label: 'Название', value: order.clientName),
                          _InfoRow(label: 'ID', value: '${order.clientId}'),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Доставка', style: theme.textTheme.titleMedium),
                          const SizedBox(height: 12),
                          _InfoRow(
                            label: 'Дата',
                            value: _formatDate(order.deliveryDate),
                          ),
                          if (order.routeId != null)
                            _InfoRow(label: 'Рейс (route_id)', value: '${order.routeId}'),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  static String _formatDate(DateTime d) {
    String pad2(int n) => n.toString().padLeft(2, '0');
    return '${pad2(d.day)}.${pad2(d.month)}.${d.year}';
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          Expanded(child: Text(value, style: theme.textTheme.bodyMedium)),
        ],
      ),
    );
  }
}
