import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/club_model.dart';
import '../models/app_user.dart';
import 'auth_provider.dart';

final currentClubProvider = FutureProvider<ClubModel?>((ref) async {
  final AppUser? user = await ref.watch(currentUserProfileProvider.future);
  if (user == null || user.clubId == null) return null;

  final data = await Supabase.instance.client
      .from('clubs')
      .select()
      .eq('id', user.clubId!)
      .maybeSingle();

  if (data == null) return null;
  return ClubModel.fromMap(data);
});
