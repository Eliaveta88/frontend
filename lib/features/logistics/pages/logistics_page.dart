import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/widgets/async_error_card.dart';
import '../../../core/widgets/empty_list_state.dart';
import '../../../core/widgets/loading_skeletons.dart';
import '../providers/logistics_providers.dart';

class LogisticsPage extends ConsumerWidget {
  const LogisticsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final async = ref.watch(logisticsRoutesProvider);

    return async.when(
      loading: () => ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SkeletonLine(width: 140, height: 28),
                    const SizedBox(height: 8),
                    const SkeletonLine(width: 180, height: 16),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          const SkeletonLine(width: 80, height: 18),
          const SizedBox(height: 12),
          const TableLoadingSkeleton(columnCount: 4, rowCount: 5),
        ],
      ),
      error: (e, _) => Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: AsyncErrorCard(
            error: e,
            title: 'Не удалось загрузить логистику',
            onRetry: () => ref.invalidate(logisticsRoutesProvider),
          ),
        ),
      ),
      data: (page) => RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(logisticsRoutesProvider);
          await ref.read(logisticsRoutesProvider.future);
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
                      Text('Логистика', style: theme.textTheme.headlineMedium),
                      const SizedBox(height: 4),
                      Text(
                        'Маршруты (${page.total} всего)',
                        style: theme.textTheme.bodyLarge?.copyWith(color: colors.onSurfaceVariant),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Text('Рейсы', style: theme.textTheme.titleMedium),
            const SizedBox(height: 12),
            if (page.items.isEmpty)
              EmptyListState(
                icon: Icons.local_shipping_outlined,
                title: 'Маршрутов нет',
                message: 'Создайте рейс или обновите список.',
                actionLabel: 'Обновить',
                onAction: () => ref.invalidate(logisticsRoutesProvider),
              )
            else
              Card(
                child: DataTable(
                  columns: const [
                    DataColumn(label: Text('ID')),
                    DataColumn(label: Text('Водитель')),
                    DataColumn(label: Text('Статус')),
                    DataColumn(label: Text('Точек'), numeric: true),
                  ],
                  rows: [
                    for (final r in page.items)
                      DataRow(
                        cells: [
                          DataCell(Text('${r.id}')),
                          DataCell(Text(r.driverName)),
                          DataCell(Text(r.status)),
                          DataCell(Text('${r.pointsCount}')),
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
}
