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
                    'Управление заказами клиентов',
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
        const SizedBox(height: 20),
        Row(
          children: [
            _StatusChip(label: 'Все', count: 156, selected: true, colors: colors),
            const SizedBox(width: 8),
            _StatusChip(label: 'Черновик', count: 12, selected: false, colors: colors),
            const SizedBox(width: 8),
            _StatusChip(label: 'Подтверждён', count: 34, selected: false, colors: colors),
            const SizedBox(width: 8),
            _StatusChip(label: 'В доставке', count: 18, selected: false, colors: colors),
            const SizedBox(width: 8),
            _StatusChip(label: 'Закрыт', count: 92, selected: false, colors: colors),
          ],
        ),
        const SizedBox(height: 20),
        Card(
          child: DataTable(
            showCheckboxColumn: false,
            columns: const [
              DataColumn(label: Text('№')),
              DataColumn(label: Text('Клиент')),
              DataColumn(label: Text('Сумма')),
              DataColumn(label: Text('Статус')),
              DataColumn(label: Text('Дата')),
            ],
            rows: List.generate(8, (i) {
              final statuses = ['Черновик', 'Подтверждён', 'В доставке', 'Закрыт'];
              final statusColors = [
                colors.outline,
                colors.primary,
                colors.tertiary,
                colors.primary,
              ];
              final si = i % 4;
              return DataRow(
                onSelectChanged: (_) => context.go('/orders/100${i + 1}'),
                cells: [
                  DataCell(Text('#100${i + 1}')),
                  DataCell(Text([
                    'ООО «Ресторатор»',
                    'ИП Козлов А.В.',
                    'АО «ФудСервис»',
                    'ООО «Шеф-Повар»',
                    'ИП Белова М.Н.',
                    'ООО «ГастроПлюс»',
                    'АО «ТрейдФуд»',
                    'ООО «Вкус»',
                  ][i])),
                  DataCell(Text('₽ ${(i + 1) * 42 + 180} 000')),
                  DataCell(
                    Chip(
                      label: Text(statuses[si], style: TextStyle(fontSize: 12, color: statusColors[si])),
                      backgroundColor: statusColors[si].withAlpha(20),
                      side: BorderSide.none,
                      padding: EdgeInsets.zero,
                      visualDensity: VisualDensity.compact,
                    ),
                  ),
                  DataCell(Text('1${i + 1}.03.2026')),
                ],
              );
            }),
          ),
        ),
      ],
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({
    required this.label,
    required this.count,
    required this.selected,
    required this.colors,
  });

  final String label;
  final int count;
  final bool selected;
  final ColorScheme colors;

  @override
  Widget build(BuildContext context) {
    return FilterChip(
      label: Text('$label ($count)'),
      selected: selected,
      onSelected: (_) {},
      selectedColor: colors.primaryContainer,
    );
  }
}
