class RouteRow {
  const RouteRow({
    required this.id,
    required this.vehicleId,
    required this.driverName,
    required this.status,
    required this.pointsCount,
    required this.totalWeight,
    required this.totalVolume,
    required this.createdAt,
  });

  factory RouteRow.fromJson(Map<String, dynamic> j) {
    return RouteRow(
      id: (j['id'] as num).toInt(),
      vehicleId: (j['vehicle_id'] as num).toInt(),
      driverName: j['driver_name'] as String,
      status: j['status'] as String,
      pointsCount: (j['points_count'] as num).toInt(),
      totalWeight: (j['total_weight'] as num).toDouble(),
      totalVolume: (j['total_volume'] as num).toDouble(),
      createdAt: DateTime.parse(j['created_at'] as String),
    );
  }

  final int id;
  final int vehicleId;
  final String driverName;
  final String status;
  final int pointsCount;
  final double totalWeight;
  final double totalVolume;
  final DateTime createdAt;
}

class RouteListPage {
  const RouteListPage({
    required this.items,
    required this.total,
    required this.skip,
    required this.limit,
  });

  factory RouteListPage.fromJson(Map<String, dynamic> j) {
    final raw = j['items'] as List<dynamic>? ?? [];
    return RouteListPage(
      items: raw.map((e) => RouteRow.fromJson(e as Map<String, dynamic>)).toList(),
      total: (j['total'] as num).toInt(),
      skip: (j['skip'] as num).toInt(),
      limit: (j['limit'] as num).toInt(),
    );
  }

  final List<RouteRow> items;
  final int total;
  final int skip;
  final int limit;
}
