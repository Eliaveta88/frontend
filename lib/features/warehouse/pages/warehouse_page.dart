import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/dio_error_mapper.dart';
import '../../../core/widgets/bokeh_modal.dart';
import '../providers/warehouse_providers.dart';

class WarehousePage extends ConsumerWidget {
  const WarehousePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final async = ref.watch(warehouseStockProvider);

    return async.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: SelectableText(
            'Ошибка: ${dioErrorMessage(e)}',
            style: TextStyle(color: colors.error),
          ),
        ),
      ),
      data: (page) => RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(warehouseStockProvider);
          await ref.read(warehouseStockProvider.future);
        },
        child: ListView(
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
                        'Остатки по данным warehouse API (${page.total} поз.)',
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
              child: page.items.isEmpty
                  ? Padding(
                      padding: const EdgeInsets.all(24),
                      child: Text(
                        'Нет строк на складе (или БД пуста).',
                        style: theme.textTheme.bodyMedium?.copyWith(color: colors.onSurfaceVariant),
                      ),
                    )
                  : DataTable(
                      columns: const [
                        DataColumn(label: Text('Товар')),
                        DataColumn(label: Text('Доступно'), numeric: true),
                        DataColumn(label: Text('Резерв'), numeric: true),
                        DataColumn(label: Text('Ячейка')),
                      ],
                      rows: [
                        for (final s in page.items)
                          DataRow(
                            cells: [
                              DataCell(Text('${s.productName} (#${s.productId})')),
                              DataCell(Text(_fmtQty(s.available))),
                              DataCell(Text(_fmtQty(s.reserved))),
                              DataCell(Text(s.cellLocation)),
                            ],
                          ),
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }

  static String _fmtQty(double q) {
    if (q == q.roundToDouble()) return '${q.toInt()}';
    return q.toStringAsFixed(2);
  }

  void _showReceiveDialog(BuildContext context) {
    showBokehModal(
      context: context,
      child: BokehModalCard(
        title: 'Оприходование партии',
        subtitle: 'POST на склад будет подключён позже',
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
