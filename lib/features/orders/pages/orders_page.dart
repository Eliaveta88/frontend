import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/network/api_services/orders_api_service.dart';
import '../../../core/network/dio_error_mapper.dart';
import '../../../core/routing/route_names.dart';
import '../../../core/widgets/async_error_card.dart';
import '../../../core/widgets/empty_list_state.dart';
import '../../../core/widgets/loading_skeletons.dart';
import '../providers/orders_providers.dart';

class OrdersPage extends ConsumerWidget {
  const OrdersPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final async = ref.watch(ordersListProvider);
    final skip = ref.watch(ordersSkipProvider);

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
              onPressed: () => _showNewOrderDialog(context, ref),
              icon: const Icon(Icons.add),
              label: const Text('Новый заказ'),
            ),
          ],
        ),
        const SizedBox(height: 24),
        async.when(
          data: (page) {
            final canPrev = skip > 0;
            final canNext = skip + page.items.length < page.total;
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (page.items.isEmpty)
                  EmptyListState(
                    icon: Icons.receipt_long_outlined,
                    title: page.total == 0 ? 'Заказов пока нет' : 'На этой странице пусто',
                    message: page.total == 0
                        ? 'Создайте первый заказ кнопкой «Новый заказ».'
                        : 'Всего в системе: ${page.total}. Перейдите на другую страницу списка.',
                    actionLabel: 'Обновить список',
                    onAction: () => ref.invalidate(ordersListProvider),
                  )
                else
                  Card(
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
                  ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Text(
                      'Всего: ${page.total} · страница ${skip ~/ kOrdersPageSize + 1}',
                      style: theme.textTheme.bodySmall?.copyWith(color: colors.onSurfaceVariant),
                    ),
                    const Spacer(),
                    OutlinedButton(
                      onPressed: canPrev
                          ? () {
                              ref.read(ordersSkipProvider.notifier).state =
                                  (skip - kOrdersPageSize).clamp(0, 1 << 30);
                            }
                          : null,
                      child: const Text('Назад'),
                    ),
                    const SizedBox(width: 8),
                    OutlinedButton(
                      onPressed: canNext
                          ? () {
                              ref.read(ordersSkipProvider.notifier).state = skip + kOrdersPageSize;
                            }
                          : null,
                      child: const Text('Вперёд'),
                    ),
                  ],
                ),
              ],
            );
          },
          loading: () => Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const TableLoadingSkeleton(columnCount: 4, rowCount: 5),
              const SizedBox(height: 12),
              Row(
                children: [
                  const SkeletonLine(width: 160, height: 12),
                  const Spacer(),
                  const SkeletonLine(width: 72, height: 36),
                  const SizedBox(width: 8),
                  const SkeletonLine(width: 72, height: 36),
                ],
              ),
            ],
          ),
          error: (e, _) => AsyncErrorCard(
            error: e,
            title: 'Не удалось загрузить заказы',
            onRetry: () => ref.invalidate(ordersListProvider),
            hint:
                'Проверьте, что Traefik и сервис orders запущены, а для Flutter Web задана база API, например:\n'
                'flutter run -d chrome --dart-define=API_BASE_URL=http://localhost',
          ),
        ),
      ],
    );
  }

  Future<void> _showNewOrderDialog(BuildContext context, WidgetRef ref) async {
    final clientCtrl = TextEditingController(text: '1');
    final productCtrl = TextEditingController(text: '1');
    final qtyCtrl = TextEditingController(text: '10');
    final notesCtrl = TextEditingController();
    var delivery = DateTime.now().add(const Duration(days: 1));

    await showDialog<void>(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setLocal) {
            return AlertDialog(
              title: const Text('Новый заказ'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: clientCtrl,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'client_id'),
                    ),
                    TextField(
                      controller: productCtrl,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'product_id'),
                    ),
                    TextField(
                      controller: qtyCtrl,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: const InputDecoration(labelText: 'Количество'),
                    ),
                    const SizedBox(height: 8),
                    ListTile(
                      title: const Text('Дата доставки'),
                      subtitle: Text('${delivery.toLocal()}'.split(' ').take(2).join(' ')),
                      trailing: const Icon(Icons.calendar_today),
                      onTap: () async {
                        final d = await showDatePicker(
                          context: context,
                          initialDate: delivery,
                          firstDate: DateTime.now(),
                          lastDate: DateTime.now().add(const Duration(days: 365)),
                        );
                        if (d != null) {
                          setLocal(() {
                            delivery = DateTime(d.year, d.month, d.day, delivery.hour, delivery.minute);
                          });
                        }
                      },
                    ),
                    TextField(
                      controller: notesCtrl,
                      decoration: const InputDecoration(labelText: 'Заметки (необязательно)'),
                      maxLines: 2,
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Отмена')),
                FilledButton(
                  onPressed: () async {
                    final clientId = int.tryParse(clientCtrl.text.trim());
                    final pid = int.tryParse(productCtrl.text.trim());
                    final qty = double.tryParse(qtyCtrl.text.trim().replaceAll(',', '.'));
                    if (clientId == null || pid == null || qty == null || qty <= 0) {
                      return;
                    }
                    try {
                      await ref.read(ordersApiServiceProvider).createOrder(
                            clientId: clientId,
                            items: [
                              {'product_id': pid, 'quantity': qty},
                            ],
                            deliveryDate: delivery,
                            notes: notesCtrl.text.trim().isEmpty ? null : notesCtrl.text.trim(),
                          );
                      ref.invalidate(ordersListProvider);
                      if (ctx.mounted) Navigator.pop(ctx);
                    } catch (e) {
                      if (ctx.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(dioErrorMessage(e))),
                        );
                      }
                    }
                  },
                  child: const Text('Создать'),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
