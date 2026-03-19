import 'package:flutter/material.dart';

class LogisticsPage extends StatelessWidget {
  const LogisticsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return ListView(
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
                    'Маршруты, транспорт и точки доставки',
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
        const SizedBox(height: 20),
        Wrap(
          spacing: 16,
          runSpacing: 16,
          children: [
            _LogiCard(icon: Icons.local_shipping, label: 'Всего машин', value: '18', colors: colors),
            _LogiCard(icon: Icons.route, label: 'Рейсов сегодня', value: '12', colors: colors),
            _LogiCard(icon: Icons.check_circle_outline, label: 'Доставлено', value: '7 / 12', colors: colors),
          ],
        ),
        const SizedBox(height: 24),
        Text('Активные рейсы', style: theme.textTheme.titleMedium),
        const SizedBox(height: 12),
        Card(
          child: DataTable(
            columns: const [
              DataColumn(label: Text('Рейс')),
              DataColumn(label: Text('Машина')),
              DataColumn(label: Text('Водитель')),
              DataColumn(label: Text('Точек')),
              DataColumn(label: Text('Загрузка')),
              DataColumn(label: Text('Статус')),
            ],
            rows: [
              _routeRow('МСК-012', 'Газель Next (А 123 ВС)', 'Иванов С.П.', '6', '87%', 'В пути', colors),
              _routeRow('МСК-013', 'MAN TGL (В 456 НК)', 'Петров А.И.', '4', '72%', 'В пути', colors),
              _routeRow('МСК-014', 'Газель Next (С 789 ОР)', 'Сидоров К.В.', '8', '95%', 'Загрузка', colors),
              _routeRow('МСК-015', 'ISUZU ELF (Д 012 МА)', 'Козлов Р.Д.', '5', '60%', 'Планирование', colors),
            ],
          ),
        ),
        const SizedBox(height: 24),
        Text('Точки доставки — рейс МСК-012', style: theme.textTheme.titleMedium),
        const SizedBox(height: 12),
        Card(
          child: Column(
            children: [
              _pointTile('ООО «Ресторатор»', 'ул. Ленина, 42', 'Доставлено', true, colors),
              _pointTile('ИП Козлов А.В.', 'пр. Мира, 15', 'Доставлено', true, colors),
              _pointTile('АО «ФудСервис»', 'ул. Тверская, 8', 'В пути', false, colors),
              _pointTile('ООО «Шеф-Повар»', 'ул. Гагарина, 3', 'Ожидание', false, colors),
              _pointTile('ИП Белова М.Н.', 'пер. Южный, 11', 'Ожидание', false, colors),
              _pointTile('ООО «ГастроПлюс»', 'ул. Кирова, 29', 'Ожидание', false, colors),
            ],
          ),
        ),
      ],
    );
  }

  DataRow _routeRow(
    String route,
    String vehicle,
    String driver,
    String points,
    String load,
    String status,
    ColorScheme colors,
  ) {
    final statusColor = status == 'В пути'
        ? colors.primary
        : status == 'Загрузка'
            ? colors.tertiary
            : colors.outline;
    return DataRow(cells: [
      DataCell(Text(route, style: const TextStyle(fontWeight: FontWeight.w600))),
      DataCell(Text(vehicle)),
      DataCell(Text(driver)),
      DataCell(Text(points)),
      DataCell(Text(load)),
      DataCell(
        Chip(
          label: Text(status, style: TextStyle(fontSize: 12, color: statusColor)),
          backgroundColor: statusColor.withAlpha(20),
          side: BorderSide.none,
          visualDensity: VisualDensity.compact,
          padding: EdgeInsets.zero,
        ),
      ),
    ]);
  }

  Widget _pointTile(String client, String address, String status, bool done, ColorScheme colors) {
    return ListTile(
      leading: Icon(
        done ? Icons.check_circle : Icons.radio_button_unchecked,
        color: done ? const Color(0xFF43A047) : colors.outline,
      ),
      title: Text(client),
      subtitle: Text(address),
      trailing: Text(
        status,
        style: TextStyle(
          color: done
              ? const Color(0xFF43A047)
              : status == 'В пути'
                  ? colors.primary
                  : colors.onSurfaceVariant,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}

class _LogiCard extends StatelessWidget {
  const _LogiCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.colors,
  });

  final IconData icon;
  final String label;
  final String value;
  final ColorScheme colors;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SizedBox(
      width: 200,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: colors.primary.withAlpha(25),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: colors.primary, size: 22),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(value, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
                  Text(label, style: theme.textTheme.labelSmall?.copyWith(color: colors.onSurfaceVariant)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
