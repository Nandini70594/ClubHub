import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/activity_log_model.dart';
import '../models/budget_model.dart';
import '../models/event_model.dart';
import '../models/stage_model.dart';

class EventService {
  final SupabaseClient _client = Supabase.instance.client;

  Future<List<EventModel>> getEventsForCurrentUserClub() async {
    final authUser = _client.auth.currentUser;
    if (authUser == null) return [];

    final userRow = await _client
        .from('users')
        .select('club_id')
        .eq('id', authUser.id)
        .maybeSingle();

    if (userRow == null) return [];

    final clubId = userRow['club_id'];
    if (clubId == null) return [];

    final data = await _client
        .from('events')
        .select('*, clubs(*)')
        .eq('club_id', clubId)
        .order('created_at', ascending: false);

    return (data as List)
        .map((e) => EventModel.fromMap(e as Map<String, dynamic>))
        .toList();
  }

  Future<List<EventModel>> getPendingProposalEventsForRole(String role) async {
    final data = await _client
        .from('events')
        .select('*, clubs(*)')
        .eq('proposal_status', 'pending')
        .eq('proposal_current_approver_role', role)
        .order('created_at', ascending: false);

    return (data as List)
        .map((e) => EventModel.fromMap(e as Map<String, dynamic>))
        .toList();
  }

  Future<List<EventModel>> getReviewedProposalEventsForCurrentApprover() async {
    final authUser = _client.auth.currentUser;
    if (authUser == null) return [];

    final userRow = await _client
        .from('users')
        .select('role')
        .eq('id', authUser.id)
        .maybeSingle();

    final role = userRow?['role']?.toString();
    if (role == null) return [];

    if (role == 'vertical_coordinator') {
      final data = await _client
          .from('events')
          .select('*, clubs(*)')
          .eq('proposal_status', 'approved')
          .order('proposal_approved_at', ascending: false);

      return (data as List)
          .map((e) => EventModel.fromMap(e as Map<String, dynamic>))
          .toList();
    }

    final data = await _client
        .from('events')
        .select('*, clubs(*)')
        .eq('proposal_approved_by', authUser.id)
        .inFilter('proposal_status', [
          'approved',
          'changes_requested',
          'rejected',
        ])
        .order('proposal_approved_at', ascending: false);

    return (data as List)
        .map((e) => EventModel.fromMap(e as Map<String, dynamic>))
        .toList();
  }

  Future<void> requestProposalChanges({
    required String eventId,
    required String remarks,
  }) async {
    final authUser = _client.auth.currentUser;
    if (authUser == null) {
      throw Exception('User not logged in');
    }

    await _client.from('events').update({
      'proposal_status': 'changes_requested',
      'proposal_current_approver_role': 'proposal_approver',
      'proposal_remarks': remarks,
      'proposal_approved_by': authUser.id,
      'proposal_approved_at': DateTime.now().toUtc().toIso8601String(),
    }).eq('id', eventId);

    await _client.from('activity_log').insert({
      'event_id': eventId,
      'user_id': authUser.id,
      'action': 'Proposal changes requested',
      'old_status': 'pending',
      'new_status': 'changes_requested',
    });
  }

  Future<List<BudgetModel>> getPendingBudgets() async {
    final data = await _client
        .from('budget')
        .select('''
          *,
          events!inner(
            club_id,
            clubs!inner(
              name
            )
          )
        ''')
        .eq('status', 'pending')
        .order('created_at', ascending: false);

    return (data as List)
        .map((e) => BudgetModel.fromMap(e as Map<String, dynamic>))
        .toList();
  }

  Future<List<BudgetModel>> getReviewedBudgetsForCurrentApprover() async {
    final authUser = _client.auth.currentUser;
    if (authUser == null) return [];

    final data = await _client
        .from('budget')
        .select('''
          *,
          events!inner(
            club_id,
            clubs!inner(
              name
            )
          )
        ''')
        .eq('approved_by', authUser.id)
        .inFilter('status', [
          'approved',
          'changes_requested',
          'rejected',
        ])
        .order('approved_at', ascending: false);

    return (data as List)
        .map((e) => BudgetModel.fromMap(e as Map<String, dynamic>))
        .toList();
  }

