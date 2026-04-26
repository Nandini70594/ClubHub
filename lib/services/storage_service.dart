import 'dart:typed_data';

import 'package:supabase_flutter/supabase_flutter.dart';

class StorageService {
  final SupabaseClient _client = Supabase.instance.client;

  Future<Map<String, dynamic>> uploadBudgetFile({
    required String eventId,
    required String fileName,
    required Uint8List bytes,
  }) async {
    final safeFileName = '${DateTime.now().millisecondsSinceEpoch}_$fileName';
    final storagePath = '$eventId/budget/$safeFileName';

    await _client.storage
        .from('event-documents')
        .uploadBinary(storagePath, bytes);

    return {
      'storage_path': storagePath,
      'file_name': fileName,
      'file_size_bytes': bytes.length,
    };
  }

  Future<Map<String, dynamic>> uploadPermissionFile({
    required String eventId,
    required String resourceType,
    required String fileName,
    required Uint8List bytes,
  }) async {
    final safeFileName = '${DateTime.now().millisecondsSinceEpoch}_$fileName';
    final storagePath = '$eventId/permissions/$resourceType/$safeFileName';

    await _client.storage
        .from('event-documents')
        .uploadBinary(storagePath, bytes);

    return {
      'storage_path': storagePath,
      'file_name': fileName,
      'file_size_bytes': bytes.length,
    };
  }

  Future<String> getSignedFileUrl(String storagePath) async {
    final url = await _client.storage
        .from('event-documents')
        .createSignedUrl(storagePath, 60 * 60);
    return url;
  }

  Future<Map<String, dynamic>> uploadExpenseFile({
  required String eventId,
  required String fileType,
  required String fileName,
  required Uint8List bytes,
}) async {
  final safeFileName = '${DateTime.now().millisecondsSinceEpoch}_$fileName';
  final storagePath = '$eventId/expenses/$fileType/$safeFileName';

  await _client.storage
      .from('event-documents')
      .uploadBinary(storagePath, bytes);

  return {
    'storage_path': storagePath,
    'file_name': fileName,
    'file_size_bytes': bytes.length,
  };
}

Future<Map<String, dynamic>> uploadClosingFile({
  required String eventId,
  required String fileType,
  required String fileName,
  required Uint8List bytes,
}) async {
  final safeFileName = '${DateTime.now().millisecondsSinceEpoch}_$fileName';
  final storagePath = '$eventId/closing/$fileType/$safeFileName';

  await _client.storage
      .from('event-documents')
      .uploadBinary(storagePath, bytes);

  return {
    'storage_path': storagePath,
    'file_name': fileName,
    'file_size_bytes': bytes.length,
  };
}
}