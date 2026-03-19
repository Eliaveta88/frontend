import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class CatalogPage extends StatelessWidget {
  const CatalogPage({super.key});

  static const _mockProducts = [
    _Product('Сыр Российский 50%', 'Молочные', '₽ 680/кг', 'В наличии'),
    _Product('Масло сливочное 82.5%', 'Молочные', '₽ 920/кг', 'В наличии'),
    _Product('Молоко 3.2% (пак.)', 'Молочные', '₽ 85/шт', 'В наличии'),
    _Product('Филе куриное охл.', 'Мясо', '₽ 340/кг', 'Мало'),
    _Product('Говядина 1 кат. б/к', 'Мясо', '₽ 780/кг', 'В наличии'),
    _Product('Лосось с/м филе', 'Рыба', '₽ 1 450/кг', 'Под заказ'),
    _Product('Мука пш. в/с 50кг', 'Бакалея', '₽ 2 100/мш', 'В наличии'),
    _Product('Сахар-песок 50кг', 'Бакалея', '₽ 3 200/мш', 'В наличии'),
    _Product('Масло подсолн. раф. 5л', 'Бакалея', '₽ 520/бут', 'Мало'),
    _Product('Томаты свежие', 'Овощи', '₽ 260/кг', 'В наличии'),
  ];

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
                  Text('Каталог', style: theme.textTheme.headlineMedium),
                  const SizedBox(height: 4),
                  Text(
                    'Номенклатура продуктов питания',
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
                hintText: 'Поиск товара...',
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
            rows: _mockProducts.asMap().entries.map((e) {
              final i = e.key;
              final p = e.value;
              final stockColor = p.stock == 'В наличии'
                  ? colors.primary
                  : p.stock == 'Мало'
                      ? colors.error
                      : colors.outline;
              return DataRow(
                onSelectChanged: (_) => context.go('/catalog/${i + 1}'),
                cells: [
                  DataCell(Text(p.name)),
                  DataCell(Text(p.category)),
                  DataCell(Text(p.price)),
                  DataCell(
                    Text(p.stock, style: TextStyle(color: stockColor, fontWeight: FontWeight.w500)),
                  ),
                ],
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}

class _Product {
  const _Product(this.name, this.category, this.price, this.stock);
  final String name;
  final String category;
  final String price;
  final String stock;
}
