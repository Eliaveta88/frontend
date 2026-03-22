import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/network/api_services/warehouse_api_service.dart';
import '../../../core/network/dio_error_mapper.dart';
import '../../../core/widgets/async_error_card.dart';
import '../../../core/widgets/bokeh_modal.dart';
import '../../../core/widgets/empty_list_state.dart';
import '../../../core/widgets/loading_skeletons.dart';
import '../providers/warehouse_providers.dart';

class WarehousePage extends ConsumerWidget {
  const WarehousePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final async = ref.watch(warehouseStockProvider);

    return async.when(
      loading: () => ListView(
        padding: AppTheme.pagePadding,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SkeletonLine(width: 120, height: 28),
                    const SizedBox(height: 8),
                    const SkeletonLine(width: 200, height: 16),
                  ],
                ),
              ),
              const SkeletonLine(width: 140, height: 40),
            ],
          ),
          const SizedBox(height: 24),
          const SkeletonLine(width: 100, height: 18),
          const SizedBox(height: 12),
          const TableLoadingSkeleton(columnCount: 4, rowCount: 5),
        ],
      ),
      error: (e, _) => Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: AsyncErrorCard(
            error: e,
            title: 'Не удалось загрузить склад',
            onRetry: () => ref.invalidate(warehouseStockProvider),
          ),
        ),
      ),
      data: (page) => RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(warehouseStockProvider);
          await ref.read(warehouseStockProvider.future);
        },
        child: ListView(
          padding: AppTheme.pagePadding,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Склад',
                        style: theme.textTheme.headlineMedium?.copyWith(letterSpacing: -0.3),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Остатки на складе (${page.total} поз.)',
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: colors.onSurfaceVariant,
                          height: 1.45,
                        ),
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
            if (page.items.isEmpty)
              EmptyListState(
                icon: Icons.warehouse_outlined,
                title: 'Остатков нет',
                message: 'Добавьте оприходование или проверьте данные в БД.',
                actionLabel: 'Обновить',
                onAction: () => ref.invalidate(warehouseStockProvider),
              )
            else
              Card(
                child: DataTable(
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

    await showBokehModal<void>(
      context: context,
      maxWidth: 440,
      child: StatefulBuilder(
        builder: (context, setLocal) {
          return BokehModalCard(
            title: 'Оприходование партии',
            subtitle: 'Новая партия на складе',
            body: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextField(
                  controller: productCtrl,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'product_id',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: qtyCtrl,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Количество',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: unitCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Ед. измерения (unit, kg, …)',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 8),
                ListTile(
                  contentPadding: EdgeInsets.zero,
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
                  decoration: const InputDecoration(
                    labelText: 'Ячейка',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: batchCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Номер партии',
                    border: OutlineInputBorder(),
                  ),
                ),
              ],
            ),
            actions: [
              OutlinedButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Отмена'),
              ),
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
                    if (context.mounted) {
                      Navigator.of(context).pop();
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
      ),
    );
  }
}
