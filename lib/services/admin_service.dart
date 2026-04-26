import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/app_user.dart';
import '../models/club_model.dart';

class AdminService {
  final SupabaseClient _client = Supabase.instance.client;

  Future<List<ClubModel>> getClubs() async {
    final data = await _client.from('clubs').select().order('club_name');

    return (data as List)
        .map((e) => ClubModel.fromMap(e as Map<String, dynamic>))
        .toList();
  }

  Future<List<AppUser>> getUsers() async {
    final data = await _client.from('users').select().order('full_name');

    return (data as List)
        .map((e) => AppUser.fromMap(e as Map<String, dynamic>))
        .toList();
  }

  Future<void> createClub({
    required String clubName,
    required String clubCode,
  }) async {
    await _client.from('clubs').insert({
      'club_name': clubName,
      'club_code': clubCode,
    });
  }

  Future<void> createUserProfile({
    required String authUserId,
    required String email,
    required String role,
    required String fullName,
    String? department,
    String? clubId,
  }) async {
    await _client.from('users').insert({
      'id': authUserId,
      'email': email,
      'role': role,
      'full_name': fullName,
      'department': department,
      'club_id': clubId,
    });
  }

  Future<void> assignFacultyToClub({
    required String clubId,
    required String facultyUserId,
  }) async {
    await _client
        .from('clubs')
        .update({'faculty_mentor_id': facultyUserId})
        .eq('id', clubId);
  }
}