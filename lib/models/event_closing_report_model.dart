class EventClosingReportModel {
  final String id;
  final String eventId;
  final String approvalNumber;
  final bool googleFormSubmitted;
  final bool vendorAuthorized;
  final String? summary;
  final String status;
  final String? submittedBy;
  final String? createdAt;

  EventClosingReportModel({
    required this.id,
    required this.eventId,
    required this.approvalNumber,
    required this.googleFormSubmitted,
    required this.vendorAuthorized,
    required this.status,
    this.summary,
    this.submittedBy,
    this.createdAt,
  });

  factory EventClosingReportModel.fromMap(Map<String, dynamic> map) {
    return EventClosingReportModel(
      id: map['id'] as String,
      eventId: map['event_id'] as String,
      approvalNumber: map['approval_number'] as String,
      googleFormSubmitted: (map['google_form_submitted'] as bool?) ?? false,
      vendorAuthorized: (map['vendor_authorized'] as bool?) ?? true,
      summary: map['summary'] as String?,
      status: map['status'] as String,
      submittedBy: map['submitted_by'] as String?,
      createdAt: map['created_at'] as String?,
    );
  }
}