import 'package:flutter/material.dart';

class AdminPage extends StatelessWidget {
  const AdminPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        Text('Администрирование', style: theme.textTheme.headlineMedium),
        const SizedBox(height: 4),
        Text(
          'Пользователи, роли и доступ',
          style: theme.textTheme.bodyLarge?.copyWith(color: colors.onSurfaceVariant),
        ),
        const SizedBox(height: 24),
        Row(
          children: [
            Expanded(child: Text('Сотрудники', style: theme.textTheme.titleMedium)),
            FilledButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.person_add),
              label: const Text('Добавить'),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Card(
          child: DataTable(
            columns: const [
              DataColumn(label: Text('Сотрудник')),
              DataColumn(label: Text('Email')),
              DataColumn(label: Text('Роль')),
              DataColumn(label: Text('Статус')),
            ],
            rows: [
              _userRow('Смирнов А.В.', 'smirnov@gastro.ru', 'Администратор', true, colors),
              _userRow('Козлова И.М.', 'kozlova@gastro.ru', 'Менеджер продаж', true, colors),
              _userRow('Иванов С.П.', 'ivanov@gastro.ru', 'Водитель', true, colors),
              _userRow('Петров А.И.', 'petrov@gastro.ru', 'Кладовщик', true, colors),
              _userRow('Сидоров К.В.', 'sidorov@gastro.ru', 'Водитель', false, colors),
              _userRow('Белова М.Н.', 'belova@gastro.ru', 'Бухгалтер', true, colors),
            ],
          ),
        ),
        const SizedBox(height: 24),
        Text('Роли и права', style: theme.textTheme.titleMedium),
        const SizedBox(height: 12),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            _RoleCard(role: 'Администратор', perms: 'Полный доступ', count: 1, colors: colors),
            _RoleCard(role: 'Менеджер продаж', perms: 'Заказы, каталог, финансы', count: 3, colors: colors),
            _RoleCard(role: 'Кладовщик', perms: 'Склад, каталог', count: 2, colors: colors),
            _RoleCard(role: 'Водитель', perms: 'Логистика (свои рейсы)', count: 8, colors: colors),
            _RoleCard(role: 'Бухгалтер', perms: 'Финансы, отчёты', count: 1, colors: colors),
          ],
        ),
      ],
    );
  }

  DataRow _userRow(String name, String email, String role, bool active, ColorScheme colors) {
    return DataRow(cells: [
      DataCell(Text(name)),
      DataCell(Text(email)),
      DataCell(Text(role)),
      DataCell(
        Chip(
          label: Text(
            active ? 'Активен' : 'Заблокирован',
            style: TextStyle(
              fontSize: 12,
              color: active ? colors.primary : colors.error,
            ),
          ),
          backgroundColor:
              (active ? colors.primary : colors.error).withAlpha(20),
          side: BorderSide.none,
          visualDensity: VisualDensity.compact,
          padding: EdgeInsets.zero,
        ),
      ),
    ]);
  }
}

class _RoleCard extends StatelessWidget {
  const _RoleCard({
    required this.role,
    required this.perms,
    required this.count,
    required this.colors,
  });

  final String role;
  final String perms;
  final int count;
  final ColorScheme colors;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SizedBox(
      width: 240,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.shield_outlined, color: colors.primary, size: 20),
                  const SizedBox(width: 8),
                  Text(role, style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600)),
                ],
              ),
              const SizedBox(height: 8),
              Text(perms, style: theme.textTheme.bodySmall?.copyWith(color: colors.onSurfaceVariant)),
              const SizedBox(height: 8),
              Text('$count чел.', style: theme.textTheme.labelSmall?.copyWith(color: colors.outline)),
            ],
          ),
        ),
      ),
    );
  }
}
