import 'package:flutter/material.dart';

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
          'Обзор ключевых показателей',
          style: theme.textTheme.bodyLarge?.copyWith(color: colors.onSurfaceVariant),
        ),
        const SizedBox(height: 24),
        Wrap(
          spacing: 16,
          runSpacing: 16,
          children: [
            _KpiCard(
              icon: Icons.receipt_long,
              label: 'Заказы сегодня',
              value: '47',
              trend: '+12%',
              trendUp: true,
              color: colors.primary,
            ),
            _KpiCard(
              icon: Icons.inventory_2,
              label: 'Позиций на складе',
              value: '3 842',
              trend: '−2%',
              trendUp: false,
              color: colors.tertiary,
            ),
            _KpiCard(
              icon: Icons.account_balance,
              label: 'Выручка за день',
              value: '₽ 2.4M',
              trend: '+8%',
              trendUp: true,
              color: Color(0xFF43A047),
            ),
            _KpiCard(
              icon: Icons.local_shipping,
              label: 'Рейсов в пути',
              value: '12',
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
          child: Column(
            children: List.generate(
              6,
              (i) => _ActivityTile(
                icon: [
                  Icons.add_box_outlined,
                  Icons.local_shipping_outlined,
                  Icons.payment_outlined,
                  Icons.inventory_outlined,
                  Icons.receipt_long_outlined,
                  Icons.check_circle_outline,
                ][i % 6],
                title: [
                  'Новый заказ #1247 от ООО «Ресторатор»',
                  'Рейс МСК-012 отправлен',
                  'Оплата ₽340 000 от ИП Козлов',
                  'Приход партии: Сыр Российский (320 кг)',
                  'Заказ #1243 подтверждён',
                  'Доставка #1198 завершена',
                ][i % 6],
                time: '${(i * 12 + 3)} мин назад',
                isLast: i == 5,
              ),
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
                        color: (trendUp ? const Color(0xFF43A047) : colors.error).withAlpha(20),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        trend,
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: trendUp ? const Color(0xFF43A047) : colors.error,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 16),
              Text(value, style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700)),
              const SizedBox(height: 4),
              Text(label, style: theme.textTheme.bodySmall?.copyWith(color: colors.onSurfaceVariant)),
            ],
          ),
        ),
      ),
    );
  }
}

class _ActivityTile extends StatelessWidget {
  const _ActivityTile({
    required this.icon,
    required this.title,
    required this.time,
    required this.isLast,
  });

  final IconData icon;
  final String title;
  final String time;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Column(
      children: [
        ListTile(
          leading: Icon(icon, color: colors.primary),
          title: Text(title, style: theme.textTheme.bodyMedium),
          trailing: Text(
            time,
            style: theme.textTheme.labelSmall?.copyWith(color: colors.onSurfaceVariant),
          ),
        ),
        if (!isLast) Divider(height: 1, indent: 56, color: colors.outlineVariant.withAlpha(60)),
      ],
    );
  }
}
