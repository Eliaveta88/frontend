import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/widgets/async_error_card.dart';
import '../../../core/widgets/loading_skeletons.dart';
import '../data/activity_feed_item.dart';
import '../providers/dashboard_activity_provider.dart';
import '../providers/dashboard_providers.dart';

/// Дашборд: ключевые показатели по заказам, каталогу и финансам.
class DashboardPage extends ConsumerWidget {
  const DashboardPage({super.key});

  static String _fmtInt(int? v) => v == null ? '—' : '$v';
  static String _fmtMoney(double? v) {
    if (v == null) return '—';
    if (v == 0) return '₽ 0';
    return '₽ ${v.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]} ')}';
  }

  static String _fmtActivityTime(DateTime d) {
    final dd = d.day.toString().padLeft(2, '0');
    final mm = d.month.toString().padLeft(2, '0');
    final hh = d.hour.toString().padLeft(2, '0');
    final min = d.minute.toString().padLeft(2, '0');
    return '$dd.$mm $hh:$min';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final async = ref.watch(dashboardSummaryProvider);
    final activityAsync = ref.watch(dashboardActivityProvider);

    return async.when(
      loading: () => const DashboardLoadingSkeleton(),
      error: (e, _) => Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: AsyncErrorCard(
            error: e,
            title: 'Не удалось загрузить дашборд',
            onRetry: () => ref.invalidate(dashboardSummaryProvider),
          ),
        ),
      ),
      data: (summary) => RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(dashboardSummaryProvider);
          ref.invalidate(dashboardActivityProvider);
          await Future.wait([
            ref.read(dashboardSummaryProvider.future),
            ref.read(dashboardActivityProvider.future),
          ]);
        },
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            Text('Дашборд', style: theme.textTheme.headlineMedium),
            const SizedBox(height: 4),
            Text(
              'Ключевые показатели и активность',
              style: theme.textTheme.bodyLarge?.copyWith(color: colors.onSurfaceVariant),
            ),
            if (summary.partialErrors.isNotEmpty) ...[
              const SizedBox(height: 16),
              Card(
                color: colors.errorContainer,
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Часть данных не загрузилась', style: theme.textTheme.titleSmall?.copyWith(color: colors.onErrorContainer)),
                      const SizedBox(height: 8),
                      for (final line in summary.partialErrors)
                        Text('• $line', style: theme.textTheme.bodySmall?.copyWith(color: colors.onErrorContainer)),
                    ],
                  ),
                ),
              ),
            ],
            const SizedBox(height: 28),
            Text('Ключевые показатели', style: theme.textTheme.titleMedium),
            const SizedBox(height: 16),
            Wrap(
              spacing: 16,
              runSpacing: 16,
              children: [
                _KpiCard(
                  icon: Icons.receipt_long,
                  label: 'Заказы сегодня',
                  subtitle: 'Созданные за сегодняшний день',
                  value: _fmtInt(summary.ordersToday),
                  trend: '',
                  trendUp: true,
                  color: colors.primary,
                ),
                _KpiCard(
                  icon: Icons.inventory_2,
                  label: 'Позиций в каталоге',
                  subtitle: 'всего в номенклатуре',
                  value: _fmtInt(summary.catalogTotal),
                  trend: '',
                  trendUp: true,
                  color: colors.tertiary,
                ),
                _KpiCard(
                  icon: Icons.account_balance,
                  label: 'Выручка за день',
                  subtitle: 'Завершённые оплаты за сегодня (сумма на сервере)',
                  value: _fmtMoney(summary.revenueTodayRub),
                  trend: '',
                  trendUp: true,
                  color: colors.primary,
                ),
                _KpiCard(
                  icon: Icons.local_shipping,
                  label: 'Рейсов в пути',
                  subtitle: 'Маршруты в работе',
                  value: _fmtInt(summary.routesInProgress),
                  trend: '',
                  trendUp: true,
                  color: colors.secondary,
                ),
              ],
            ),
            const SizedBox(height: 32),
            Text('Последняя активность', style: theme.textTheme.titleMedium),
            const SizedBox(height: 8),
            Text(
              'Недавние заказы и операции (данные с API заказов и финансов)',
              style: theme.textTheme.bodySmall?.copyWith(color: colors.onSurfaceVariant),
            ),
            const SizedBox(height: 12),
            activityAsync.when(
              loading: () => const Card(
                child: Padding(
                  padding: EdgeInsets.all(24),
                  child: Center(child: CircularProgressIndicator()),
                ),
              ),
              error: (e, _) => Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    'Не удалось загрузить ленту',
                    style: theme.textTheme.bodyMedium?.copyWith(color: colors.error),
                  ),
                ),
              ),
              data: (items) {
                if (items.isEmpty) {
                  return Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Text(
                        'Пока нет событий. Всего заказов в системе: ${_fmtInt(summary.ordersTotal)}',
                        style: theme.textTheme.bodyMedium?.copyWith(color: colors.onSurfaceVariant),
                      ),
                    ),
                  );
                }
                return Card(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      for (final item in items)
                        ListTile(
                          leading: Icon(
                            item.kind == ActivityFeedKind.order
                                ? Icons.receipt_long
                                : Icons.payments_outlined,
                            color: colors.primary,
                          ),
                          title: Text(item.title),
                          subtitle: Text(item.subtitle),
                          trailing: Text(
                            _fmtActivityTime(item.at),
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: colors.onSurfaceVariant,
                            ),
                          ),
                        ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _KpiCard extends StatelessWidget {
  const _KpiCard({
    required this.icon,
    required this.label,
    this.subtitle,
    required this.value,
    required this.trend,
    required this.trendUp,
    required this.color,
  });

  final IconData icon;
  final String label;
  final String? subtitle;
  final String value;
  final String trend;
  final bool trendUp;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return SizedBox(
      width: 240,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: color.withAlpha(25),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(icon, color: color, size: 22),
                  ),
                  const Spacer(),
                  if (trend.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: (trendUp ? colors.primary : colors.error).withAlpha(20),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        trend,
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: trendUp ? colors.primary : colors.error,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                value,
                style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: theme.textTheme.bodySmall?.copyWith(color: colors.onSurfaceVariant),
              ),
              if (subtitle != null && subtitle!.isNotEmpty) ...[
                const SizedBox(height: 6),
                Text(
                  subtitle!,
                  style: theme.textTheme.labelSmall?.copyWith(color: colors.onSurfaceVariant.withAlpha(180)),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