  Future<List<ActivityLogModel>> getMyActivityLogs() async {
    final authUser = _client.auth.currentUser;
    if (authUser == null) return [];

    final data = await _client
        .from('activity_log')
        .select()
        .eq('user_id', authUser.id)
        .order('created_at', ascending: false);

    return (data as List)
        .map((e) => ActivityLogModel.fromMap(e as Map<String, dynamic>))
        .toList();
  }

  Future<void> createEvent({
    required String title,
    required String description,
    required String eventDate,
    required String venue,
  }) async {
    final authUser = _client.auth.currentUser;
    if (authUser == null) {
      throw Exception('User not logged in');
    }

    final userRow = await _client
        .from('users')
        .select('club_id')
        .eq('id', authUser.id)
        .maybeSingle();

    if (userRow == null) {
      throw Exception('User profile not found.');
    }

    final clubId = userRow['club_id'];
    if (clubId == null) {
      throw Exception('No club assigned to this user');
    }

    final inserted = await _client
        .from('events')
        .insert({
          'club_id': clubId,
          'title': title,
          'description': description,
          'event_date': eventDate,
          'venue': venue,
          'status': 'proposal_submitted',
          'proposal_status': 'pending',
          'proposal_current_approver_role': 'proposal_approver',
          'current_stage': 1,
          'progress_pct': 10,
          'created_by': authUser.id,
        })
        .select()
        .maybeSingle();

    if (inserted == null) {
      throw Exception('Event was not created. Please try again.');
    }

    final eventId = inserted['id'] as String;

    await _client.from('stages').insert([
      {
        'event_id': eventId,
        'stage_number': 1,
        'stage_name': 'Proposal Approval',
        'status': 'pending',
      },
      {
        'event_id': eventId,
        'stage_number': 2,
        'stage_name': 'Budget Approval',
        'status': 'locked',
      },
      {
        'event_id': eventId,
        'stage_number': 3,
        'stage_name': 'Permissions Cleared',
        'status': 'locked',
      },
      {
        'event_id': eventId,
        'stage_number': 4,
        'stage_name': 'Event Conducted',
        'status': 'locked',
      },
      {
        'event_id': eventId,
        'stage_number': 5,
        'stage_name': 'Expense Verification',
        'status': 'locked',
      },
      {
        'event_id': eventId,
        'stage_number': 6,
        'stage_name': 'Closing File Submitted',
        'status': 'locked',
      },
      {
        'event_id': eventId,
        'stage_number': 7,
        'stage_name': 'Event Closed',
        'status': 'locked',
      },
    ]);

    await _client.from('activity_log').insert({
      'event_id': eventId,
      'user_id': authUser.id,
      'action': 'Event created',
      'old_status': null,
      'new_status': 'proposal_submitted',
    });
  }

  Future<void> updateEvent({
    required String eventId,
    required String title,
    required String description,
    required String eventDate,
    required String venue,
  }) async {
    final authUser = _client.auth.currentUser;
    if (authUser == null) {
      throw Exception('User not logged in');
    }

    final oldEvent = await _client
        .from('events')
        .select('status, proposal_status')
        .eq('id', eventId)
        .eq('created_by', authUser.id)
        .maybeSingle();

    if (oldEvent == null) {
      throw Exception('Event not found or you are not allowed to edit it.');
    }

    if (oldEvent['proposal_status'] != 'pending' &&
        oldEvent['proposal_status'] != 'changes_requested') {
      throw Exception('Event can only be edited before proposal approval.');
    }

    await _client
        .from('events')
        .update({
          'title': title,
          'description': description,
          'event_date': eventDate,
          'venue': venue,
        })
        .eq('id', eventId)
        .eq('created_by', authUser.id);

    await _client.from('activity_log').insert({
      'event_id': eventId,
      'user_id': authUser.id,
      'action': 'Event updated',
      'old_status': oldEvent['status'],
      'new_status': oldEvent['status'],
    });
  }

