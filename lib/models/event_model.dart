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

  static int _toInt(dynamic value, {int fallback = 0}) {
    if (value == null) return fallback;
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value.toString()) ?? fallback;
  }

  factory EventModel.fromMap(Map<String, dynamic> map) {
    final club = map['clubs'] is Map<String, dynamic>
        ? map['clubs'] as Map<String, dynamic>
        : null;

    return EventModel(
      id: map['id']?.toString() ?? '',
      clubId: map['club_id']?.toString() ?? '',
      title: map['title']?.toString() ?? 'Untitled Event',
      description: map['description']?.toString(),
      eventDate: map['event_date']?.toString() ?? '',
      venue: map['venue']?.toString(),
      status: map['status']?.toString() ?? 'proposal_submitted',
      currentStage: _toInt(map['current_stage'], fallback: 1),
      progressPct: _toInt(map['progress_pct'], fallback: 10),
      createdBy: map['created_by']?.toString() ?? '',
      createdAt: map['created_at']?.toString(),
      proposalStatus: map['proposal_status']?.toString() ?? 'pending',
      proposalCurrentApproverRole: map['proposal_current_approver_role']?.toString(),
      proposalApprovedBy: map['proposal_approved_by']?.toString(),
      proposalApprovedAt: map['proposal_approved_at']?.toString(),
      proposalRemarks: map['proposal_remarks']?.toString(),
      clubName: club?['club_name']?.toString() ?? club?['name']?.toString(),
      clubCode: club?['club_code']?.toString() ?? club?['code']?.toString(),
    );
  }
}