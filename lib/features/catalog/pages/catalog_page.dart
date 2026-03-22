import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/network/dio_error_mapper.dart';
import '../../../core/routing/route_names.dart';
import '../data/catalog_models.dart';
import '../providers/catalog_providers.dart';

class CatalogPage extends ConsumerWidget {
  const CatalogPage({super.key});

  String _formatPrice(double p) {
    return '₽ ${p.toStringAsFixed(0)}';
  }

  String _stockLabel(bool inStock) {
    return inStock ? 'В наличии' : 'Нет';
  }

  List<ProductListItem> _applyFilters({
    required List<ProductListItem> items,
    required String query,
    required String? category,
  }) {
    final q = query.trim().toLowerCase();
    return items.where((p) {
      if (category != null && p.category != category) {
        return false;
      }
      if (q.isEmpty) return true;
      return p.name.toLowerCase().contains(q) || p.category.toLowerCase().contains(q);
    }).toList();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final async = ref.watch(catalogProductsProvider);
    final searchQuery = ref.watch(catalogSearchQueryProvider);
    final categoryFilter = ref.watch(catalogCategoryFilterProvider);

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
      data: (page) {
        final categories = page.items.map((p) => p.category).toSet().toList()..sort();
        final filtered = _applyFilters(
          items: page.items,
          query: searchQuery,
          category: categoryFilter,
        );

        return RefreshIndicator(
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
                          'Номенклатура (${page.total} поз., показано ${filtered.length})',
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
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: SearchBar(
                      hintText: 'Фильтр по названию или категории',
                      leading: Icon(Icons.filter_alt_outlined, color: colors.onSurfaceVariant),
                      padding: const WidgetStatePropertyAll(
                        EdgeInsets.symmetric(horizontal: 12),
                      ),
                      onChanged: (v) => ref.read(catalogSearchQueryProvider.notifier).state = v,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: FilterChip(
                        label: const Text('Все категории'),
                        selected: categoryFilter == null,
                        onSelected: (_) {
                          ref.read(catalogCategoryFilterProvider.notifier).state = null;
                        },
                        selectedColor: colors.primaryContainer,
                      ),
                    ),
                    for (final c in categories)
                      Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: FilterChip(
                          label: Text(c),
                          selected: categoryFilter == c,
                          onSelected: (_) {
                            ref.read(catalogCategoryFilterProvider.notifier).state =
                                categoryFilter == c ? null : c;
                          },
                          selectedColor: colors.primaryContainer,
                        ),
                      ),
                  ],
                ),
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
                  rows: filtered.map((p) {
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
        );
      },
    );
  }
}
