import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/network/api_services/logistics_api_service.dart';
import '../../../core/network/dio_error_mapper.dart';
import '../../../core/widgets/async_error_card.dart';
import '../../../core/widgets/bokeh_modal.dart';
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
        padding: AppTheme.pagePadding,
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
              const SkeletonLine(width: 130, height: 40),
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
          padding: AppTheme.pagePadding,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Логистика',
                        style: theme.textTheme.headlineMedium?.copyWith(letterSpacing: -0.3),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Маршруты (${page.total} всего)',
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: colors.onSurfaceVariant,
                          height: 1.45,
                        ),
                      ),
                    ],
                  ),
                ),
                FilledButton.icon(
                  onPressed: () => _showNewRouteDialog(context, ref),
                  icon: const Icon(Icons.add),
                  label: const Text('Новый рейс'),
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
                    for (final (i, r) in page.items.indexed)
                      DataRow(
                        color: AppTheme.dataRowStripe(i, colors),
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

List<({int clientId, String address})> _parseRoutePoints(String raw) {
  final out = <({int clientId, String address})>[];
  for (final line in raw.split('\n')) {
    final t = line.trim();
    if (t.isEmpty) continue;
    final semi = t.indexOf(';');
    if (semi <= 0) continue;
    final id = int.tryParse(t.substring(0, semi).trim());
    final addr = t.substring(semi + 1).trim();
    if (id != null && id > 0 && addr.isNotEmpty) {
      out.add((clientId: id, address: addr));
    }
  }
  return out;
}

Future<void> _showNewRouteDialog(BuildContext context, WidgetRef ref) async {
  final vehicleCtrl = TextEditingController(text: '1');
  final driverIdCtrl = TextEditingController(text: '1');
  final driverNameCtrl = TextEditingController();
  final pointsCtrl = TextEditingController(text: '1; Адрес первой точки');
  var start = DateTime.now().add(const Duration(hours: 1));
  var busy = false;

  await showBokehModal<void>(
    context: context,
    maxWidth: 480,
    child: StatefulBuilder(
      builder: (context, setDialogState) {
        Future<void> pickStart() async {
          final d = await showDatePicker(
            context: context,
            initialDate: start,
            firstDate: DateTime.now().subtract(const Duration(days: 1)),
            lastDate: DateTime.now().add(const Duration(days: 365)),
          );
          if (d == null || !context.mounted) return;
          final t = await showTimePicker(
            context: context,
            initialTime: TimeOfDay.fromDateTime(start),
          );
          if (t == null || !context.mounted) return;
          setDialogState(() {
            start = DateTime(d.year, d.month, d.day, t.hour, t.minute);
          });
        }

        return BokehModalCard(
          title: 'Новый рейс',
          subtitle: 'Транспорт, водитель и точки доставки',
          body: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextField(
                controller: vehicleCtrl,
                decoration: const InputDecoration(
                  labelText: 'ID транспорта',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: driverIdCtrl,
                decoration: const InputDecoration(
                  labelText: 'ID водителя',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: driverNameCtrl,
                decoration: const InputDecoration(
                  labelText: 'ФИО водителя',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: busy ? null : pickStart,
                icon: const Icon(Icons.schedule),
                label: Text(
                  'Старт: ${start.toLocal().toString().split('.').first}',
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: pointsCtrl,
                maxLines: 5,
                decoration: const InputDecoration(
                  labelText: 'Точки доставки',
                  hintText: 'Каждая строка: номер клиента; адрес',
                  alignLabelWithHint: true,
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
          actions: [
            OutlinedButton(
              onPressed: busy ? null : () => Navigator.of(context).pop(),
              child: const Text('Отмена'),
            ),
            FilledButton(
              onPressed: busy
                  ? null
                  : () async {
                      final vid = int.tryParse(vehicleCtrl.text.trim());
                      final did = int.tryParse(driverIdCtrl.text.trim());
                      final name = driverNameCtrl.text.trim();
                      final pts = _parseRoutePoints(pointsCtrl.text);
                      if (vid == null || vid <= 0 || did == null || did <= 0) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Укажите корректные ID транспорта и водителя')),
                        );
                        return;
                      }
                      if (name.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Укажите ФИО водителя')),
                        );
                        return;
                      }
                      if (pts.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'Добавьте хотя бы одну точку: «номер клиента; адрес»',
                            ),
                          ),
                        );
                        return;
                      }
                      setDialogState(() => busy = true);
                      try {
                        await ref.read(logisticsApiServiceProvider).createRoute(
                              vehicleId: vid,
                              driverId: did,
                              driverName: name,
                              startTime: start,
                              points: pts,
                            );
                        if (context.mounted) {
                          Navigator.of(context).pop();
                          ref.invalidate(logisticsRoutesProvider);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Маршрут создан')),
                          );
                        }
                      } catch (e) {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(dioErrorMessage(e))),
                          );
                        }
                      } finally {
                        if (context.mounted) {
                          setDialogState(() => busy = false);
                        }
                      }
                    },
              child: busy
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Создать'),
            ),
          ],
        );
      },
    ),
  );

  vehicleCtrl.dispose();
  driverIdCtrl.dispose();
  driverNameCtrl.dispose();
  pointsCtrl.dispose();
}
