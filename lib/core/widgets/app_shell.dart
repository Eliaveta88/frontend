import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../auth/auth_provider.dart';
import '../routing/route_names.dart';
import '../theme/theme_provider.dart';
import 'animated_emoji_background.dart';

class AppShell extends ConsumerWidget {
  const AppShell({super.key, required this.child});

  final Widget child;

  static const _destinations = [
    _Dest(icon: Icons.dashboard_outlined, selectedIcon: Icons.dashboard, label: 'Дашборд', route: Routes.dashboard),
    _Dest(icon: Icons.receipt_long_outlined, selectedIcon: Icons.receipt_long, label: 'Заказы', route: Routes.orders),
    _Dest(icon: Icons.inventory_2_outlined, selectedIcon: Icons.inventory_2, label: 'Каталог', route: Routes.catalog),
    _Dest(icon: Icons.warehouse_outlined, selectedIcon: Icons.warehouse, label: 'Склад', route: Routes.warehouse),
    _Dest(icon: Icons.account_balance_outlined, selectedIcon: Icons.account_balance, label: 'Финансы', route: Routes.finance),
    _Dest(icon: Icons.local_shipping_outlined, selectedIcon: Icons.local_shipping, label: 'Логистика', route: Routes.logistics),
    _Dest(icon: Icons.admin_panel_settings_outlined, selectedIcon: Icons.admin_panel_settings, label: 'Админ', route: Routes.admin),
  ];

  int _selectedIndex(String location) {
    for (var i = _destinations.length - 1; i >= 0; i--) {
      if (location.startsWith(_destinations[i].route)) return i;
    }
    return 0;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final location = GoRouterState.of(context).matchedLocation;
    final selected = _selectedIndex(location);
    final width = MediaQuery.sizeOf(context).width;
    final isCompact = width < 900;

    return AnimatedEmojiBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: colors.surface.withAlpha(230),
          title: Row(
            children: [
              Icon(Icons.local_shipping_rounded, color: colors.primary, size: 28),
              const SizedBox(width: 10),
              Text(
                'GastroRoute',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: colors.primary,
                ),
              ),
            ],
          ),
          actions: [
            SizedBox(
              width: isCompact ? 200 : 320,
              child: SearchBar(
                hintText: 'Поиск...',
                leading: Icon(Icons.search, color: colors.onSurfaceVariant),
                padding: const WidgetStatePropertyAll(
                  EdgeInsets.symmetric(horizontal: 12),
                ),
              ),
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
              itemBuilder: (_) => [
                const PopupMenuItem(value: 'profile', child: Text('Профиль')),
                const PopupMenuItem(value: 'logout', child: Text('Выход')),
              ],
              onSelected: (value) {
                if (value == 'logout') {
                  ref.read(authProvider.notifier).logout();
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
              minExtendedWidth: 200,
              backgroundColor: Colors.transparent,
              selectedIndex: selected,
              onDestinationSelected: (i) {
                context.go(_destinations[i].route);
              },
              destinations: _destinations
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
              child: Container(
                color: colors.surface.withAlpha(240),
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
