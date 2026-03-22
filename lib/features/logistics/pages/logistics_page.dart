import 'package:flutter/material.dart';

class LogisticsPage extends StatelessWidget {
  const LogisticsPage({super.key});

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
                  Text('Логистика', style: theme.textTheme.headlineMedium),
                  const SizedBox(height: 4),
                  Text(
                    'Маршруты и доставка (скоро)',
                    style: theme.textTheme.bodyLarge?.copyWith(color: colors.onSurfaceVariant),
                  ),
                ],
              ),
            ),
            FilledButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.add),
              label: const Text('Новый рейс'),
            ),
          ],
        ),
        const SizedBox(height: 24),
        Text('Рейсы', style: theme.textTheme.titleMedium),
        const SizedBox(height: 12),
        Card(
          child: DataTable(
            columns: const [
              DataColumn(label: Text('Рейс')),
              DataColumn(label: Text('Статус')),
            ],
            rows: const [
              DataRow(cells: [
                DataCell(Text('—')),
                DataCell(Text('данные с бэкенда позже')),
              ]),
            ],
          ),
        ),
      ],
    );
  }
}
