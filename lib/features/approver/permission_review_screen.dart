import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../models/permission_request_item_model.dart';
import '../../models/permission_request_model.dart';
import '../../models/app_user.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/app_scaffold.dart';

class ERPTheme {
  static const Color primary = Color(0xFF3D52A0);
  static const Color primaryLight = Color(0xFF7091E6);
  static const Color primarySurface = Color(0xFFEEF2FF);
  static const Color accent = Color(0xFF8697C4);
  static const Color bgPage = Color(0xFFF4F6FB);
  static const Color cardBg = Colors.white;
  static const Color textPrimary = Color(0xFF1A1F36);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color divider = Color(0xFFE5E9F2);

  static const Color statusPending = Color(0xFFF59E0B);
  static const Color statusApproved = Color(0xFF10B981);
  static const Color statusRejected = Color(0xFFEF4444);

  static BoxDecoration cardDecoration = BoxDecoration(
    color: cardBg,
    borderRadius: BorderRadius.circular(12),
    border: Border.all(color: divider),
    boxShadow: [
      BoxShadow(
        color: primary.withOpacity(0.06),
        blurRadius: 10,
        offset: const Offset(0, 2),
      ),
    ],
  );

  static LinearGradient headerGradient = const LinearGradient(
    colors: [Color(0xFF3D52A0), Color(0xFF7091E6)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}

class PermissionReviewScreen extends ConsumerStatefulWidget {
  final PermissionRequestModel request;

  const PermissionReviewScreen({
    super.key,
    required this.request,
  });

  @override
  ConsumerState<PermissionReviewScreen> createState() =>
      _PermissionReviewScreenState();
}

class _PermissionReviewScreenState
    extends ConsumerState<PermissionReviewScreen> {
  bool _isSubmitting = false;

  String _label(String type) {
    switch (type) {
      case 'CLASSROOM':
        return 'Classroom';
      case 'LABORATORY':
        return 'Laboratory';
      case 'AUDITORIUM':
        return 'Auditorium / Seminar Room';
      case 'CONFERENCE_ROOM':
        return 'Conference Room';
      case 'DIGITAL_SCREEN':
        return 'Digital Screen';
      case 'OTHER':
        return 'Other';
      default:
        return type;
    }
  }

  IconData _resourceIcon(String type) {
    switch (type) {
      case 'CLASSROOM':
        return Icons.meeting_room_outlined;
      case 'LABORATORY':
        return Icons.science_outlined;
      case 'AUDITORIUM':
        return Icons.theater_comedy_outlined;
      case 'CONFERENCE_ROOM':
        return Icons.groups_outlined;
      case 'DIGITAL_SCREEN':
        return Icons.tv_outlined;
      default:
        return Icons.widgets_outlined;
    }
  }

  String _formatDateTime(String? dateTimeStr) {
    if (dateTimeStr == null || dateTimeStr.isEmpty) return '-';
    final dt = DateTime.parse(dateTimeStr).toLocal();
    final hour = dt.hour % 12 == 0 ? 12 : dt.hour % 12;
    final minute = dt.minute.toString().padLeft(2, '0');
    final amPm = dt.hour >= 12 ? 'PM' : 'AM';
    return '${dt.day}/${dt.month}/${dt.year} • $hour:$minute $amPm';
  }

  Widget _buildStatusChip(String status) {
    Color bg, fg;
    switch (status.toUpperCase()) {
      case 'APPROVED':
        bg = ERPTheme.statusApproved.withOpacity(0.12);
        fg = ERPTheme.statusApproved;
        break;
      case 'REJECTED':
        bg = ERPTheme.statusRejected.withOpacity(0.12);
        fg = ERPTheme.statusRejected;
        break;
      default:
        bg = ERPTheme.statusPending.withOpacity(0.12);
        fg = ERPTheme.statusPending;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status,
        style: TextStyle(
          color: fg,
          fontSize: 12,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.4,
        ),
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 130,
            child: Text(
              label,
              style: const TextStyle(
                color: ERPTheme.textSecondary,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                color: ERPTheme.textPrimary,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 18,
            decoration: BoxDecoration(
              gradient: ERPTheme.headerGradient,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 10),
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: ERPTheme.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _openFile(
    BuildContext context,
    WidgetRef ref,
    String? storagePath,
  ) async {
    if (storagePath == null || storagePath.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No file available.')),
      );
      return;
    }

    try {
      final url =
          await ref.read(storageServiceProvider).getSignedFileUrl(storagePath);
      final uri = Uri.parse(url);

      final launched = await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );

      if (!launched && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not open file.')),
        );
      }
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error opening file: $e')),
      );
    }
  }

  Future<void> _approve(String role) async {
    final remarksController = TextEditingController();

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: ERPTheme.statusApproved.withOpacity(0.12),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.check_circle_outline,
                color: ERPTheme.statusApproved,
                size: 20,
              ),
            ),
            const SizedBox(width: 10),
            const Text(
              'Approve Request',
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
            ),
          ],
        ),
        content: TextField(
          controller: remarksController,
          maxLines: 3,
          decoration: InputDecoration(
            hintText: 'Optional remarks',
            hintStyle: const TextStyle(color: ERPTheme.textSecondary),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: ERPTheme.divider),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide:
                  const BorderSide(color: ERPTheme.primary, width: 1.5),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text(
              'Cancel',
              style: TextStyle(color: ERPTheme.textSecondary),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: ERPTheme.statusApproved,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('Approve'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() => _isSubmitting = true);

    try {
      await ref.read(permissionServiceProvider).approveRequest(
            requestId: widget.request.id,
            currentRole: role,
            remarks: remarksController.text.trim().isEmpty
                ? null
                : remarksController.text.trim(),
          );

      if (!mounted) return;
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Approval failed: $e')),
      );
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  Future<void> _reject(String role) async {
    final remarksController = TextEditingController();

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: ERPTheme.statusRejected.withOpacity(0.12),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.cancel_outlined,
                color: ERPTheme.statusRejected,
                size: 20,
              ),
            ),
            const SizedBox(width: 10),
            const Text(
              'Reject Request',
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
            ),
          ],
        ),
        content: TextField(
          controller: remarksController,
          maxLines: 4,
          decoration: InputDecoration(
            hintText: 'Add rejection remarks',
            hintStyle: const TextStyle(color: ERPTheme.textSecondary),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: ERPTheme.divider),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide:
                  const BorderSide(color: ERPTheme.statusRejected, width: 1.5),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text(
              'Cancel',
              style: TextStyle(color: ERPTheme.textSecondary),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: ERPTheme.statusRejected,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('Reject'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() => _isSubmitting = true);

    try {
      await ref.read(permissionServiceProvider).rejectRequest(
            requestId: widget.request.id,
            currentRole: role,
            remarks: remarksController.text.trim().isEmpty
                ? null
                : remarksController.text.trim(),
          );

      if (!mounted) return;
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Rejection failed: $e')),
      );
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final permissionService = ref.read(permissionServiceProvider);
    final userService = ref.read(userServiceProvider);

    return AppScaffold(
  title: 'ClubHub',
  currentRoute: '/permission-approver',
  showBottomNav: false,
  child: Scaffold(
    backgroundColor: ERPTheme.bgPage,
    appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        flexibleSpace: Container(
          decoration: BoxDecoration(gradient: ERPTheme.headerGradient),
        ),
        title: const Text(
          'ClubHub',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 18,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: FutureBuilder<List<dynamic>>(
        future: Future.wait([
          permissionService.getItemsForRequest(widget.request.id),
          userService.getCurrentUserProfile(),
        ]),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: ERPTheme.primary),
            );
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final items =
              (snapshot.data?[0] as List?)?.cast<PermissionRequestItemModel>() ??
                  [];
          final user = snapshot.data?[1] as AppUser?;

          if (user == null) {
            return const Center(child: Text('User not found'));
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    gradient: ERPTheme.headerGradient,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.info_outline_rounded,
                        color: Colors.white70,
                        size: 18,
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'Request Status',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 13,
                        ),
                      ),
                      const Spacer(),
                      _buildStatusChip(widget.request.status),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: ERPTheme.cardDecoration,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _sectionTitle('Request Details'),
                      _infoRow('Purpose', widget.request.purpose),
                      const Divider(color: ERPTheme.divider, height: 16),
                      _infoRow(
                        'Current Approver',
                        widget.request.currentApproverRole ?? '-',
                      ),
                      const Divider(color: ERPTheme.divider, height: 16),
                      _infoRow(
                        'Requested At',
                        _formatDateTime(widget.request.requestedAt),
                      ),
                      if (widget.request.decisionRemarks != null &&
                          widget.request.decisionRemarks!.trim().isNotEmpty) ...[
                        const Divider(color: ERPTheme.divider, height: 16),
                        _infoRow(
                          'Remarks',
                          widget.request.decisionRemarks!,
                        ),
                      ],
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                _sectionTitle('Selected Resources'),

                if (items.isEmpty)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: ERPTheme.cardDecoration,
                    child: const Center(
                      child: Text(
                        'No resources found',
                        style: TextStyle(color: ERPTheme.textSecondary),
                      ),
                    ),
                  )
                else
                  ...items.map((item) {
                    return Container(
                      width: double.infinity,
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.all(16),
                      decoration: ERPTheme.cardDecoration,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: ERPTheme.primarySurface,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Icon(
                                  _resourceIcon(item.resourceType),
                                  color: ERPTheme.primary,
                                  size: 18,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Text(
                                _label(item.resourceType),
                                style: const TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 14,
                                  color: ERPTheme.textPrimary,
                                ),
                              ),
                            ],
                          ),
                          const Divider(
                              color: ERPTheme.divider, height: 16),
                          _infoRow(
                            'Resource Details',
                            item.resourceDetail?.isNotEmpty == true
                                ? item.resourceDetail!
                                : '-',
                          ),
                          _infoRow(
                            'Remarks',
                            item.remarks?.isNotEmpty == true
                                ? item.remarks!
                                : '-',
                          ),
                          if (item.documentName != null &&
                              item.documentName!.isNotEmpty)
                            Row(
                              children: [
                                const Icon(
                                  Icons.attach_file_rounded,
                                  size: 16,
                                  color: ERPTheme.textSecondary,
                                ),
                                const SizedBox(width: 6),
                                Expanded(
                                  child: Text(
                                    item.documentName!,
                                    style: const TextStyle(
                                      fontSize: 13,
                                      color: ERPTheme.textSecondary,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                TextButton.icon(
                                  onPressed: () =>
                                      _openFile(context, ref, item.documentUrl),
                                  icon: const Icon(
                                    Icons.open_in_new_rounded,
                                    size: 14,
                                    color: ERPTheme.primary,
                                  ),
                                  label: const Text(
                                    'View File',
                                    style: TextStyle(
                                      color: ERPTheme.primary,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 13,
                                    ),
                                  ),
                                  style: TextButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8),
                                  ),
                                ),
                              ],
                            )
                          else
                            _infoRow('Document', 'No file uploaded'),
                        ],
                      ),
                    );
                  }),

                const SizedBox(height: 24),

                if (widget.request.status == 'PENDING' &&
                    widget.request.currentApproverRole == user.role)
                  _isSubmitting
                      ? const Center(
                          child: CircularProgressIndicator(
                              color: ERPTheme.primary),
                        )
                      : Column(
                          children: [
                            SizedBox(
                              width: double.infinity,
                              height: 48,
                              child: ElevatedButton.icon(
                                onPressed: () => _approve(user.role),
                                icon: const Icon(Icons.check_rounded,
                                    size: 18),
                                label: const Text(
                                  'Approve Request',
                                  style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 15),
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: ERPTheme.statusApproved,
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                      borderRadius:
                                          BorderRadius.circular(10)),
                                  elevation: 0,
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),
                            SizedBox(
                              width: double.infinity,
                              height: 48,
                              child: OutlinedButton.icon(
                                onPressed: () => _reject(user.role),
                                icon: const Icon(Icons.close_rounded,
                                    size: 18),
                                label: const Text(
                                  'Reject Request',
                                  style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 15),
                                ),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: ERPTheme.statusRejected,
                                  side: const BorderSide(
                                      color: ERPTheme.statusRejected),
                                  shape: RoundedRectangleBorder(
                                      borderRadius:
                                          BorderRadius.circular(10)),
                                ),
                              ),
                            ),
                          ],
                        ),

                const SizedBox(height: 24),
              ],
            ),
          );
        },
      ),
  ),
    );
  }
}