import '../../orders/data/order_models.dart';

/// Элемент ленты дашборда (см. `dashboardActivityProvider`): заказ или транзакция.
enum ActivityFeedKind { order, transaction }

class ActivityFeedItem {
  const ActivityFeedItem({
    required this.at,
    required this.title,
    required this.subtitle,
    required this.kind,
  });

  final DateTime at;
  final String title;
  final String subtitle;
  final ActivityFeedKind kind;

  factory ActivityFeedItem.fromOrder(OrderSummary o) {
    return ActivityFeedItem(
      at: o.createdAt,
      title: 'Заказ №${o.id}',
      subtitle: '${o.clientName} · ${o.status} · ₽ ${_fmtMoney(o.totalAmount)}',
      kind: ActivityFeedKind.order,
    );
  }

  factory ActivityFeedItem.fromTransaction(Map<String, dynamic> m) {
    final created = DateTime.parse(m['created_at'] as String);
    final amount = (m['amount'] as num).toDouble();
    final status = m['status']?.toString() ?? '';
    final t = m['transaction_type']?.toString() ?? '';
    return ActivityFeedItem(
      at: created,
      title: t.isEmpty ? 'Операция' : 'Операция: $t',
      subtitle: '$status · ₽ ${_fmtMoney(amount)}',
      kind: ActivityFeedKind.transaction,
    );
  }

  static String _fmtMoney(double v) {
    if (v == 0) return '0';
    return v.toStringAsFixed(0).replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (m) => '${m[1]} ',
        );
  }
}
