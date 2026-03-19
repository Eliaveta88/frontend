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
                    'Остатки, партии и движения товара',
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
        const SizedBox(height: 20),
        Wrap(
          spacing: 16,
          runSpacing: 16,
          children: [
            _StockMini(icon: Icons.inventory_2, label: 'Всего позиций', value: '3 842', colors: colors),
            _StockMini(icon: Icons.warning_amber, label: 'Истекает < 7 дн', value: '28', colors: colors, alert: true),
            _StockMini(icon: Icons.lock_clock, label: 'В резерве', value: '640 кг', colors: colors),
          ],
        ),
        const SizedBox(height: 24),
        Text('Горячие остатки', style: theme.textTheme.titleMedium),
        const SizedBox(height: 12),
        Card(
          child: DataTable(
            columns: const [
              DataColumn(label: Text('Товар')),
              DataColumn(label: Text('Доступно'), numeric: true),
              DataColumn(label: Text('Резерв'), numeric: true),
              DataColumn(label: Text('Ближайший срок')),
              DataColumn(label: Text('Ячейка')),
            ],
            rows: [
              _stockRow('Сыр Российский 50%', '480 кг', '120 кг', '28.04.2026', 'A-01-03'),
              _stockRow('Масло сливочное 82.5%', '320 кг', '80 кг', '15.05.2026', 'A-02-01'),
              _stockRow('Молоко 3.2% (пак.)', '1 200 шт', '200 шт', '25.03.2026', 'B-01-02'),
              _stockRow('Филе куриное охл.', '85 кг', '40 кг', '22.03.2026', 'C-01-01'),
              _stockRow('Говядина 1 кат. б/к', '260 кг', '0 кг', '10.04.2026', 'C-02-04'),
              _stockRow('Мука пш. в/с 50кг', '140 мш', '20 мш', '01.09.2026', 'D-01-01'),
            ],
          ),
        ),
      ],
    );
  }

  DataRow _stockRow(String product, String avail, String reserve, String expiry, String cell) {
    return DataRow(cells: [
      DataCell(Text(product)),
      DataCell(Text(avail)),
      DataCell(Text(reserve)),
      DataCell(Text(expiry)),
      DataCell(Text(cell)),
    ]);
  }

  void _showReceiveDialog(BuildContext context) {
    showBokehModal(
      context: context,
      child: BokehModalCard(
        title: 'Оприходование партии',
        subtitle: 'Добавить новую партию товара на склад',
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
            const SizedBox(height: 12),
            TextFormField(decoration: const InputDecoration(labelText: 'Срок годности', hintText: 'ДД.ММ.ГГГГ')),
            const SizedBox(height: 12),
            TextFormField(decoration: const InputDecoration(labelText: 'Ячейка склада')),
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

class _StockMini extends StatelessWidget {
  const _StockMini({
    required this.icon,
    required this.label,
    required this.value,
    required this.colors,
    this.alert = false,
  });

  final IconData icon;
  final String label;
  final String value;
  final ColorScheme colors;
  final bool alert;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = alert ? colors.error : colors.primary;

    return SizedBox(
      width: 200,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withAlpha(25),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 22),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(value, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
                  Text(label, style: theme.textTheme.labelSmall?.copyWith(color: colors.onSurfaceVariant)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
