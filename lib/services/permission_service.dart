import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/permission_request_item_model.dart';
import '../models/permission_request_model.dart';

class PermissionService {
  final SupabaseClient _client = Supabase.instance.client;

  String? get _currentUserId => _client.auth.currentUser?.id;

  String? getNextApproverRole(String currentRole) {
    switch (currentRole) {
      case 'proposal_approver':
        return 'vertical_coordinator';
      case 'vertical_coordinator':
        return 'resource_incharge';
      case 'resource_incharge':
        return 'director';
      case 'director':
        return null;
      default:
        return null;
    }
  }

  Future<PermissionRequestModel?> getLatestPermissionRequestForEvent(
    String eventId,
  ) async {
    final data = await _client
        .from('permission_requests')
        .select('''
          *,
          events (
            title,
            club_id,
            clubs (
              name
            )
          )
        ''')
        .eq('event_id', eventId)
        .order('requested_at', ascending: false)
        .limit(1)
        .maybeSingle();

    if (data == null) return null;
    return PermissionRequestModel.fromMap(data as Map<String, dynamic>);
  }

  Future<PermissionRequestModel?> getRequestById(String requestId) async {
    final data = await _client
        .from('permission_requests')
        .select('''
          *,
          events (
            title,
            club_id,
            clubs (
              name
            )
          )
        ''')
        .eq('id', requestId)
        .maybeSingle();

    if (data == null) return null;
    return PermissionRequestModel.fromMap(data as Map<String, dynamic>);
  }

  Future<List<PermissionRequestItemModel>> getItemsForRequest(
    String requestId,
  ) async {
    final data = await _client
        .from('permission_request_items')
        .select()
        .eq('permission_request_id', requestId)
        .order('resource_type');

    return (data as List)
        .map(
          (e) => PermissionRequestItemModel.fromMap(
            e as Map<String, dynamic>,
          ),
        )
        .toList();
  }

  Future<void> createPermissionRequest({
    required String eventId,
    required String purpose,
    required List<Map<String, dynamic>> items,
  }) async {
    final userId = _currentUserId;
    if (userId == null) throw Exception('User not logged in');

    final inserted = await _client
        .from('permission_requests')
        .insert({
          'event_id': eventId,
          'purpose': purpose,
          'status': 'PENDING',
          'current_approver_role': 'proposal_approver',
          'requested_by': userId,
          'is_resubmission': false,
        })
        .select('''
          *,
          events (
            title,
            club_id,
            clubs (
              name
            )
          )
        ''')
        .maybeSingle();

    if (inserted == null) {
      throw Exception('Permission request was not created.');
    }

    final requestId = inserted['id'] as String;

    final payload = items.map((item) {
      return {
        'permission_request_id': requestId,
        'resource_type': item['resource_type'],
        'resource_detail': item['resource_detail'],
        'remarks': item['remarks'],
        'document_url': item['document_url'],
        'document_name': item['document_name'],
      };
    }).toList();

    if (payload.isNotEmpty) {
      await _client.from('permission_request_items').insert(payload);
    }
  }

  Future<void> resubmitPermissionRequest({
    required String oldRequestId,
    required String eventId,
    required String purpose,
    required List<Map<String, dynamic>> items,
  }) async {
    final userId = _currentUserId;
    if (userId == null) throw Exception('User not logged in');

    final inserted = await _client
        .from('permission_requests')
        .insert({
          'event_id': eventId,
          'purpose': purpose,
          'status': 'PENDING',
          'current_approver_role': 'proposal_approver',
          'requested_by': userId,
          'parent_request_id': oldRequestId,
          'is_resubmission': true,
        })
        .select('''
          *,
          events (
            title,
            club_id,
            clubs (
              name
            )
          )
        ''')
        .maybeSingle();

    if (inserted == null) {
      throw Exception('Permission request was not resubmitted.');
    }

    final requestId = inserted['id'] as String;

    final payload = items.map((item) {
      return {
        'permission_request_id': requestId,
        'resource_type': item['resource_type'],
        'resource_detail': item['resource_detail'],
        'remarks': item['remarks'],
        'document_url': item['document_url'],
        'document_name': item['document_name'],
      };
    }).toList();

    if (payload.isNotEmpty) {
      await _client.from('permission_request_items').insert(payload);
    }
  }

