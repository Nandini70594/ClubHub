import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/event_closing_file_model.dart';
import '../models/event_closing_report_model.dart';
import '../models/event_expense_file_model.dart';
import '../models/event_expense_model.dart';

class PostEventService {
  final SupabaseClient _client = Supabase.instance.client;

  String? get _currentUserId => _client.auth.currentUser?.id;

  Future<EventExpenseModel?> getExpenseForEvent(String eventId) async {
    final data = await _client
        .from('event_expenses')
        .select()
        .eq('event_id', eventId)
        .order('created_at', ascending: false)
        .limit(1)
        .maybeSingle();

    if (data == null) return null;
    return EventExpenseModel.fromMap(data as Map<String, dynamic>);
  }

  Future<List<EventExpenseFileModel>> getExpenseFiles(String expenseId) async {
    final data = await _client
        .from('event_expense_files')
        .select()
        .eq('expense_id', expenseId)
        .order('created_at', ascending: false);

    return (data as List)
        .map((e) => EventExpenseFileModel.fromMap(e as Map<String, dynamic>))
        .toList();
  }

  Future<void> submitExpense({
    required String eventId,
    required double actualAmount,
    required String summaryNote,
    required List<Map<String, dynamic>> files,
  }) async {
    final userId = _currentUserId;
    if (userId == null) throw Exception('User not logged in');

    final inserted = await _client
        .from('event_expenses')
        .insert({
          'event_id': eventId,
          'actual_amount': actualAmount,
          'summary_note': summaryNote,
          'status': 'pending',
          'submitted_by': userId,
        })
        .select()
        .single();

    final expenseId = inserted['id'] as String;

    final payload = files.map((file) {
      return {
        'expense_id': expenseId,
        'file_type': file['file_type'],
        'file_name': file['file_name'],
        'storage_path': file['storage_path'],
      };
    }).toList();

    if (payload.isNotEmpty) {
      await _client.from('event_expense_files').insert(payload);
    }

    await _client
        .from('stages')
        .update({'status': 'pending'})
        .eq('event_id', eventId)
        .eq('stage_number', 5);

    await _client
        .from('events')
        .update({
          'current_stage': 5,
          'progress_pct': 75,
        })
        .eq('id', eventId);
  }

  Future<List<EventExpenseModel>> getPendingExpenses() async {
    final data = await _client
        .from('event_expenses')
        .select()
        .eq('status', 'pending')
        .order('created_at', ascending: false);

    return (data as List)
        .map((e) => EventExpenseModel.fromMap(e as Map<String, dynamic>))
        .toList();
  }

  Future<List<EventExpenseModel>> getReviewedExpensesForCurrentApprover() async {
    final userId = _currentUserId;
    if (userId == null) return [];

    final data = await _client
        .from('event_expenses')
        .select()
        .eq('approved_by', userId)
        .inFilter('status', ['approved', 'changes_requested', 'rejected'])
        .order('approved_at', ascending: false);

    return (data as List)
        .map((e) => EventExpenseModel.fromMap(e as Map<String, dynamic>))
        .toList();
  }

  Future<void> approveExpense({
    required String expenseId,
    required String eventId,
    required String remarks,
  }) async {
    final userId = _currentUserId;
    if (userId == null) throw Exception('User not logged in');

    await _client
        .from('event_expenses')
        .update({
          'status': 'approved',
          'approved_by': userId,
          'approved_at': DateTime.now().toUtc().toIso8601String(),
          'remarks': remarks,
        })
        .eq('id', expenseId);

    await _client
        .from('stages')
        .update({
          'status': 'approved',
          'remarks': remarks,
          'completed_at': DateTime.now().toUtc().toIso8601String(),
        })
        .eq('event_id', eventId)
        .eq('stage_number', 5);

    await _client
        .from('stages')
        .update({'status': 'pending'})
        .eq('event_id', eventId)
        .eq('stage_number', 6);

    await _client
        .from('events')
        .update({
          'current_stage': 6,
          'progress_pct': 85,
        })
        .eq('id', eventId);
  }

  Future<void> requestExpenseChanges({
    required String expenseId,
    required String remarks,
  }) async {
    final userId = _currentUserId;
    if (userId == null) throw Exception('User not logged in');

    await _client
        .from('event_expenses')
        .update({
          'status': 'changes_requested',
          'approved_by': userId,
          'approved_at': DateTime.now().toUtc().toIso8601String(),
          'remarks': remarks,
        })
        .eq('id', expenseId);
  }

  Future<void> rejectExpense({
    required String expenseId,
    required String remarks,
  }) async {
    final userId = _currentUserId;
    if (userId == null) throw Exception('User not logged in');

    await _client
        .from('event_expenses')
        .update({
          'status': 'rejected',
          'approved_by': userId,
          'approved_at': DateTime.now().toUtc().toIso8601String(),
          'remarks': remarks,
        })
        .eq('id', expenseId);
  }

  Future<EventClosingReportModel?> getClosingReportForEvent(
    String eventId,
  ) async {
    final data = await _client
        .from('event_closing_reports')
        .select()
        .eq('event_id', eventId)
        .order('created_at', ascending: false)
        .limit(1)
        .maybeSingle();

    if (data == null) return null;
    return EventClosingReportModel.fromMap(data as Map<String, dynamic>);
  }

  Future<List<EventClosingFileModel>> getClosingFiles(
    String closingReportId,
  ) async {
    final data = await _client
        .from('event_closing_files')
        .select()
        .eq('closing_report_id', closingReportId)
        .order('created_at', ascending: false);

    return (data as List)
        .map((e) => EventClosingFileModel.fromMap(e as Map<String, dynamic>))
        .toList();
  }

  Future<void> submitClosingReport({
    required String eventId,
    required String approvalNumber,
    required bool googleFormSubmitted,
    required bool vendorAuthorized,
    required String summary,
    required List<Map<String, dynamic>> files,
  }) async {
    final userId = _currentUserId;
    if (userId == null) throw Exception('User not logged in');

    final inserted = await _client
        .from('event_closing_reports')
        .insert({
          'event_id': eventId,
          'approval_number': approvalNumber,
          'google_form_submitted': googleFormSubmitted,
          'vendor_authorized': vendorAuthorized,
          'summary': summary,
          'status': 'closed',
          'submitted_by': userId,
        })
        .select()
        .single();

    final closingReportId = inserted['id'] as String;

    final payload = files.map((file) {
      return {
        'closing_report_id': closingReportId,
        'file_type': file['file_type'],
        'file_name': file['file_name'],
        'storage_path': file['storage_path'],
      };
    }).toList();

    if (payload.isNotEmpty) {
      await _client.from('event_closing_files').insert(payload);
    }

    await _client
        .from('stages')
        .update({
          'status': 'approved',
          'completed_at': DateTime.now().toUtc().toIso8601String(),
        })
        .eq('event_id', eventId)
        .eq('stage_number', 6);

    await _client
        .from('stages')
        .update({
          'status': 'approved',
          'completed_at': DateTime.now().toUtc().toIso8601String(),
        })
        .eq('event_id', eventId)
        .eq('stage_number', 7);

    await _client
        .from('events')
        .update({
          'current_stage': 7,
          'progress_pct': 100,
          'status': 'closed',
        })
        .eq('id', eventId);
  }
}