class EventExpenseModel {
  final String id;
  final String eventId;
  final double actualAmount;
  final String? summaryNote;
  final String status;
  final String? submittedBy;
  final String? approvedBy;
  final String? approvedAt;
  final String? remarks;
  final String? createdAt;

  EventExpenseModel({
    required this.id,
    required this.eventId,
    required this.actualAmount,
    required this.status,
    this.summaryNote,
    this.submittedBy,
    this.approvedBy,
    this.approvedAt,
    this.remarks,
    this.createdAt,
  });

  factory EventExpenseModel.fromMap(Map<String, dynamic> map) {
    return EventExpenseModel(
      id: map['id'] as String,
      eventId: map['event_id'] as String,
      actualAmount: (map['actual_amount'] as num).toDouble(),
      summaryNote: map['summary_note'] as String?,
      status: map['status'] as String,
      submittedBy: map['submitted_by'] as String?,
      approvedBy: map['approved_by'] as String?,
      approvedAt: map['approved_at'] as String?,
      remarks: map['remarks'] as String?,
      createdAt: map['created_at'] as String?,
    );
  }
}