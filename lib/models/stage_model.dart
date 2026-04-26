class StageModel {
  final String id;
  final String eventId;
  final int stageNumber;
  final String stageName;
  final String status;
  final String? remarks;
  final String? completedAt;

  StageModel({
    required this.id,
    required this.eventId,
    required this.stageNumber,
    required this.stageName,
    required this.status,
    this.remarks,
    this.completedAt,
  });

  factory StageModel.fromMap(Map<String, dynamic> map) {
    return StageModel(
      id: map['id'] as String,
      eventId: map['event_id'] as String,
      stageNumber: map['stage_number'] as int,
      stageName: map['stage_name'] as String,
      status: map['status'] as String,
      remarks: map['remarks'] as String?,
      completedAt: map['completed_at'] as String?,
    );
  }
}