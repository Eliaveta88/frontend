import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/dio_error_mapper.dart';
import '../../../core/widgets/bokeh_modal.dart';
import '../providers/finance_providers.dart';

class FinancePage extends ConsumerStatefulWidget {
  const FinancePage({super.key});

  @override
  ConsumerState<FinancePage> createState() => _FinancePageState();
}

class _FinancePageState extends ConsumerState<FinancePage> {
  late final TextEditingController _clientIdCtrl = TextEditingController(text: '1');

  @override
  void dispose() {
    _clientIdCtrl.dispose();
    super.dispose();
  }

  void _applyClientId() {
    final id = int.tryParse(_clientIdCtrl.text.trim());
    if (id != null && id > 0) {
      ref.read(financeClientIdProvider.notifier).state = id;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final snap = ref.watch(financeSnapshotProvider);

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
                    'Баланс и операции клиента',
                    style: theme.textTheme.bodyLarge?.copyWith(color: colors.onSurfaceVariant),
                  ),
                ],
              ),
            ),
            SizedBox(
              width: 120,
              child: TextField(
                controller: _clientIdCtrl,
                decoration: const InputDecoration(
                  labelText: 'client_id',
                  border: OutlineInputBorder(),
                  isDense: true,
                ),
                keyboardType: TextInputType.number,
                onSubmitted: (_) => _applyClientId(),
              ),
            ),
            const SizedBox(width: 8),
            FilledButton(
              onPressed: _applyClientId,
              child: const Text('Загрузить'),
            ),
            const SizedBox(width: 8),
            OutlinedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.description_outlined),
              label: const Text('Инвойс'),
            ),
            const SizedBox(width: 8),
            FilledButton.icon(
              onPressed: () => _showPaymentDialog(context),
              icon: const Icon(Icons.payment),
              label: const Text('Оплата'),
            ),
          ],
        ),
        const SizedBox(height: 24),
        snap.when(
          loading: () => const Center(child: Padding(padding: EdgeInsets.all(24), child: CircularProgressIndicator())),
          error: (e, _) => SelectableText('Ошибка: ${dioErrorMessage(e)}'),
          data: (data) => Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Счёт', style: theme.textTheme.titleMedium),
              const SizedBox(height: 12),
              if (data.balance != null)
                Card(
                  child: ListTile(
                    title: Text('client_id ${data.balance!['client_id']}'),
                    subtitle: Text(
                      'Баланс: ${data.balance!['balance']} ${data.balance!['currency'] ?? 'RUB'} · '
                      'лимит: ${data.balance!['credit_limit']}',
                    ),
                  ),
                )
              else if (data.balanceError != null)
                Card(
                  color: colors.errorContainer,
                  child: ListTile(
                    leading: Icon(Icons.info_outline, color: colors.error),
                    title: Text(data.balanceError!),
                  ),
                ),
              const SizedBox(height: 24),
              Text('Транзакции', style: theme.textTheme.titleMedium),
              const SizedBox(height: 12),
              Card(
                child: data.transactions.isEmpty
                    ? const ListTile(title: Text('Нет транзакций'))
                    : Column(
                        children: data.transactions.map((tx) {
                          final amt = tx['amount'];
                          final desc = tx['description']?.toString() ?? '';
                          final st = tx['status']?.toString() ?? '';
                          return ListTile(
                            title: Text(desc),
                            subtitle: Text(st),
                            trailing: Text(
                              '$amt',
                              style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
                            ),
                          );
                        }).toList(),
                      ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _showPaymentDialog(BuildContext context) {
    showBokehModal(
      context: context,
      child: BokehModalCard(
        title: 'Провести оплату',
        subtitle: 'Форма будет отправлять POST /finance/.../transactions',
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
