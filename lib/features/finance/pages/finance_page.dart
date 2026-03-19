import 'package:flutter/material.dart';

import '../../../core/widgets/bokeh_modal.dart';

class FinancePage extends StatelessWidget {
  const FinancePage({super.key});

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
                  Text('Финансы', style: theme.textTheme.headlineMedium),
                  const SizedBox(height: 4),
                  Text(
                    'Взаиморасчёты, сальдо и инвойсы',
                    style: theme.textTheme.bodyLarge?.copyWith(color: colors.onSurfaceVariant),
                  ),
                ],
              ),
            ),
            OutlinedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.description_outlined),
              label: const Text('Сформировать инвойс'),
            ),
            const SizedBox(width: 8),
            FilledButton.icon(
              onPressed: () => _showPaymentDialog(context),
              icon: const Icon(Icons.payment),
              label: const Text('Провести оплату'),
            ),
          ],
        ),
        const SizedBox(height: 24),
        Text('Счета контрагентов', style: theme.textTheme.titleMedium),
        const SizedBox(height: 12),
        Card(
          child: DataTable(
            columns: const [
              DataColumn(label: Text('Контрагент')),
              DataColumn(label: Text('Сальдо'), numeric: true),
              DataColumn(label: Text('Кредитный лимит'), numeric: true),
              DataColumn(label: Text('Использовано'), numeric: true),
              DataColumn(label: Text('Статус')),
            ],
            rows: [
              _accountRow('ООО «Ресторатор»', '₽ 120 000', '₽ 500 000', '76%', false, colors),
              _accountRow('ИП Козлов А.В.', '−₽ 45 000', '₽ 200 000', '122%', true, colors),
              _accountRow('АО «ФудСервис»', '₽ 890 000', '₽ 1 000 000', '11%', false, colors),
              _accountRow('ООО «Шеф-Повар»', '₽ 0', '₽ 300 000', '100%', false, colors),
              _accountRow('ИП Белова М.Н.', '₽ 34 500', '₽ 150 000', '77%', false, colors),
              _accountRow('ООО «ГастроПлюс»', '−₽ 12 000', '₽ 400 000', '103%', true, colors),
            ],
          ),
        ),
        const SizedBox(height: 24),
        Text('Последние транзакции', style: theme.textTheme.titleMedium),
        const SizedBox(height: 12),
        Card(
          child: Column(
            children: [
              _txTile('Оплата от ООО «Ресторатор»', '+₽ 340 000', true, colors),
              _txTile('Отгрузка заказ #1241', '−₽ 172 200', false, colors),
              _txTile('Оплата от АО «ФудСервис»', '+₽ 890 000', true, colors),
              _txTile('Отгрузка заказ #1238', '−₽ 95 400', false, colors),
            ],
          ),
        ),
      ],
    );
  }

  DataRow _accountRow(
    String name,
    String balance,
    String limit,
    String used,
    bool overLimit,
    ColorScheme colors,
  ) {
    return DataRow(cells: [
      DataCell(Text(name)),
      DataCell(Text(
        balance,
        style: TextStyle(
          color: balance.startsWith('−') ? colors.error : null,
          fontWeight: FontWeight.w500,
        ),
      )),
      DataCell(Text(limit)),
      DataCell(Text(used)),
      DataCell(
        Chip(
          label: Text(
            overLimit ? 'Превышен' : 'Норма',
            style: TextStyle(
              fontSize: 12,
              color: overLimit ? colors.error : colors.primary,
            ),
          ),
          backgroundColor:
              (overLimit ? colors.error : colors.primary).withAlpha(20),
          side: BorderSide.none,
          visualDensity: VisualDensity.compact,
          padding: EdgeInsets.zero,
        ),
      ),
    ]);
  }

  Widget _txTile(String title, String amount, bool incoming, ColorScheme colors) {
    return ListTile(
      leading: Icon(
        incoming ? Icons.arrow_downward : Icons.arrow_upward,
        color: incoming ? colors.primary : colors.error,
      ),
      title: Text(title),
      trailing: Text(
        amount,
        style: TextStyle(
          fontWeight: FontWeight.w600,
          color: incoming ? colors.primary : colors.error,
        ),
      ),
    );
  }

  void _showPaymentDialog(BuildContext context) {
    showBokehModal(
      context: context,
      child: BokehModalCard(
        title: 'Провести оплату',
        subtitle: 'Регистрация входящего платежа',
        body: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(decoration: const InputDecoration(labelText: 'Контрагент')),
            const SizedBox(height: 12),
            TextFormField(decoration: const InputDecoration(labelText: 'Сумма, ₽', prefixText: '₽ ')),
            const SizedBox(height: 12),
            TextFormField(decoration: const InputDecoration(labelText: 'Номер п/п')),
          ],
        ),
        actions: [
          OutlinedButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Отмена')),
          FilledButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Провести')),
        ],
      ),
    );
  }
}
