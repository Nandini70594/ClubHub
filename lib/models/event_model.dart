class EventModel {
  final String id;
  final String clubId;
  final String title;
  final String? description;
  final String eventDate;
  final String? venue;
  final String status;
  final int currentStage;
  final int progressPct;
  final String createdBy;
  final String? createdAt;

  final String proposalStatus;
  final String? proposalCurrentApproverRole;
  final String? proposalApprovedBy;
  final String? proposalApprovedAt;
  final String? proposalRemarks;

  final String? clubName;
  final String? clubCode;

  EventModel({
    required this.id,
    required this.clubId,
    required this.title,
    required this.eventDate,
    required this.status,
    required this.currentStage,
    required this.progressPct,
    required this.createdBy,
    required this.proposalStatus,
    this.description,
    this.venue,
    this.createdAt,
    this.proposalCurrentApproverRole,
    this.proposalApprovedBy,
    this.proposalApprovedAt,
    this.proposalRemarks,
    this.clubName,
    this.clubCode,
  });

  factory EventModel.fromMap(Map<String, dynamic> map) {
    final club = map['clubs'] as Map<String, dynamic>?;

    return EventModel(
      id: map['id'] as String,
      clubId: map['club_id'] as String,
      title: map['title'] as String,
      description: map['description'] as String?,
      eventDate: map['event_date'] as String,
      venue: map['venue'] as String?,
      status: map['status'] as String,
      currentStage: map['current_stage'] as int,
      progressPct: map['progress_pct'] as int,
      createdBy: map['created_by'] as String,
      createdAt: map['created_at'] as String?,
      proposalStatus: (map['proposal_status'] as String?) ?? 'pending',
      proposalCurrentApproverRole:
          map['proposal_current_approver_role'] as String?,
      proposalApprovedBy: map['proposal_approved_by'] as String?,
      proposalApprovedAt: map['proposal_approved_at'] as String?,
      proposalRemarks: map['proposal_remarks'] as String?,
      clubName: club?['club_name'] as String?,
      clubCode: club?['club_code'] as String?,
    );
  }
}