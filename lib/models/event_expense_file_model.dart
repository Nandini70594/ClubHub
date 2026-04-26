class EventExpenseFileModel {
  final String id;
  final String expenseId;
  final String fileType;
  final String fileName;
  final String storagePath;
  final String? createdAt;

  EventExpenseFileModel({
    required this.id,
    required this.expenseId,
    required this.fileType,
    required this.fileName,
    required this.storagePath,
    this.createdAt,
  });

  factory EventExpenseFileModel.fromMap(Map<String, dynamic> map) {
    return EventExpenseFileModel(
      id: map['id'] as String,
      expenseId: map['expense_id'] as String,
      fileType: map['file_type'] as String,
      fileName: map['file_name'] as String,
      storagePath: map['storage_path'] as String,
      createdAt: map['created_at'] as String?,
    );
  }
}