  Future<void> resubmitProposal(String eventId) async {
    final authUser = _client.auth.currentUser;
    if (authUser == null) throw Exception('User not logged in');

    final event = await _client
        .from('events')
        .select('proposal_status')
        .eq('id', eventId)
        .eq('created_by', authUser.id)
        .maybeSingle();

    if (event == null) {
      throw Exception('Event not found or you are not allowed to resubmit it.');
    }

    if (event['proposal_status'] != 'changes_requested') {
      throw Exception(
        'Proposal can only be resubmitted after changes requested.',
      );
    }

    await _client
        .from('events')
        .update({
          'proposal_status': 'pending',
          'proposal_remarks': null,
          'proposal_current_approver_role': 'proposal_approver',
          'proposal_approved_by': null,
          'proposal_approved_at': null,
          'progress_pct': 10,
          'current_stage': 1,
        })
        .eq('id', eventId)
        .eq('created_by', authUser.id);

    await _client
        .from('stages')
        .update({
          'status': 'pending',
          'approved_by': null,
          'remarks': null,
          'completed_at': null,
        })
        .eq('event_id', eventId)
        .eq('stage_number', 1);

    await _client.from('activity_log').insert({
      'event_id': eventId,
      'user_id': authUser.id,
      'action': 'Proposal resubmitted',
      'old_status': 'changes_requested',
      'new_status': 'proposal_pending',
    });
  }

  Future<void> approveProposal({
  required String eventId,
  required String remarks,
}) async {
  final authUser = _client.auth.currentUser;
  if (authUser == null) {
    throw Exception('User not logged in');
  }

  final event = await _client
      .from('events')
      .select('proposal_current_approver_role, proposal_status')
      .eq('id', eventId)
      .maybeSingle();

  if (event == null) {
    throw Exception('Event not found for id: $eventId');
  }

  final currentRole = event['proposal_current_approver_role']?.toString();
  final proposalStatus = event['proposal_status']?.toString();

  if (proposalStatus != 'pending') {
    throw Exception('This proposal is not pending. Current status: $proposalStatus');
  }

  if (currentRole == 'proposal_approver') {
    await _client
        .from('events')
        .update({
          'proposal_current_approver_role': 'vertical_coordinator',
          'proposal_remarks': remarks,
        })
        .eq('id', eventId);

    await _client.from('activity_log').insert({
      'event_id': eventId,
      'user_id': authUser.id,
      'action': 'Proposal forwarded to vertical coordinator',
      'old_status': 'proposal_pending',
      'new_status': 'vertical_coordinator_review',
    });
  } else if (currentRole == 'vertical_coordinator') {
    await _client
        .from('events')
        .update({
          'proposal_status': 'approved',
          'proposal_current_approver_role': null,
          'proposal_approved_by': authUser.id,
          'proposal_approved_at': DateTime.now().toUtc().toIso8601String(),
          'proposal_remarks': remarks,
          'current_stage': 2,
          'progress_pct': 25,
        })
        .eq('id', eventId);

    await _client
        .from('stages')
        .update({
          'status': 'approved',
          'approved_by': authUser.id,
          'remarks': remarks,
          'completed_at': DateTime.now().toUtc().toIso8601String(),
        })
        .eq('event_id', eventId)
        .eq('stage_number', 1);

    await _client
        .from('stages')
        .update({'status': 'pending'})
        .eq('event_id', eventId)
        .eq('stage_number', 2);

    await _client.from('activity_log').insert({
      'event_id': eventId,
      'user_id': authUser.id,
      'action': 'Proposal approved by vertical coordinator',
      'old_status': 'vertical_coordinator_review',
      'new_status': 'proposal_approved',
    });
  } else {
    throw Exception('Invalid approver role for this proposal: $currentRole');
  }
}

