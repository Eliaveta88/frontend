import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/dio_error_mapper.dart';
import '../providers/admin_users_provider.dart';

class AdminPage extends ConsumerWidget {
  const AdminPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final usersAsync = ref.watch(adminUsersProvider);

    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(adminUsersProvider);
        await ref.read(adminUsersProvider.future);
      },
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
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
          usersAsync.when(
            loading: () => const Padding(
              padding: EdgeInsets.symmetric(vertical: 32),
              child: Center(child: CircularProgressIndicator()),
            ),
            error: (e, _) => Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: SelectableText(
                  'Не удалось загрузить пользователей: ${dioErrorMessage(e)}',
                  style: TextStyle(color: colors.error),
                ),
              ),
            ),
            data: (page) => Card(
              child: DataTable(
                columns: const [
                  DataColumn(label: Text('ID')),
                  DataColumn(label: Text('Логин')),
                  DataColumn(label: Text('Email')),
                  DataColumn(label: Text('Роли')),
                  DataColumn(label: Text('Статус')),
                ],
                rows: [
                  for (final u in page.items)
                    DataRow(
                      cells: [
                        DataCell(Text('${u.id}')),
                        DataCell(Text(u.username)),
                        DataCell(Text(u.email)),
                        DataCell(Text(u.roles.isEmpty ? '—' : u.roles.join(', '))),
                        DataCell(
                          Chip(
                            label: const Text(
                              'Активен',
                              style: TextStyle(fontSize: 12),
                            ),
                            backgroundColor: colors.primary.withAlpha(20),
                            side: BorderSide.none,
                            visualDensity: VisualDensity.compact,
                            padding: EdgeInsets.zero,
                          ),
                        ),
                      ],
                    ),
                ],
              ),
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
      ),
    );
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
