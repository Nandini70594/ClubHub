class ClubModel {
  final String id;
  final String clubName;
  final String clubCode;
  final String? facultyMentorId;

  ClubModel({
    required this.id,
    required this.clubName,
    required this.clubCode,
    this.facultyMentorId,
  });

  factory ClubModel.fromMap(Map<String, dynamic> map) {
    return ClubModel(
      id: map['id'] as String,
      clubName: map['club_name'] as String,
      clubCode: map['club_code'] as String,
      facultyMentorId: map['faculty_mentor_id'] as String?,
    );
  }
}