  Future<void> rejectProposal({
    required String eventId,
    required String remarks,
  }) async {
    final authUser = _client.auth.currentUser;
    if (authUser == null) throw Exception('User not logged in');

    await _client
        .from('events')
        .update({
          'proposal_status': 'rejected',
          'proposal_current_approver_role': null,
          'proposal_approved_by': authUser.id,
          'proposal_approved_at': DateTime.now().toUtc().toIso8601String(),
          'proposal_remarks': remarks,
          'progress_pct': 0,
        })
        .eq('id', eventId);

    await _client
        .from('stages')
        .update({
          'status': 'rejected',
          'approved_by': authUser.id,
          'remarks': remarks,
          'completed_at': DateTime.now().toUtc().toIso8601String(),
        })
        .eq('event_id', eventId)
        .eq('stage_number', 1);

    await _client.from('activity_log').insert({
      'event_id': eventId,
      'user_id': authUser.id,
      'action': 'Proposal rejected',
      'old_status': 'proposal_pending',
      'new_status': 'proposal_rejected',
    });
  }

  String _generateApprovalNumber(String budgetId) {
    final now = DateTime.now();
    final year = now.year;
    final suffix = budgetId.replaceAll('-', '').substring(0, 6).toUpperCase();
    return 'APP-$year-$suffix';
  }

  Future<void> approveBudget({
    required String budgetId,
    required String eventId,
    required String remarks,
  }) async {
    final authUser = _client.auth.currentUser;
    if (authUser == null) throw Exception('User not logged in');

    final approvalNumber = _generateApprovalNumber(budgetId);

    await _client
        .from('budget')
        .update({
          'status': 'approved',
          'approved_by': authUser.id,
          'approved_at': DateTime.now().toUtc().toIso8601String(),
          'remarks': remarks,
          'approval_number': approvalNumber,
        })
        .eq('id', budgetId);

    await _client
        .from('stages')
        .update({
          'status': 'approved',
          'approved_by': authUser.id,
          'remarks': remarks,
          'completed_at': DateTime.now().toUtc().toIso8601String(),
        })
        .eq('event_id', eventId)
        .eq('stage_number', 2);

    await _client
        .from('stages')
        .update({'status': 'pending'})
        .eq('event_id', eventId)
        .eq('stage_number', 3);

    await _client
        .from('events')
        .update({
          'current_stage': 3,
          'progress_pct': 45,
        })
        .eq('id', eventId);
  }

  Future<void> requestBudgetChanges({
    required String budgetId,
    required String eventId,
    required String remarks,
  }) async {
    final authUser = _client.auth.currentUser;
    if (authUser == null) throw Exception('User not logged in');

    await _client
        .from('budget')
        .update({
          'status': 'changes_requested',
          'approved_by': authUser.id,
          'approved_at': DateTime.now().toUtc().toIso8601String(),
          'remarks': remarks,
        })
        .eq('id', budgetId);
  }

  Future<void> rejectBudget({
    required String budgetId,
    required String eventId,
    required String remarks,
  }) async {
    final authUser = _client.auth.currentUser;
    if (authUser == null) throw Exception('User not logged in');

    await _client
        .from('budget')
        .update({
          'status': 'rejected',
          'approved_by': authUser.id,
          'approved_at': DateTime.now().toUtc().toIso8601String(),
          'remarks': remarks,
        })
        .eq('id', budgetId);
  }

  Future<void> resubmitBudget({
    required String budgetId,
    required String eventId,
    required double totalRequested,
    required String summaryNote,
    required String? fileName,
    required String? storagePath,
    required int? fileSizeBytes,
  }) async {
    final authUser = _client.auth.currentUser;
    if (authUser == null) throw Exception('User not logged in');

    final event = await _client
        .from('events')
        .select('created_by')
        .eq('id', eventId)
        .maybeSingle();

    if (event == null) {
      throw Exception('Event not found.');
    }

    if (event['created_by'] != authUser.id) {
      throw Exception('Not allowed');
    }

    await _client
        .from('budget')
        .update({
          'total_requested': totalRequested,
          'summary_note': summaryNote,
          'file_name': fileName,
          'storage_path': storagePath,
          'file_size_bytes': fileSizeBytes,
          'status': 'pending',
          'approved_by': null,
          'approved_at': null,
          'remarks': null,
          'approval_number': null,
        })
        .eq('id', budgetId);
  }

