import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/router/app_router.dart';
import '../../models/permission_request_item_model.dart';
import '../../models/permission_request_model.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/app_scaffold.dart';

// ── Design tokens ────────────────────────────────────────────────────────────
const _kPrimary    = Color(0xFF3B5BDB);
const _kPrimaryBg  = Color(0xFFEEF2FF);
const _kSurface    = Colors.white;
const _kBackground = Color(0xFFF4F6FB);
const _kTextDark   = Color(0xFF1A1F36);
const _kBorder     = Color(0xFFE5E7EB);
const _kRadius     = 12.0;
// ─────────────────────────────────────────────────────────────────────────────

class PermissionRequestDetailsScreen extends ConsumerWidget {
  final String requestId;
  const PermissionRequestDetailsScreen({super.key, required this.requestId});

  String _label(String type) {
    switch (type) {
      case 'CLASSROOM':        return 'Classroom';
      case 'LABORATORY':       return 'Laboratory';
      case 'AUDITORIUM':       return 'Auditorium / Seminar Room';
      case 'CONFERENCE_ROOM':  return 'Conference Room';
      case 'DIGITAL_SCREEN':   return 'Digital Screen';
      case 'OTHER':            return 'Other';
      default:                 return type;
    }
  }

  IconData _iconFor(String type) {
    switch (type) {
      case 'CLASSROOM':        return Icons.door_front_door_outlined;
      case 'LABORATORY':       return Icons.science_outlined;
      case 'AUDITORIUM':       return Icons.theater_comedy_outlined;
      case 'CONFERENCE_ROOM':  return Icons.meeting_room_outlined;
      case 'DIGITAL_SCREEN':   return Icons.monitor_outlined;
      case 'OTHER':            return Icons.category_outlined;
      default:                 return Icons.room_outlined;
    }
  }

  String _formatDateTime(String? dateTimeStr) {
    if (dateTimeStr == null || dateTimeStr.isEmpty) return '-';
    final dt   = DateTime.parse(dateTimeStr).toLocal();
    final hour = dt.hour % 12 == 0 ? 12 : dt.hour % 12;
    final min  = dt.minute.toString().padLeft(2, '0');
    final amPm = dt.hour >= 12 ? 'PM' : 'AM';
    return '${dt.day}/${dt.month}/${dt.year} • $hour:$min $amPm';
  }

  // Status badge colours
  ({Color bg, Color fg}) _statusColors(String status) {
    final s = status.toLowerCase();
    if (s.contains('approved')) {
      return (bg: const Color(0xFFF0FDF4), fg: const Color(0xFF16A34A));
    } else if (s.contains('reject')) {
      return (bg: const Color(0xFFFEF2F2), fg: const Color(0xFFDC2626));
    }
    return (bg: _kPrimaryBg, fg: _kPrimary);
  }

