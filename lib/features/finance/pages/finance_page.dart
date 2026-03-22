import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/network/api_services/finance_api_service.dart';
import '../../../core/network/dio_error_mapper.dart';
import '../../../core/widgets/async_error_card.dart';
import '../../../core/widgets/bokeh_modal.dart';
import '../../../core/widgets/empty_list_state.dart';
import '../../../core/widgets/loading_skeletons.dart';
import '../providers/finance_providers.dart';

class FinancePage extends ConsumerStatefulWidget {
  const FinancePage({super.key});

  @override
  ConsumerState<FinancePage> createState() => _FinancePageState();
}

class _FinancePageState extends ConsumerState<FinancePage> {
  late final TextEditingController _clientIdCtrl;

  @override
  void initState() {
    super.initState();
    _clientIdCtrl = TextEditingController(text: '${ref.read(financeClientIdProvider)}');
  }

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
    ref.listen<int>(financeClientIdProvider, (prev, next) {
      if (_clientIdCtrl.text != '$next') {
        _clientIdCtrl.text = '$next';
      }
    });
    final snap = ref.watch(financeSnapshotProvider);

    return ListView(
      padding: AppTheme.pagePadding,
      children: [
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Финансы',
                    style: theme.textTheme.headlineMedium?.copyWith(letterSpacing: -0.3),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Баланс и операции клиента',
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: colors.onSurfaceVariant,
                      height: 1.45,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(
              width: 120,
              child: TextField(
                controller: _clientIdCtrl,
                decoration: const InputDecoration(
                  labelText: 'Клиент (ID)',
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
              onPressed: () => _showInvoiceDialog(context, ref),
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
          loading: () => const FinanceLoadingSkeleton(),
          error: (e, _) => AsyncErrorCard(
            error: e,
            title: 'Не удалось загрузить финансы',
            onRetry: () => ref.invalidate(financeSnapshotProvider),
          ),
          data: (data) => Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Счёт', style: theme.textTheme.titleMedium),
              const SizedBox(height: 12),
              if (data.balance != null)
                Card(
                  child: ListTile(
                    title: Text('Клиент № ${data.balance!['client_id']}'),
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
              data.transactions.isEmpty
                  ? EmptyListState(
                      icon: Icons.payments_outlined,
                      title: 'Транзакций нет',
                      message: 'Операции по выбранному клиенту пока не найдены.',
                    )
                  : Card(
                      child: Column(
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

  void _showInvoiceDialog(BuildContext context, WidgetRef ref) {
    final orderIdsCtrl = TextEditingController();
    var busy = false;

    showBokehModal<void>(
      context: context,
      maxWidth: 480,
      child: StatefulBuilder(
        builder: (context, setDialogState) {
          return BokehModalCard(
            title: 'Сформировать счёт',
            subtitle: 'Клиент: ${ref.read(financeClientIdProvider)}',
            body: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextField(
                  controller: orderIdsCtrl,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: 'Номера заказов',
                    hintText: 'Через запятую, например: 1, 2, 3',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.text,
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
                        final ids = orderIdsCtrl.text
                            .split(RegExp(r'[\s,;]+'))
                            .map((s) => int.tryParse(s.trim()))
                            .whereType<int>()
                            .toList();
                        if (ids.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Укажите хотя бы один номер заказа')),
                          );
                          return;
                        }
                        setDialogState(() => busy = true);
                        try {
                          final clientId = ref.read(financeClientIdProvider);
                          final result = await ref.read(financeApiServiceProvider).generateInvoice(
                                clientId: clientId,
                                orderIds: ids,
                              );
                          if (context.mounted) {
                            final messenger = ScaffoldMessenger.of(context);
                            Navigator.of(context).pop();
                            ref.invalidate(financeSnapshotProvider);
                            final invId = result['invoice_id'];
                            messenger.showSnackBar(
                              SnackBar(content: Text('Счёт создан${invId != null ? ' № $invId' : ''}')),
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
                    : const Text('Сформировать'),
              ),
            ],
          );
        },
      ),
    ).whenComplete(orderIdsCtrl.dispose);
  }

  void _showPaymentDialog(BuildContext context) {
    showBokehModal<void>(
      context: context,
      child: const _PaymentModal(),
    );
  }
}

class _PaymentModal extends ConsumerStatefulWidget {
  const _PaymentModal();

  @override
  ConsumerState<_PaymentModal> createState() => _PaymentModalState();
}

class _PaymentModalState extends ConsumerState<_PaymentModal> {
  late final TextEditingController _descCtrl;
  late final TextEditingController _amountCtrl;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    _descCtrl = TextEditingController();
    _amountCtrl = TextEditingController();
  }

  @override
  void dispose() {
    _descCtrl.dispose();
    _amountCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final desc = _descCtrl.text.trim();
    final amount = double.tryParse(_amountCtrl.text.trim().replaceAll(',', '.'));
    if (desc.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Укажите назначение платежа')),
      );
      return;
    }
    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Укажите сумму больше нуля')),
      );
      return;
    }
    setState(() => _busy = true);
    try {
      final clientId = ref.read(financeClientIdProvider);
      await ref.read(financeApiServiceProvider).createTransaction(
            clientId: clientId,
            amount: amount,
            description: desc,
          );
      if (mounted) {
        final messenger = ScaffoldMessenger.of(context);
        Navigator.of(context).pop();
        ref.invalidate(financeSnapshotProvider);
        messenger.showSnackBar(
          const SnackBar(content: Text('Оплата проведена')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(dioErrorMessage(e))),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _busy = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return BokehModalCard(
      title: 'Провести оплату',
      subtitle: 'Списание по счёту клиента',
      body: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _descCtrl,
            decoration: const InputDecoration(
              labelText: 'Назначение платежа',
              border: OutlineInputBorder(),
            ),
            textCapitalization: TextCapitalization.sentences,
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _amountCtrl,
            decoration: const InputDecoration(
              labelText: 'Сумма, ₽',
              border: OutlineInputBorder(),
            ),
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
          ),
        ],
      ),
      actions: [
        OutlinedButton(
          onPressed: _busy ? null : () => Navigator.of(context).pop(),
          child: const Text('Отмена'),
        ),
        FilledButton(
          onPressed: _busy ? null : _submit,
          child: _busy
              ? const SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Провести'),
        ),
      ],
    );
  }
}