  Future<EventModel> getEventById(String eventId) async {
    debugPrint('GET EVENT BY ID = $eventId');

    final data = await _client
        .from('events')
        .select('*, clubs(*)')
        .eq('id', eventId)
        .maybeSingle();

    if (data == null) {
      throw Exception('Event not found for id: $eventId');
    }

    return EventModel.fromMap(data);
  }

  Future<List<StageModel>> getStagesForEvent(String eventId) async {
    final data = await _client
        .from('stages')
        .select()
        .eq('event_id', eventId)
        .order('stage_number', ascending: true);

    return (data as List)
        .map((e) => StageModel.fromMap(e as Map<String, dynamic>))
        .toList();
  }

  Future<List<ActivityLogModel>> getActivityLogsForEvent(String eventId) async {
    final data = await _client
        .from('activity_log')
        .select()
        .eq('event_id', eventId)
        .order('created_at', ascending: false);

    return (data as List)
        .map((e) => ActivityLogModel.fromMap(e as Map<String, dynamic>))
        .toList();
  }

  Future<BudgetModel?> getBudgetForEvent(String eventId) async {
    final data = await _client
        .from('budget')
        .select()
        .eq('event_id', eventId)
        .maybeSingle();

    if (data == null) return null;
    return BudgetModel.fromMap(data);
  }

  Future<void> submitBudget({
    required String eventId,
    required double totalRequested,
    required String summaryNote,
    required String? fileName,
    required String? storagePath,
    required int? fileSizeBytes,
  }) async {
    final authUser = _client.auth.currentUser;
    if (authUser == null) {
      throw Exception('User not logged in');
    }

    final event = await _client
        .from('events')
        .select('proposal_status')
        .eq('id', eventId)
        .maybeSingle();

    if (event == null) {
      throw Exception('Event not found.');
    }

    if (event['proposal_status'] != 'approved') {
      throw Exception('Budget can only be submitted after proposal approval.');
    }

    await _client.from('budget').insert({
      'event_id': eventId,
      'total_requested': totalRequested,
      'summary_note': summaryNote,
      'file_name': fileName,
      'storage_path': storagePath,
      'file_size_bytes': fileSizeBytes,
      'status': 'pending',
    });
  }

  Future<void> markEventConducted(String eventId) async {
    await _client
        .from('stages')
        .update({
          'status': 'approved',
          'completed_at': DateTime.now().toUtc().toIso8601String(),
        })
        .eq('event_id', eventId)
        .eq('stage_number', 4);

    await _client
        .from('stages')
        .update({'status': 'pending'})
        .eq('event_id', eventId)
        .eq('stage_number', 5);

    await _client
        .from('events')
        .update({
          'current_stage': 5,
          'progress_pct': 70,
        })
        .eq('id', eventId);
  }

  Future<List<EventModel>> getArchivedEventsForRole(String role) async {
    final authUser = _client.auth.currentUser;
    if (authUser == null) return [];

    var query = _client
        .from('events')
        .select('*, clubs(*)')
        .eq('status', 'closed');

    if (role == 'club_lead' || role == 'proposal_approver') {
      final user = await _client
          .from('users')
          .select('club_id')
          .eq('id', authUser.id)
          .maybeSingle();

      if (user == null) return [];

      final clubId = user['club_id'];
      if (clubId == null) return [];

      query = query.eq('club_id', clubId);
    }

    final data = await query.order('created_at', ascending: false);

    return (data as List)
        .map((e) => EventModel.fromMap(e as Map<String, dynamic>))
        .toList();
  }
}