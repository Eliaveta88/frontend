import 'package:flutter/material.dart';

class ProductDetailPage extends StatelessWidget {
  const ProductDetailPage({super.key, required this.id});

  final String id;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        Row(
          children: [
            IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => Navigator.of(context).maybePop(),
            ),
            const SizedBox(width: 8),
            Text('Карточка товара #$id', style: theme.textTheme.headlineMedium),
          ],
        ),
        const SizedBox(height: 24),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 2,
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Сыр Российский 50%', style: theme.textTheme.headlineSmall),
                      const SizedBox(height: 8),
                      Chip(
                        label: const Text('Молочные'),
                        backgroundColor: colors.primaryContainer,
                        side: BorderSide.none,
                      ),
                      const SizedBox(height: 20),
                      _DetailRow(label: 'Артикул', value: 'МЛК-00$id'),
                      _DetailRow(label: 'Штрихкод', value: '460700${id}00142'),
                      _DetailRow(label: 'Базовая ед.', value: 'кг'),
                      _DetailRow(label: 'Срок годности', value: '120 суток'),
                      _DetailRow(label: 'Условия хранения', value: '+2...+6 °C'),
                      const Divider(height: 32),
                      Text('Атрибуты (JSONB)', style: theme.textTheme.titleSmall),
                      const SizedBox(height: 8),
                      _DetailRow(label: 'Жирность', value: '50%'),
                      _DetailRow(label: 'Белок', value: '23 г / 100 г'),
                      _DetailRow(label: 'ГОСТ', value: '32260-2013'),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Единицы измерения', style: theme.textTheme.titleMedium),
                      const SizedBox(height: 16),
                      _UnitRow(unit: '1 кг', base: 'базовая'),
                      _UnitRow(unit: '1 головка', base: '= 4.5 кг'),
                      _UnitRow(unit: '1 коробка', base: '= 4 головки (18 кг)'),
                      _UnitRow(unit: '1 паллета', base: '= 60 коробок (1080 кг)'),
                      const SizedBox(height: 16),
                      OutlinedButton.icon(
                        onPressed: () {},
                        icon: const Icon(Icons.add, size: 18),
                        label: const Text('Добавить единицу'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          SizedBox(
            width: 160,
            child: Text(label, style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
          ),
          Expanded(child: Text(value, style: theme.textTheme.bodyMedium)),
        ],
      ),
    );
  }
}

class _UnitRow extends StatelessWidget {
  const _UnitRow({required this.unit, required this.base});
  final String unit;
  final String base;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Text(unit, style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600)),
          const SizedBox(width: 12),
          Text(base, style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
        ],
      ),
    );
  }
}
