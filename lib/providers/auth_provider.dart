import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/app_user.dart';
import '../services/auth_service.dart';
import '../services/event_service.dart';
import '../services/permission_service.dart';
import '../services/storage_service.dart';
import '../services/user_service.dart';
import '../services/post_event_service.dart';
import '../services/admin_service.dart';

final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService();
});

final userServiceProvider = Provider<UserService>((ref) {
  return UserService();
});

final eventServiceProvider = Provider<EventService>((ref) {
  return EventService();
});

final storageServiceProvider = Provider<StorageService>((ref) {
  return StorageService();
});

final permissionServiceProvider = Provider<PermissionService>((ref) {
  return PermissionService();
});

final currentUserProfileProvider = FutureProvider<AppUser?>((ref) async {
  return ref.read(userServiceProvider).getCurrentUserProfile();
});

final postEventServiceProvider = Provider<PostEventService>((ref) {
  return PostEventService();
});

final adminServiceProvider = Provider<AdminService>((ref) {
  return AdminService();
});