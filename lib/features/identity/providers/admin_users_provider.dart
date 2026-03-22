import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_services/identity_api_service.dart';
import '../data/identity_users_models.dart';

final adminUsersProvider = FutureProvider.autoDispose<IdentityUserListPage>((ref) async {
  final api = ref.watch(identityApiServiceProvider);
  final data = await api.listUsers(skip: 0, limit: 100);
  return IdentityUserListPage.fromJson(data);
});
