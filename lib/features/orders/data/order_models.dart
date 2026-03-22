class OrderSummary {
  const OrderSummary({
    required this.id,
    required this.clientId,
    required this.clientName,
    required this.totalAmount,
    required this.status,
    required this.deliveryDate,
    this.routeId,
    required this.createdAt,
  });

  final int id;
  final int clientId;
  final String clientName;
  final double totalAmount;
  final String status;
  final DateTime deliveryDate;
  final int? routeId;
  final DateTime createdAt;

  factory OrderSummary.fromJson(Map<String, dynamic> j) {
    return OrderSummary(
      id: (j['id'] as num).toInt(),
      clientId: (j['client_id'] as num).toInt(),
      clientName: j['client_name'] as String,
      totalAmount: (j['total_amount'] as num).toDouble(),
      status: j['status'] as String,
      deliveryDate: DateTime.parse(j['delivery_date'] as String),
      routeId: j['route_id'] == null ? null : (j['route_id'] as num).toInt(),
      createdAt: DateTime.parse(j['created_at'] as String),
    );
  }
}

class OrderListPage {
  const OrderListPage({
    required this.items,
    required this.total,
    required this.skip,
    required this.limit,
  });

  final List<OrderSummary> items;
  final int total;
  final int skip;
  final int limit;

  factory OrderListPage.fromJson(Map<String, dynamic> j) {
    final raw = j['items'] as List<dynamic>? ?? [];
    return OrderListPage(
      items: raw.map((e) => OrderSummary.fromJson(e as Map<String, dynamic>)).toList(),
      total: (j['total'] as num).toInt(),
      skip: (j['skip'] as num).toInt(),
      limit: (j['limit'] as num).toInt(),
    );
  }
}

class OrderItemLine {
  const OrderItemLine({
    required this.productId,
    required this.productName,
    required this.quantity,
    required this.unitPrice,
    required this.total,
  });

  final int productId;
  final String productName;
  final double quantity;
  final double unitPrice;
  final double total;

  factory OrderItemLine.fromJson(Map<String, dynamic> j) {
    return OrderItemLine(
      productId: (j['product_id'] as num).toInt(),
      productName: j['product_name'] as String,
      quantity: (j['quantity'] as num).toDouble(),
      unitPrice: (j['unit_price'] as num).toDouble(),
      total: (j['total'] as num).toDouble(),
    );
  }
}

class OrderDetail {
  const OrderDetail({
    required this.id,
    required this.clientId,
    required this.clientName,
    required this.items,
    required this.totalAmount,
    required this.status,
    required this.deliveryDate,
    this.routeId,
    required this.createdAt,
  });

  final int id;
  final int clientId;
  final String clientName;
  final List<OrderItemLine> items;
  final double totalAmount;
  final String status;
  final DateTime deliveryDate;
  final int? routeId;
  final DateTime createdAt;

  factory OrderDetail.fromJson(Map<String, dynamic> j) {
    final raw = j['items'] as List<dynamic>? ?? [];
    return OrderDetail(
      id: (j['id'] as num).toInt(),
      clientId: (j['client_id'] as num).toInt(),
      clientName: j['client_name'] as String,
      items: raw.map((e) => OrderItemLine.fromJson(e as Map<String, dynamic>)).toList(),
      totalAmount: (j['total_amount'] as num).toDouble(),
      status: j['status'] as String,
      deliveryDate: DateTime.parse(j['delivery_date'] as String),
      routeId: j['route_id'] == null ? null : (j['route_id'] as num).toInt(),
      createdAt: DateTime.parse(j['created_at'] as String),
    );
  }

  String get formattedTotal => '₽ ${totalAmount.toStringAsFixed(0)}';
}
