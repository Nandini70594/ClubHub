class AppUser {
  final String id;
  final String email;
  final String role;
  final String? fullName;
  final String? department;
  final String? clubId;

  AppUser({
    required this.id,
    required this.email,
    required this.role,
    this.fullName,
    this.department,
    this.clubId,
  });

  factory AppUser.fromMap(Map<String, dynamic> map) {
    return AppUser(
      id: map['id'] as String,
      email: map['email'] as String,
      role: map['role'] as String,
      fullName: map['full_name'] as String?,
      department: map['department'] as String?,
      clubId: map['club_id'] as String?,
    );
  }
}