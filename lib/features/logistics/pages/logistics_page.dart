import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/dio_error_mapper.dart';
import '../providers/logistics_providers.dart';

class LogisticsPage extends ConsumerWidget {
  const LogisticsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final async = ref.watch(logisticsRoutesProvider);

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
              child: page.items.isEmpty
                  ? Padding(
                      padding: const EdgeInsets.all(24),
                      child: Text(
                        'Нет маршрутов (или БД пуста).',
                        style: theme.textTheme.bodyMedium?.copyWith(color: colors.onSurfaceVariant),
                      ),
                    )
                  : DataTable(
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
