import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/widgets/async_error_card.dart';
import '../../../core/widgets/loading_skeletons.dart';
import '../providers/dashboard_providers.dart';

/// Дашборд: KPI из каталога, заказов и финансов (Traefik).
class DashboardPage extends ConsumerWidget {
  const DashboardPage({super.key});

  static String _fmtInt(int? v) => v == null ? '—' : '$v';
  static String _fmtMoney(double? v) {
    if (v == null) return '—';
    if (v == 0) return '₽ 0';
    return '₽ ${v.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]} ')}';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final async = ref.watch(dashboardSummaryProvider);

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
          await ref.read(dashboardSummaryProvider.future);
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
                  subtitle: 'по дате создания (серверный подсчёт за локальный день)',
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
                  subtitle: 'сумма completed-транзакций за сегодня (client_id из финансов)',
                  value: _fmtMoney(summary.revenueTodayRub),
                  trend: '',
                  trendUp: true,
                  color: colors.primary,
                ),
                _KpiCard(
                  icon: Icons.local_shipping,
                  label: 'Рейсов в пути',
                  subtitle: 'маршруты in_progress (первая страница списка)',
                  value: _fmtInt(summary.routesInProgress),
                  trend: '',
                  trendUp: true,
                  color: colors.secondary,
                ),
              ],
            ),
            const SizedBox(height: 32),
            Text('Последняя активность', style: theme.textTheme.titleMedium),
            const SizedBox(height: 12),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Сводка',
                      style: theme.textTheme.titleSmall,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Всего заказов в системе: ${_fmtInt(summary.ordersTotal)}',
                      style: theme.textTheme.bodyMedium?.copyWith(color: colors.onSurfaceVariant),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Лента событий (заказы/склад) — в следующих итерациях.',
                      style: theme.textTheme.bodyMedium?.copyWith(color: colors.onSurfaceVariant),
                    ),
                  ],
                ),
              ),
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
