class IdentityUserRow {
  const IdentityUserRow({
    required this.id,
    required this.username,
    required this.email,
    required this.roles,
  });

  factory IdentityUserRow.fromJson(Map<String, dynamic> j) {
    final r = j['roles'];
    List<String> roles = [];
    if (r is List) {
      roles = r.map((e) => e.toString()).toList();
    }
    return IdentityUserRow(
      id: (j['id'] as num).toInt(),
      username: j['username'] as String,
      email: j['email'] as String,
      roles: roles,
    );
  }

  final int id;
  final String username;
  final String email;
  final List<String> roles;
}

class IdentityUserListPage {
  const IdentityUserListPage({
    required this.items,
    required this.total,
    required this.skip,
    required this.limit,
  });

  factory IdentityUserListPage.fromJson(Map<String, dynamic> j) {
    final raw = j['items'] as List<dynamic>? ?? [];
    return IdentityUserListPage(
      items: raw.map((e) => IdentityUserRow.fromJson(e as Map<String, dynamic>)).toList(),
      total: (j['total'] as num).toInt(),
      skip: (j['skip'] as num).toInt(),
      limit: (j['limit'] as num).toInt(),
    );
  }

  final List<IdentityUserRow> items;
  final int total;
  final int skip;
  final int limit;
}
