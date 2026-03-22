import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/network/api_services/identity_api_service.dart';
import '../../../core/network/dio_error_mapper.dart';
import '../../../core/widgets/async_error_card.dart';
import '../../../core/widgets/bokeh_modal.dart';
import '../../../core/widgets/empty_list_state.dart';
import '../../../core/widgets/loading_skeletons.dart';
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
        padding: AppTheme.pagePadding,
        children: [
          Text(
            'Администрирование',
            style: theme.textTheme.headlineMedium?.copyWith(letterSpacing: -0.3),
          ),
          const SizedBox(height: 8),
          Text(
            'Пользователи, роли и доступ',
            style: theme.textTheme.bodyLarge?.copyWith(
              color: colors.onSurfaceVariant,
              height: 1.45,
            ),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(child: Text('Сотрудники', style: theme.textTheme.titleMedium)),
              FilledButton.icon(
                onPressed: () => _showAddUserDialog(context, ref),
                icon: const Icon(Icons.person_add),
                label: const Text('Добавить'),
              ),
            ],
          ),
          const SizedBox(height: 12),
          usersAsync.when(
            loading: () => const TableLoadingSkeleton(columnCount: 5, rowCount: 5),
            error: (e, _) => AsyncErrorCard(
              error: e,
              title: 'Не удалось загрузить пользователей',
              onRetry: () => ref.invalidate(adminUsersProvider),
            ),
            data: (page) => page.items.isEmpty
                ? EmptyListState(
                    icon: Icons.people_outline,
                    title: 'Пользователей нет',
                    message: 'Пока нет пользователей в списке.',
                    actionLabel: 'Обновить',
                    onAction: () => ref.invalidate(adminUsersProvider),
                  )
                : Card(
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

Future<void> _showAddUserDialog(BuildContext context, WidgetRef ref) async {
  final loginCtrl = TextEditingController();
  final emailCtrl = TextEditingController();
  final passCtrl = TextEditingController();
  var busy = false;

  await showBokehModal<void>(
    context: context,
    maxWidth: 420,
    child: StatefulBuilder(
      builder: (context, setDialogState) {
        return BokehModalCard(
          title: 'Новый пользователь',
          subtitle: 'Логин, email и пароль',
          body: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextField(
                controller: loginCtrl,
                decoration: const InputDecoration(labelText: 'Логин', border: OutlineInputBorder()),
                textCapitalization: TextCapitalization.none,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: emailCtrl,
                decoration: const InputDecoration(labelText: 'Email', border: OutlineInputBorder()),
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: passCtrl,
                decoration: const InputDecoration(labelText: 'Пароль', border: OutlineInputBorder()),
                obscureText: true,
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
                      final u = loginCtrl.text.trim();
                      final em = emailCtrl.text.trim();
                      final p = passCtrl.text;
                      if (u.isEmpty || em.isEmpty || p.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Заполните все поля')),
                        );
                        return;
                      }
                      setDialogState(() => busy = true);
                      try {
                        await ref.read(identityApiServiceProvider).register(
                              username: u,
                              email: em,
                              password: p,
                            );
                        if (context.mounted) {
                          Navigator.of(context).pop();
                          ref.invalidate(adminUsersProvider);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Пользователь создан')),
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

  loginCtrl.dispose();
  emailCtrl.dispose();
  passCtrl.dispose();
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
