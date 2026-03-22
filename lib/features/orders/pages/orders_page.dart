import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class OrdersPage extends StatelessWidget {
  const OrdersPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

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
                    'Заказы клиентов (скоро)',
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
        Card(
          child: DataTable(
            showCheckboxColumn: false,
            columns: const [
              DataColumn(label: Text('№')),
              DataColumn(label: Text('Статус')),
            ],
            rows: [
              DataRow(
                onSelectChanged: (_) => context.go('/orders/demo'),
                cells: const [
                  DataCell(Text('—')),
                  DataCell(Text('список заказов с API позже')),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}
