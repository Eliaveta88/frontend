import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/routing/route_names.dart';
import '../providers/orders_providers.dart';

class OrdersPage extends ConsumerWidget {
  const OrdersPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final async = ref.watch(ordersListProvider);

    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Заказы', style: theme.textTheme.headlineMedium),
                  const SizedBox(height: 4),
                  Text(
                    'Данные с сервиса orders через Traefik',
                    style: theme.textTheme.bodyLarge?.copyWith(color: colors.onSurfaceVariant),
                  ),
                ],
              ),
            ),
            FilledButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.add),
              label: const Text('Новый заказ'),
            ),
          ],
        ),
        const SizedBox(height: 24),
        async.when(
          data: (page) {
            if (page.items.isEmpty) {
              return Card(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Text(
                    'Заказов пока нет (или БД пуста).',
                    style: theme.textTheme.bodyLarge?.copyWith(color: colors.onSurfaceVariant),
                  ),
                ),
              );
            }
            return Card(
              child: DataTable(
                showCheckboxColumn: false,
                columns: const [
                  DataColumn(label: Text('№')),
                  DataColumn(label: Text('Клиент')),
                  DataColumn(label: Text('Статус')),
                  DataColumn(label: Text('Сумма'), numeric: true),
                ],
                rows: [
                  for (final o in page.items)
                    DataRow(
                      onSelectChanged: (_) => context.go('${Routes.orders}/${o.id}'),
                      cells: [
                        DataCell(Text('${o.id}')),
                        DataCell(Text(o.clientName)),
                        DataCell(Text(o.status)),
                        DataCell(Text('₽ ${o.totalAmount.toStringAsFixed(0)}')),
                      ],
                    ),
                ],
              ),
            );
          },
          loading: () => const Center(child: Padding(padding: EdgeInsets.all(32), child: CircularProgressIndicator())),
          error: (e, _) => Card(
            color: colors.errorContainer,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: SelectableText(
                'Не удалось загрузить заказы: $e\n\n'
                'Проверьте, что Traefik и сервис orders запущены, а для Flutter Web задана база API, например:\n'
                'flutter run -d chrome --dart-define=API_BASE_URL=http://localhost',
                style: TextStyle(color: colors.onErrorContainer),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
