class StockRow {
  const StockRow({
    required this.productId,
    required this.productName,
    required this.available,
    required this.reserved,
    required this.total,
    required this.cellLocation,
    required this.batchId,
    required this.expiryDate,
  });

  factory StockRow.fromJson(Map<String, dynamic> j) {
    return StockRow(
      productId: (j['product_id'] as num).toInt(),
      productName: j['product_name'] as String,
      available: (j['available'] as num).toDouble(),
      reserved: (j['reserved'] as num).toDouble(),
      total: (j['total'] as num).toDouble(),
      cellLocation: j['cell_location'] as String,
      batchId: (j['batch_id'] as num).toInt(),
      expiryDate: DateTime.parse(j['expiry_date'] as String),
    );
  }

  final int productId;
  final String productName;
  final double available;
  final double reserved;
  final double total;
  final String cellLocation;
  final int batchId;
  final DateTime expiryDate;
}

class StockListPage {
  const StockListPage({
    required this.items,
    required this.total,
    required this.skip,
    required this.limit,
  });

  factory StockListPage.fromJson(Map<String, dynamic> j) {
    final raw = j['items'] as List<dynamic>? ?? [];
    return StockListPage(
      items: raw.map((e) => StockRow.fromJson(e as Map<String, dynamic>)).toList(),
      total: (j['total'] as num).toInt(),
      skip: (j['skip'] as num).toInt(),
      limit: (j['limit'] as num).toInt(),
    );
  }

  final List<StockRow> items;
  final int total;
  final int skip;
  final int limit;
}