  Future<void> _openFile(
      BuildContext context, WidgetRef ref, String? storagePath) async {
    if (storagePath == null || storagePath.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No file available.')),
      );
      return;
    }
    try {
      final url = await ref.read(storageServiceProvider).getSignedFileUrl(storagePath);
      final launched =
          await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
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

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AppScaffold(
      title: 'Permission Request',
      currentRoute: AppRoutes.permDetails,
      showBottomNav: false,
      actions: [
        IconButton(
          icon: const Icon(Icons.close, size: 20, color: Color(0xFF1A1F36)),
          onPressed: () => Navigator.pop(context),
        ),
      ],
      child: FutureBuilder<List<dynamic>>(
        future: Future.wait([
          ref.read(permissionServiceProvider).getRequestById(requestId),
          ref.read(permissionServiceProvider).getItemsForRequest(requestId),
        ]),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: _kPrimary),
            );
          }
          if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}',
                style: const TextStyle(color: Color(0xFFDC2626))),
            );
          }
          if (!snapshot.hasData) {
            return const Center(child: Text('No request found'));
          }

          final request = snapshot.data![0] as PermissionRequestModel?;
          final items   = snapshot.data![1] as List<PermissionRequestItemModel>;

          if (request == null) {
            return const Center(child: Text('No request found'));
          }

          final sc = _statusColors(request.status);

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                // ── Summary card ─────────────────────────────────────────
                _SurfaceCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Purpose + status badge
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              request.purpose,
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                color: _kTextDark,
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: sc.bg,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              request.status,
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: sc.fg,
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 14),
                      Divider(height: 1, color: Colors.grey.shade100),
                      const SizedBox(height: 14),

                      // Meta rows
                      _DetailRow(
                        icon: Icons.person_outline,
                        label: 'Current Approver',
                        value: request.currentApproverRole ?? '-',
                      ),
                      const SizedBox(height: 8),
                      _DetailRow(
                        icon: Icons.schedule_outlined,
                        label: 'Requested At',
                        value: _formatDateTime(request.requestedAt),
                      ),
                      if (request.decidedAt != null) ...[
                        const SizedBox(height: 8),
                        _DetailRow(
                          icon: Icons.done_all_outlined,
                          label: 'Decided At',
                          value: _formatDateTime(request.decidedAt),
                        ),
                      ],

                      // Decision remarks
                      if (request.decisionRemarks?.isNotEmpty == true) ...[
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 10),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFFBEB),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: const Color(0xFFFDE68A)),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Icon(Icons.info_outline,
                                  size: 15, color: Color(0xFFD97706)),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  request.decisionRemarks!,
                                  style: const TextStyle(
                                      fontSize: 12, color: Color(0xFFD97706)),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],

                      // Resubmission badge
                      if (request.isResubmission) ...[
                        const SizedBox(height: 10),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: _kPrimaryBg,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Text(
                            'This is a resubmitted request.',
                            style: TextStyle(
                              fontSize: 12,
                              fontStyle: FontStyle.italic,
                              color: _kPrimary,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),

                const SizedBox(height: 22),

                // ── Resources ────────────────────────────────────────────
                _SectionLabel(label: 'Selected Resources'),
                const SizedBox(height: 10),

                if (items.isEmpty)
                  _SurfaceCard(
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Text(
                          'No resources found',
                          style: TextStyle(
                              fontSize: 13, color: Colors.grey.shade400),
                        ),
                      ),
                    ),
                  )
                else
                  ...items.map((item) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: _SurfaceCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Resource type header
                          Row(
                            children: [
                              Container(
                                width: 36, height: 36,
                                decoration: BoxDecoration(
                                  color: _kPrimaryBg,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Icon(
                                  _iconFor(item.resourceType),
                                  color: _kPrimary,
                                  size: 18,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  _label(item.resourceType),
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: _kTextDark,
                                  ),
                                ),
                              ),
                            ],
                          ),

                          if (item.resourceDetail?.isNotEmpty == true ||
                              item.remarks?.isNotEmpty == true) ...[
                            const SizedBox(height: 10),
                            Divider(height: 1, color: Colors.grey.shade100),
                            const SizedBox(height: 10),
                          ],

                          if (item.resourceDetail?.isNotEmpty == true)
                            _DetailRow(
                              icon: Icons.info_outline,
                              label: 'Details',
                              value: item.resourceDetail!,
                            ),
                          if (item.remarks?.isNotEmpty == true) ...[
                            const SizedBox(height: 8),
                            _DetailRow(
                              icon: Icons.notes_outlined,
                              label: 'Remarks',
                              value: item.remarks!,
                            ),
                          ],

                          // Document button / placeholder
                          if (item.documentName != null &&
                              item.documentName!.isNotEmpty) ...[
                            const SizedBox(height: 12),
                            SizedBox(
                              width: double.infinity,
                              child: OutlinedButton.icon(
                                onPressed: () =>
                                    _openFile(context, ref, item.documentUrl),
                                icon: const Icon(
                                    Icons.insert_drive_file_outlined, size: 16),
                                label: Text(
                                  item.documentName!,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: _kPrimary,
                                  side: const BorderSide(color: _kPrimary),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 10, horizontal: 12),
                                  textStyle: const TextStyle(
                                    fontSize: 12, fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ),
                          ] else ...[
                            const SizedBox(height: 10),
                            Row(
                              children: [
                                Icon(Icons.insert_drive_file_outlined,
                                    size: 14, color: Colors.grey.shade300),
                                const SizedBox(width: 6),
                                Text(
                                  'No document uploaded',
                                  style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey.shade400),
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),
                  )),

                const SizedBox(height: 24),
              ],
            ),
          );
        },
      ),
    );
  }
}

// ── Shared small widgets ──────────────────────────────────────────────────────
class _SurfaceCard extends StatelessWidget {
  final Widget child;
  const _SurfaceCard({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _kSurface,
        borderRadius: BorderRadius.circular(_kRadius),
        border: Border.all(color: _kBorder),
      ),
      child: child,
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String label;
  const _SectionLabel({required this.label});

  @override
  Widget build(BuildContext context) {
    return Text(
      label.toUpperCase(),
      style: TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w700,
        color: Colors.grey.shade500,
        letterSpacing: 0.8,
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 14, color: Colors.grey.shade400),
        const SizedBox(width: 6),
        Text('$label: ',
          style: TextStyle(fontSize: 12, color: Colors.grey.shade500)),
        Expanded(
          child: Text(value,
            style: const TextStyle(
              fontSize: 12, fontWeight: FontWeight.w500, color: _kTextDark,
            )),
        ),
      ],
    );
  }
}