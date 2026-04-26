class EventClosingFileModel {
  final String id;
  final String closingReportId;
  final String fileType;
  final String fileName;
  final String storagePath;
  final String? createdAt;

  EventClosingFileModel({
    required this.id,
    required this.closingReportId,
    required this.fileType,
    required this.fileName,
    required this.storagePath,
    this.createdAt,
  });

  factory EventClosingFileModel.fromMap(Map<String, dynamic> map) {
    return EventClosingFileModel(
      id: map['id'] as String,
      closingReportId: map['closing_report_id'] as String,
      fileType: map['file_type'] as String,
      fileName: map['file_name'] as String,
      storagePath: map['storage_path'] as String,
      createdAt: map['created_at'] as String?,
    );
  }
}