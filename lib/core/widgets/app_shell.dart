import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../auth/auth_flags.dart';
import '../auth/auth_provider.dart';
import '../routing/route_names.dart';
import '../theme/theme_provider.dart';
import 'animated_emoji_background.dart';
import 'catalog_global_search_bar.dart';

class AppShell extends ConsumerWidget {
  const AppShell({super.key, required this.child});

  final Widget child;

  static const _baseDestinations = [
    _Dest(icon: Icons.dashboard_outlined, selectedIcon: Icons.dashboard, label: 'Дашборд', route: Routes.dashboard),
    _Dest(icon: Icons.receipt_long_outlined, selectedIcon: Icons.receipt_long, label: 'Заказы', route: Routes.orders),
    _Dest(icon: Icons.inventory_2_outlined, selectedIcon: Icons.inventory_2, label: 'Каталог', route: Routes.catalog),
    _Dest(icon: Icons.warehouse_outlined, selectedIcon: Icons.warehouse, label: 'Склад', route: Routes.warehouse),
    _Dest(icon: Icons.account_balance_outlined, selectedIcon: Icons.account_balance, label: 'Финансы', route: Routes.finance),
    _Dest(icon: Icons.local_shipping_outlined, selectedIcon: Icons.local_shipping, label: 'Логистика', route: Routes.logistics),
  ];

  static const _adminDestination = _Dest(
    icon: Icons.admin_panel_settings_outlined,
    selectedIcon: Icons.admin_panel_settings,
    label: 'Админ',
    route: Routes.admin,
  );

  List<_Dest> _destinationsFor(List<String> roles, bool authGate) {
    final showAdmin = !authGate || roles.any((r) => r.toLowerCase() == 'admin');
    return [
      ..._baseDestinations,
      if (showAdmin) _adminDestination,
    ];
  }

  int _selectedIndex(List<_Dest> destinations, String location) {
    for (var i = destinations.length - 1; i >= 0; i--) {
      final route = destinations[i].route;
      if (route == Routes.dashboard) {
        if (location == Routes.dashboard) return i;
        continue;
      }
      if (location == route || location.startsWith('$route/')) return i;
    }
    return 0;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final location = GoRouterState.of(context).matchedLocation;
    final roles = ref.watch(authProvider).profile?.roles ?? const <String>[];
    final authGate = ref.watch(authEnabledProvider);
    final destinations = _destinationsFor(roles, authGate);
    final selected = _selectedIndex(destinations, location);
    final width = MediaQuery.sizeOf(context).width;
    final isCompact = width < 900;

    return AnimatedEmojiBackground(
      child: Scaffold(
        backgroundColor: colors.surface,
        appBar: AppBar(
          backgroundColor: colors.surface,
          surfaceTintColor: Colors.transparent,
          title: Row(
            children: [
              Icon(Icons.local_shipping_rounded, color: colors.primary, size: 26),
              const SizedBox(width: 12),
              Text(
                'GastroRoute',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.2,
                  color: colors.primary,
                ),
              ),
            ],
          ),
          actions: [
            CatalogGlobalSearchBar(
              width: isCompact ? 200 : 320,
            ),
            const SizedBox(width: 8),
            IconButton(
              icon: Icon(
                theme.brightness == Brightness.dark
                    ? Icons.light_mode_outlined
                    : Icons.dark_mode_outlined,
              ),
              tooltip: 'Сменить тему',
              onPressed: () => ref.read(themeModeProvider.notifier).toggle(),
            ),
            const SizedBox(width: 4),
            PopupMenuButton(
              icon: CircleAvatar(
                radius: 16,
                backgroundColor: colors.primaryContainer,
                child: Icon(Icons.person, size: 18, color: colors.onPrimaryContainer),
              ),
              itemBuilder: (_) {
                final name = ref.watch(authProvider).profile?.username;
                return [
                  PopupMenuItem(
                    enabled: false,
                    child: Text(
                      name != null ? 'Вошли как $name' : 'Гость',
                      style: theme.textTheme.bodySmall?.copyWith(color: colors.onSurfaceVariant),
                    ),
                  ),
                  const PopupMenuItem(value: 'profile', child: Text('Профиль')),
                  const PopupMenuItem(value: 'logout', child: Text('Выход')),
                ];
              },
              onSelected: (value) {
                if (value == 'logout') {
                  ref.read(authProvider.notifier).logout();
                } else if (value == 'profile') {
                  _showProfileDialog(context, ref);
                }
              },
            ),
            const SizedBox(width: 12),
          ],
        ),
        body: Row(
          children: [
            NavigationRail(
              extended: !isCompact,
              minExtendedWidth: 220,
              backgroundColor: colors.surfaceContainerLow,
              selectedIndex: selected,
              onDestinationSelected: (i) {
                context.go(destinations[i].route);
              },
              destinations: destinations
                  .map(
                    (d) => NavigationRailDestination(
                      icon: Icon(d.icon),
                      selectedIcon: Icon(d.selectedIcon),
                      label: Text(d.label),
                    ),
                  )
                  .toList(),
            ),
            VerticalDivider(
              width: 1,
              thickness: 1,
              color: colors.outlineVariant.withAlpha(60),
            ),
            Expanded(
              child: ColoredBox(
                color: colors.surface,
                child: child,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Dest {
  const _Dest({
    required this.icon,
    required this.selectedIcon,
    required this.label,
    required this.route,
  });

  final IconData icon;
  final IconData selectedIcon;
  final String label;
  final String route;
}

void _showProfileDialog(BuildContext context, WidgetRef ref) {
  final profile = ref.read(authProvider).profile;
  final theme = Theme.of(context);

  if (profile == null) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Профиль недоступен — войдите в систему'),
      ),
    );
    return;
  }

  showDialog<void>(
    context: context,
    builder: (dialogContext) {
      return AlertDialog(
        title: const Text('Профиль'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _ProfileRow(label: 'ID', value: '${profile.id}'),
            _ProfileRow(label: 'Пользователь', value: profile.username),
            _ProfileRow(label: 'Email', value: profile.email),
            _ProfileRow(
              label: 'Роли',
              value: profile.roles.isEmpty ? '—' : profile.roles.join(', '),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Закрыть'),
          ),
          FilledButton.tonalIcon(
            icon: const Icon(Icons.logout),
            label: const Text('Выйти'),
            onPressed: () {
              Navigator.of(dialogContext).pop();
              ref.read(authProvider.notifier).logout();
            },
          ),
        ],
        titleTextStyle: theme.textTheme.titleLarge,
      );
    },
  );
}

class _ProfileRow extends StatelessWidget {
  const _ProfileRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          Expanded(
            child: SelectableText(value, style: theme.textTheme.bodyMedium),
          ),
        ],
      ),
    );
  }
}
