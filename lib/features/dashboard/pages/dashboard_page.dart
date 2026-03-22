import 'package:flutter/material.dart';

/// Дашборд: только бизнес-обзор (KPI, активность). Состояние инфраструктуры — в Traefik.
class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        Text('Дашборд', style: theme.textTheme.headlineMedium),
        const SizedBox(height: 4),
        Text(
          'Ключевые показатели и активность',
          style: theme.textTheme.bodyLarge?.copyWith(color: colors.onSurfaceVariant),
        ),
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
              value: '—',
              trend: '',
              trendUp: true,
              color: colors.primary,
            ),
            _KpiCard(
              icon: Icons.inventory_2,
              label: 'Позиций в каталоге',
              value: '—',
              trend: '',
              trendUp: true,
              color: colors.tertiary,
            ),
            _KpiCard(
              icon: Icons.account_balance,
              label: 'Выручка за день',
              value: '—',
              trend: '',
              trendUp: true,
              color: colors.primary,
            ),
            _KpiCard(
              icon: Icons.local_shipping,
              label: 'Рейсов в пути',
              value: '—',
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
            child: Text(
              'Лента событий будет подключена к заказам и складу.',
              style: theme.textTheme.bodyMedium?.copyWith(color: colors.onSurfaceVariant),
            ),
          ),
        ),
      ],
    );
  }
}

class _KpiCard extends StatelessWidget {
  const _KpiCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.trend,
    required this.trendUp,
    required this.color,
  });

  final IconData icon;
  final String label;
  final String value;
  final String trend;
  final bool trendUp;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return SizedBox(
      width: 220,
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
            ],
          ),
        ),
      ),
    );
  }
}
