import 'package:flutter/material.dart';

import '../../../core/widgets/bokeh_modal.dart';

class WarehousePage extends StatelessWidget {
  const WarehousePage({super.key});

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
                  Text('Склад', style: theme.textTheme.headlineMedium),
                  const SizedBox(height: 4),
                  Text(
                    'Остатки и движения (скоро)',
                    style: theme.textTheme.bodyLarge?.copyWith(color: colors.onSurfaceVariant),
                  ),
                ],
              ),
            ),
            FilledButton.icon(
              onPressed: () => _showReceiveDialog(context),
              icon: const Icon(Icons.add_box_outlined),
              label: const Text('Оприходовать'),
            ),
          ],
        ),
        const SizedBox(height: 24),
        Text('Остатки', style: theme.textTheme.titleMedium),
        const SizedBox(height: 12),
        Card(
          child: DataTable(
            columns: const [
              DataColumn(label: Text('Товар')),
              DataColumn(label: Text('Доступно'), numeric: true),
              DataColumn(label: Text('Резерв'), numeric: true),
            ],
            rows: const [
              DataRow(cells: [
                DataCell(Text('Пример позиции')),
                DataCell(Text('—')),
                DataCell(Text('—')),
              ]),
            ],
          ),
        ),
      ],
    );
  }

  void _showReceiveDialog(BuildContext context) {
    showBokehModal(
      context: context,
      child: BokehModalCard(
        title: 'Оприходование партии',
        subtitle: 'Подключение к складу',
        body: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(decoration: const InputDecoration(labelText: 'Товар')),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(child: TextFormField(decoration: const InputDecoration(labelText: 'Количество'))),
                const SizedBox(width: 12),
                Expanded(child: TextFormField(decoration: const InputDecoration(labelText: 'Ед. измерения'))),
              ],
            ),
          ],
        ),
        actions: [
          OutlinedButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Отмена')),
          FilledButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Оприходовать')),
        ],
      ),
    );
  }
}
