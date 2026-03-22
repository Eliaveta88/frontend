import 'package:flutter/foundation.dart';

/// Профиль из identity (`/login` или `/users/me`).
@immutable
class UserProfile {
  const UserProfile({
    required this.id,
    required this.username,
    required this.email,
    this.roles = const ['user'],
  });

  factory UserProfile.fromJson(Map<String, dynamic> j) {
    final r = j['roles'];
    List<String> roles = const ['user'];
    if (r is List) {
      roles = r.map((e) => e.toString()).toList();
    }
    return UserProfile(
      id: (j['id'] as num).toInt(),
      username: j['username'] as String,
      email: j['email'] as String,
      roles: roles,
    );
  }

  /// ID пользователя в identity; совпадает с `client_id` в finance для сидов 1:1.
  final int id;
  final String username;
  final String email;
  final List<String> roles;
}
