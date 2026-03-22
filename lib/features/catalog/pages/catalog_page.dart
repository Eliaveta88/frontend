import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/network/dio_error_mapper.dart';
import '../../../core/routing/route_names.dart';
import '../providers/catalog_providers.dart';

class CatalogPage extends ConsumerWidget {
  const CatalogPage({super.key});

  String _formatPrice(double p) {
    return '₽ ${p.toStringAsFixed(0)}';
  }

  String _stockLabel(bool inStock) {
    return inStock ? 'В наличии' : 'Нет';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final async = ref.watch(catalogProductsProvider);

    return async.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.cloud_off, size: 48, color: colors.error),
              const SizedBox(height: 12),
              Text(
                'Не удалось загрузить каталог',
                style: theme.textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              Text(
                dioErrorMessage(e),
                textAlign: TextAlign.center,
                style: theme.textTheme.bodySmall?.copyWith(color: colors.onSurfaceVariant),
              ),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: () => ref.invalidate(catalogProductsProvider),
                child: const Text('Повторить'),
              ),
            ],
          ),
        ),
      ),
      data: (page) => RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(catalogProductsProvider);
          await ref.read(catalogProductsProvider.future);
        },
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Каталог', style: theme.textTheme.headlineMedium),
                      const SizedBox(height: 4),
                      Text(
                        'Номенклатура (${page.total} поз.)',
                        style: theme.textTheme.bodyLarge?.copyWith(color: colors.onSurfaceVariant),
                      ),
                    ],
                  ),
                ),
                FilledButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.add),
                  label: const Text('Добавить товар'),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                SizedBox(
                  width: 300,
                  child: SearchBar(
                    hintText: 'Поиск в шапке приложения',
                    leading: Icon(Icons.search, color: colors.onSurfaceVariant),
                    padding: const WidgetStatePropertyAll(
                      EdgeInsets.symmetric(horizontal: 12),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                FilterChip(
                  label: const Text('Все категории'),
                  onSelected: (_) {},
                  selected: true,
                  selectedColor: colors.primaryContainer,
                ),
              ],
            ),
            const SizedBox(height: 20),
            Card(
              child: DataTable(
                showCheckboxColumn: false,
                columns: const [
                  DataColumn(label: Text('Название')),
                  DataColumn(label: Text('Категория')),
                  DataColumn(label: Text('Цена')),
                  DataColumn(label: Text('Наличие')),
                ],
                rows: page.items.map((p) {
                  final stockColor = p.inStock ? colors.primary : colors.error;
                  return DataRow(
                    onSelectChanged: (_) => context.go('${Routes.catalog}/${p.id}'),
                    cells: [
                      DataCell(Text(p.name)),
                      DataCell(Text(p.category)),
                      DataCell(Text(_formatPrice(p.price))),
                      DataCell(
                        Text(
                          _stockLabel(p.inStock),
                          style: TextStyle(color: stockColor, fontWeight: FontWeight.w500),
                        ),
                      ),
                    ],
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