  Future<List<PermissionRequestModel>> getPendingRequestsForRole(
    String role,
  ) async {
    final data = await _client
        .from('permission_requests')
        .select('''
          *,
          events (
            title,
            club_id,
            clubs (
              name
            )
          )
        ''')
        .eq('status', 'PENDING')
        .eq('current_approver_role', role)
        .order('requested_at', ascending: false);

    return (data as List)
        .map(
          (e) => PermissionRequestModel.fromMap(
            e as Map<String, dynamic>,
          ),
        )
        .toList();
  }

  Future<List<PermissionRequestModel>> getReviewedRequestsForRole(
    String role,
  ) async {
    final actions = await _client
        .from('permission_request_actions')
        .select('permission_request_id, acted_at')
        .eq('acted_by_role', role)
        .order('acted_at', ascending: false);

    if ((actions as List).isEmpty) return [];

    final requestIds = actions
        .map((e) => e['permission_request_id'] as String)
        .toSet()
        .toList();

    final data = await _client
        .from('permission_requests')
        .select('''
          *,
          events (
            title,
            club_id,
            clubs (
              name
            )
          )
        ''')
        .inFilter('id', requestIds);

    final requests = (data as List)
        .map((e) => PermissionRequestModel.fromMap(e as Map<String, dynamic>))
        .toList();

    requests.sort((a, b) {
      final aAction = actions.firstWhere(
        (x) => x['permission_request_id'] == a.id,
        orElse: () => {'acted_at': ''},
      );
      final bAction = actions.firstWhere(
        (x) => x['permission_request_id'] == b.id,
        orElse: () => {'acted_at': ''},
      );

      final aTime = aAction['acted_at']?.toString() ?? '';
      final bTime = bAction['acted_at']?.toString() ?? '';

      return bTime.compareTo(aTime);
    });

    return requests;
  }

  Future<void> approveRequest({
    required String requestId,
    required String currentRole,
    String? remarks,
  }) async {
    final nextRole = getNextApproverRole(currentRole);
    final userId = _currentUserId;
    if (userId == null) throw Exception('User not logged in');

    await _client.from('permission_request_actions').insert({
      'permission_request_id': requestId,
      'acted_by': userId,
      'acted_by_role': currentRole,
      'action': 'APPROVED',
      'remarks': remarks,
    });

    if (nextRole == null) {
      await _client
          .from('permission_requests')
          .update({
            'status': 'APPROVED',
            'current_approver_role': null,
            'decision_remarks': remarks,
            'decided_by_role': currentRole,
            'decided_at': DateTime.now().toUtc().toIso8601String(),
          })
          .eq('id', requestId);

      final request = await getRequestById(requestId);

      if (request != null) {
        await _client
            .from('stages')
            .update({
              'status': 'approved',
              'remarks': remarks,
              'completed_at': DateTime.now().toUtc().toIso8601String(),
            })
            .eq('event_id', request.eventId)
            .eq('stage_number', 3);

        await _client
            .from('stages')
            .update({'status': 'pending'})
            .eq('event_id', request.eventId)
            .eq('stage_number', 4);

        await _client
            .from('events')
            .update({
              'current_stage': 4,
              'progress_pct': 65,
            })
            .eq('id', request.eventId);
      }
    } else {
      await _client
          .from('permission_requests')
          .update({
            'current_approver_role': nextRole,
            'decision_remarks': remarks,
          })
          .eq('id', requestId);
    }
  }

  Future<void> rejectRequest({
    required String requestId,
    required String currentRole,
    String? remarks,
  }) async {
    final userId = _currentUserId;
    if (userId == null) throw Exception('User not logged in');

    await _client.from('permission_request_actions').insert({
      'permission_request_id': requestId,
      'acted_by': userId,
      'acted_by_role': currentRole,
      'action': 'REJECTED',
      'remarks': remarks,
    });

    await _client
        .from('permission_requests')
        .update({
          'status': 'REJECTED',
          'current_approver_role': null,
          'decision_remarks': remarks,
          'decided_by_role': currentRole,
          'decided_at': DateTime.now().toUtc().toIso8601String(),
        })
        .eq('id', requestId);

    final request = await getRequestById(requestId);

    if (request != null) {
      await _client
          .from('stages')
          .update({
            'status': 'rejected',
            'remarks': remarks,
            'completed_at': DateTime.now().toUtc().toIso8601String(),
          })
          .eq('event_id', request.eventId)
          .eq('stage_number', 3);

      await _client
          .from('events')
          .update({
            'current_stage': 3,
            'progress_pct': 45,
          })
          .eq('id', request.eventId);
    }
  }
}