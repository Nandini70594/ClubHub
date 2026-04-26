class BudgetModel {
  final String id;
  final String eventId;
  final double totalRequested;
  final String? summaryNote;
  final String? fileName;
  final String? storagePath;
  final int? fileSizeBytes;
  final String status;
  final String? approvalNumber;
  final String? approvedBy;
  final String? approvedAt;
  final String? remarks;
  final String? createdAt;

  BudgetModel({
    required this.id,
    required this.eventId,
    required this.totalRequested,
    required this.status,
    this.summaryNote,
    this.fileName,
    this.storagePath,
    this.fileSizeBytes,
    this.approvalNumber,
    this.approvedBy,
    this.approvedAt,
    this.remarks,
    this.createdAt,
  });

  factory BudgetModel.fromMap(Map<String, dynamic> map) {
    return BudgetModel(
      id: map['id'] as String,
      eventId: map['event_id'] as String,
      totalRequested: (map['total_requested'] as num).toDouble(),
      summaryNote: map['summary_note'] as String?,
      fileName: map['file_name'] as String?,
      storagePath: map['storage_path'] as String?,
      fileSizeBytes: map['file_size_bytes'] as int?,
      status: map['status'] as String,
      approvalNumber: map['approval_number'] as String?,
      approvedBy: map['approved_by'] as String?,
      approvedAt: map['approved_at'] as String?,
      remarks: map['remarks'] as String?,
      createdAt: map['created_at'] as String?,
    );
  }
}