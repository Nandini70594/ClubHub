class PermissionRequestModel {
  final String id;
  final String eventId;
  final String purpose;
  final String status;
  final String? currentApproverRole;
  final String? requestedBy;
  final String? decisionRemarks;
  final String? decidedByRole;
  final String? requestedAt;
  final String? decidedAt;
  final String? parentRequestId;
  final bool isResubmission;

  PermissionRequestModel({
    required this.id,
    required this.eventId,
    required this.purpose,
    required this.status,
    this.currentApproverRole,
    this.requestedBy,
    this.decisionRemarks,
    this.decidedByRole,
    this.requestedAt,
    this.decidedAt,
    this.parentRequestId,
    required this.isResubmission,
  });

  factory PermissionRequestModel.fromMap(Map<String, dynamic> map) {
    return PermissionRequestModel(
      id: map['id'] as String,
      eventId: map['event_id'] as String,
      purpose: map['purpose'] as String,
      status: map['status'] as String,
      currentApproverRole: map['current_approver_role'] as String?,
      requestedBy: map['requested_by'] as String?,
      decisionRemarks: map['decision_remarks'] as String?,
      decidedByRole: map['decided_by_role'] as String?,
      requestedAt: map['requested_at'] as String?,
      decidedAt: map['decided_at'] as String?,
      parentRequestId: map['parent_request_id'] as String?,
      isResubmission: (map['is_resubmission'] as bool?) ?? false,
    );
  }
}