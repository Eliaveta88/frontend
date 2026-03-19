import 'package:flutter/material.dart';

class OrderDetailPage extends StatelessWidget {
  const OrderDetailPage({super.key, required this.id});

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
            Text('Заказ #$id', style: theme.textTheme.headlineMedium),
            const SizedBox(width: 12),
            Chip(
              label: Text('Подтверждён', style: TextStyle(color: colors.primary, fontSize: 12)),
              backgroundColor: colors.primaryContainer,
              side: BorderSide.none,
              visualDensity: VisualDensity.compact,
            ),
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
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Состав заказа', style: theme.textTheme.titleMedium),
                      const SizedBox(height: 16),
                      DataTable(
                        columns: const [
                          DataColumn(label: Text('Товар')),
                          DataColumn(label: Text('Кол-во'), numeric: true),
                          DataColumn(label: Text('Цена'), numeric: true),
                          DataColumn(label: Text('Сумма'), numeric: true),
                        ],
                        rows: const [
                          DataRow(cells: [
                            DataCell(Text('Сыр Российский 50%')),
                            DataCell(Text('120 кг')),
                            DataCell(Text('₽ 680')),
                            DataCell(Text('₽ 81 600')),
                          ]),
                          DataRow(cells: [
                            DataCell(Text('Масло сливочное 82.5%')),
                            DataCell(Text('80 кг')),
                            DataCell(Text('₽ 920')),
                            DataCell(Text('₽ 73 600')),
                          ]),
                          DataRow(cells: [
                            DataCell(Text('Молоко 3.2% (пак.)')),
                            DataCell(Text('200 шт')),
                            DataCell(Text('₽ 85')),
                            DataCell(Text('₽ 17 000')),
                          ]),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Align(
                        alignment: Alignment.centerRight,
                        child: Text(
                          'Итого: ₽ 172 200',
                          style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                children: [
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Клиент', style: theme.textTheme.titleMedium),
                          const SizedBox(height: 12),
                          _InfoRow(label: 'Название', value: 'ООО «Ресторатор»'),
                          _InfoRow(label: 'ИНН', value: '7712345678'),
                          _InfoRow(label: 'Контакт', value: '+7 (495) 123-45-67'),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Доставка', style: theme.textTheme.titleMedium),
                          const SizedBox(height: 12),
                          _InfoRow(label: 'Адрес', value: 'ул. Ленина, д. 42'),
                          _InfoRow(label: 'Дата', value: '20.03.2026'),
                          _InfoRow(label: 'Рейс', value: 'МСК-012'),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});

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
            width: 80,
            child: Text(
              label,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          Expanded(child: Text(value, style: theme.textTheme.bodyMedium)),
        ],
      ),
    );
  }
}
