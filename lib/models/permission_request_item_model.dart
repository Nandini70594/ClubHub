class PermissionRequestItemModel {
  final String id;
  final String permissionRequestId;
  final String resourceType;
  final String? resourceDetail;
  final String? remarks;
  final String? documentUrl;
  final String? documentName;

  PermissionRequestItemModel({
    required this.id,
    required this.permissionRequestId,
    required this.resourceType,
    this.resourceDetail,
    this.remarks,
    this.documentUrl,
    this.documentName,
  });

  factory PermissionRequestItemModel.fromMap(Map<String, dynamic> map) {
    return PermissionRequestItemModel(
      id: map['id'] as String,
      permissionRequestId: map['permission_request_id'] as String,
      resourceType: map['resource_type'] as String,
      resourceDetail: map['resource_detail'] as String?,
      remarks: map['remarks'] as String?,
      documentUrl: map['document_url'] as String?,
      documentName: map['document_name'] as String?,
    );
  }
}