import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_services/warehouse_api_service.dart';
import '../../../core/network/dio_error_mapper.dart';
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
                  onPressed: () => WarehousePage._showReceiveDialog(context, ref),
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

  static Future<void> _showReceiveDialog(BuildContext context, WidgetRef ref) async {
    final productCtrl = TextEditingController(text: '1');
    final qtyCtrl = TextEditingController(text: '10');
    final unitCtrl = TextEditingController(text: 'kg');
    final cellCtrl = TextEditingController(text: 'A-01');
    final batchCtrl = TextEditingController(text: 'BATCH-${DateTime.now().millisecondsSinceEpoch}');
    var expiry = DateTime.now().add(const Duration(days: 30));

    final messenger = ScaffoldMessenger.of(context);

    await showDialog<void>(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setLocal) {
            return AlertDialog(
              title: const Text('Оприходование партии'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: productCtrl,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'product_id'),
                    ),
                    TextField(
                      controller: qtyCtrl,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'Количество'),
                    ),
                    TextField(
                      controller: unitCtrl,
                      decoration: const InputDecoration(labelText: 'Ед. измерения (unit, kg, …)'),
                    ),
                    ListTile(
                      title: const Text('Срок годности'),
                      subtitle: Text(expiry.toLocal().toString().split(' ').first),
                      trailing: const Icon(Icons.calendar_today),
                      onTap: () async {
                        final d = await showDatePicker(
                          context: context,
                          initialDate: expiry,
                          firstDate: DateTime.now(),
                          lastDate: DateTime.now().add(const Duration(days: 3650)),
                        );
                        if (d != null) {
                          setLocal(() {
                            expiry = DateTime(d.year, d.month, d.day, 12);
                          });
                        }
                      },
                    ),
                    TextField(
                      controller: cellCtrl,
                      decoration: const InputDecoration(labelText: 'Ячейка'),
                    ),
                    TextField(
                      controller: batchCtrl,
                      decoration: const InputDecoration(labelText: 'Номер партии'),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Отмена')),
                FilledButton(
                  onPressed: () async {
                    final pid = int.tryParse(productCtrl.text.trim());
                    final qty = int.tryParse(qtyCtrl.text.trim());
                    if (pid == null || qty == null || qty <= 0) {
                      messenger.showSnackBar(
                        const SnackBar(content: Text('Укажите корректные product_id и количество')),
                      );
                      return;
                    }
                    try {
                      await ref.read(warehouseApiServiceProvider).receiveBatch(
                            productId: pid,
                            quantity: qty,
                            unitType: unitCtrl.text.trim().isEmpty ? 'unit' : unitCtrl.text.trim(),
                            expiryDate: expiry,
                            cellLocation: cellCtrl.text.trim(),
                            batchReference: batchCtrl.text.trim(),
                          );
                      ref.invalidate(warehouseStockProvider);
                      if (ctx.mounted) {
                        Navigator.pop(ctx);
                        messenger.showSnackBar(
                          const SnackBar(content: Text('Партия оприходована')),
                        );
                      }
                    } catch (e) {
                      messenger.showSnackBar(
                        SnackBar(content: Text(dioErrorMessage(e))),
                      );
                    }
                  },
                  child: const Text('Оприходовать'),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
