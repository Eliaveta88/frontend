import 'package:flutter_test/flutter_test.dart';
import 'package:gastroroute_frontend/core/auth/user_profile.dart';

void main() {
  group('UserProfile.fromJson', () {
    test('parses roles list', () {
      final p = UserProfile.fromJson({
        'id': 7,
        'username': 'alice',
        'email': 'a@b.com',
        'roles': ['admin', 'user'],
      });
      expect(p.id, 7);
      expect(p.username, 'alice');
      expect(p.email, 'a@b.com');
      expect(p.roles, ['admin', 'user']);
    });

    test('defaults roles to user when missing', () {
      final p = UserProfile.fromJson({
        'id': 1,
        'username': 'bob',
        'email': 'bob@b.com',
      });
      expect(p.roles, ['user']);
    });
  });
}
