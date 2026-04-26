class ActivityLogModel {
  final String id;
  final String eventId;
  final String? userId;
  final String action;
  final String? oldStatus;
  final String? newStatus;
  final String? createdAt;

  ActivityLogModel({
    required this.id,
    required this.eventId,
    required this.action,
    this.userId,
    this.oldStatus,
    this.newStatus,
    this.createdAt,
  });

  factory ActivityLogModel.fromMap(Map<String, dynamic> map) {
    return ActivityLogModel(
      id: map['id'] as String,
      eventId: map['event_id'] as String,
      userId: map['user_id'] as String?,
      action: map['action'] as String,
      oldStatus: map['old_status'] as String?,
      newStatus: map['new_status'] as String?,
      createdAt: map['created_at'] as String?,
    );
  }
}