import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/activity_log_model.dart';
import '../../models/event_model.dart';
import '../../models/stage_model.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/app_scaffold.dart';

// ── ERPTheme tokens (same as other screens) ────────────────────────────────
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
  static const Color statusChanges = Color(0xFF6366F1);

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

class ProposalReviewScreen extends ConsumerStatefulWidget {
  final String eventId;

  const ProposalReviewScreen({
    super.key,
    required this.eventId,
  });

  @override
  ConsumerState<ProposalReviewScreen> createState() =>
      _ProposalReviewScreenState();
}

class _ProposalReviewScreenState extends ConsumerState<ProposalReviewScreen> {
  final _remarksController = TextEditingController();
  bool _loading = false;

  Future<void> _approve() async {
    setState(() => _loading = true);
    try {
      await ref.read(eventServiceProvider).approveProposal(
            eventId: widget.eventId,
            remarks: _remarksController.text.trim(),
          );
      if (!mounted) return;
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _requestChanges() async {
    setState(() => _loading = true);
    try {
      await ref.read(eventServiceProvider).requestProposalChanges(
            eventId: widget.eventId,
            remarks: _remarksController.text.trim(),
          );
      if (!mounted) return;
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _reject() async {
    setState(() => _loading = true);
    try {
      await ref.read(eventServiceProvider).rejectProposal(
            eventId: widget.eventId,
            remarks: _remarksController.text.trim(),
          );
      if (!mounted) return;
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  String _formatDateTime(String? dateTimeStr) {
    if (dateTimeStr == null || dateTimeStr.isEmpty) return '';
    final dt = DateTime.parse(dateTimeStr).toLocal();
    final hour = dt.hour % 12 == 0 ? 12 : dt.hour % 12;
    final minute = dt.minute.toString().padLeft(2, '0');
    final amPm = dt.hour >= 12 ? 'PM' : 'AM';
    return '${dt.day}/${dt.month}/${dt.year} • $hour:$minute $amPm';
  }

  Widget _statusChip(String status) {
    Color bg, fg;
    switch (status.toLowerCase()) {
      case 'approved':
        bg = ERPTheme.statusApproved.withOpacity(0.12);
        fg = ERPTheme.statusApproved;
        break;
      case 'rejected':
        bg = ERPTheme.statusRejected.withOpacity(0.12);
        fg = ERPTheme.statusRejected;
        break;
      case 'changes_requested':
      case 'changes requested':
        bg = ERPTheme.statusChanges.withOpacity(0.12);
        fg = ERPTheme.statusChanges;
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
        status.toUpperCase(),
        style: TextStyle(
          color: fg,
          fontSize: 11,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.5,
        ),
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

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
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

  Color _stageColor(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
        return ERPTheme.statusApproved;
      case 'in_progress':
      case 'in progress':
        return ERPTheme.primary;
      case 'rejected':
        return ERPTheme.statusRejected;
      default:
        return ERPTheme.textSecondary;
    }
  }

  @override
  void dispose() {
    _remarksController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final eventService = ref.read(eventServiceProvider);

    return AppScaffold(
  title: 'ClubHub',
  currentRoute: '/proposal-approver',
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
          'Proposal Review',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 18,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: FutureBuilder<List<dynamic>>(
        future: Future.wait<dynamic>([
          eventService.getEventById(widget.eventId),
          eventService.getStagesForEvent(widget.eventId),
          eventService.getActivityLogsForEvent(widget.eventId),
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
          if (!snapshot.hasData) {
            return const Center(child: Text('No data found'));
          }

          final data = snapshot.data!;
          final event = data[0] as EventModel;
          final stages = data[1] as List<StageModel>;
          final logs = data[2] as List<ActivityLogModel>;

          // Get current user role
          final currentUser = ref.read(currentUserProfileProvider).value;
          final isAdmin = currentUser?.role == 'admin';
          final isVerticalCoordinator = currentUser?.role == 'vertical_coordinator';

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Event Header Card ────────────────────────────────────
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    gradient: ERPTheme.headerGradient,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        event.title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          _statusChip(event.proposalStatus),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // ── Event Details Card ───────────────────────────────────
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: ERPTheme.cardDecoration,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _sectionTitle('Event Details'),
                      _infoRow('Date', event.eventDate),
                      const Divider(color: ERPTheme.divider, height: 12),
                      _infoRow('Venue', event.venue ?? '-'),
                      const Divider(color: ERPTheme.divider, height: 12),
                      _infoRow('Description', event.description ?? '-'),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // ── Stage Tracker (hidden for vertical coordinator) ────────
                if (!isVerticalCoordinator) ...[
                  _sectionTitle('Stage Tracker'),

                  Container(
                    decoration: ERPTheme.cardDecoration,
                    child: stages.isEmpty
                        ? const Padding(
                            padding: EdgeInsets.all(16),
                            child: Text(
                              'No stages found',
                              style: TextStyle(color: ERPTheme.textSecondary),
                            ),
                          )
                        : Column(
                            children: List.generate(stages.length, (index) {
                              final stage = stages[index];
                              final isLast = index == stages.length - 1;
                              final stageColor = _stageColor(stage.status);
                              return IntrinsicHeight(
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Timeline column
                                    SizedBox(
                                      width: 56,
                                      child: Column(
                                        children: [
                                          const SizedBox(height: 16),
                                          Container(
                                            width: 32,
                                            height: 32,
                                            decoration: BoxDecoration(
                                              color: stageColor.withOpacity(0.15),
                                              shape: BoxShape.circle,
                                              border: Border.all(
                                                  color: stageColor, width: 2),
                                            ),
                                            child: Center(
                                              child: Text(
                                                '${stage.stageNumber}',
                                                style: TextStyle(
                                                  color: stageColor,
                                                  fontWeight: FontWeight.w700,
                                                  fontSize: 13,
                                                ),
                                              ),
                                            ),
                                          ),
                                          if (!isLast)
                                            Expanded(
                                              child: Container(
                                                width: 2,
                                                color: ERPTheme.divider,
                                                margin: const EdgeInsets.only(
                                                    top: 4),
                                              ),
                                            ),
                                          if (isLast) const SizedBox(height: 16),
                                        ],
                                      ),
                                    ),
                                    // Content
                                    Expanded(
                                      child: Padding(
                                        padding: EdgeInsets.only(
                                          top: 12,
                                          bottom: isLast ? 16 : 12,
                                          right: 16,
                                        ),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              stage.stageName,
                                              style: const TextStyle(
                                                color: ERPTheme.textPrimary,
                                                fontWeight: FontWeight.w600,
                                                fontSize: 14,
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 8,
                                                      vertical: 3),
                                              decoration: BoxDecoration(
                                                color: stageColor
                                                    .withOpacity(0.10),
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                              ),
                                              child: Text(
                                                stage.status,
                                                style: TextStyle(
                                                  color: stageColor,
                                                  fontSize: 11,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }),
                          ),
                  ),

                  const SizedBox(height: 20),
                ],

                // ── Remarks Field ────────────────────────────────────────
                if (event.proposalStatus == 'pending') ...[
                  _sectionTitle('Add Remarks'),
                  Container(
                    decoration: ERPTheme.cardDecoration,
                    child: TextField(
                      controller: _remarksController,
                      maxLines: 3,
                      style: const TextStyle(
                          color: ERPTheme.textPrimary, fontSize: 14),
                      decoration: InputDecoration(
                        hintText: 'Enter your remarks here...',
                        hintStyle:
                            const TextStyle(color: ERPTheme.textSecondary),
                        contentPadding: const EdgeInsets.all(16),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        fillColor: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // ── Action Buttons ───────────────────────────────────
                  _loading
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
                                onPressed: _approve,
                                icon: const Icon(Icons.check_rounded,
                                    size: 18),
                                label: const Text(
                                  'Approve Proposal',
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
                            const SizedBox(height: 10),
                            SizedBox(
                              width: double.infinity,
                              height: 48,
                              child: ElevatedButton.icon(
                                onPressed: _requestChanges,
                                icon: const Icon(Icons.edit_note_rounded,
                                    size: 18),
                                label: const Text(
                                  'Request Changes',
                                  style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 15),
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: ERPTheme.statusChanges,
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                      borderRadius:
                                          BorderRadius.circular(10)),
                                  elevation: 0,
                                ),
                              ),
                            ),
                            const SizedBox(height: 10),
                            SizedBox(
                              width: double.infinity,
                              height: 48,
                              child: OutlinedButton.icon(
                                onPressed: _reject,
                                icon: const Icon(Icons.close_rounded,
                                    size: 18),
                                label: const Text(
                                  'Reject Proposal',
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

                // ── Activity Log (Admin only) ───────────────────────────────────────
                if (isAdmin) ...[
                  _sectionTitle('Activity Log'),

                  logs.isEmpty
                      ? Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(20),
                          decoration: ERPTheme.cardDecoration,
                          child: const Center(
                            child: Text(
                              'No activity yet',
                              style:
                                  TextStyle(color: ERPTheme.textSecondary),
                            ),
                          ),
                        )
                      : Container(
                          decoration: ERPTheme.cardDecoration,
                          child: Column(
                            children: List.generate(logs.length, (index) {
                              final log = logs[index];
                              final isLast = index == logs.length - 1;
                              return Column(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 16, vertical: 12),
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        Container(
                                          width: 36,
                                          height: 36,
                                          decoration: BoxDecoration(
                                            color: ERPTheme.primarySurface,
                                            shape: BoxShape.circle,
                                          ),
                                          child: const Icon(
                                            Icons.history_rounded,
                                            color: ERPTheme.primary,
                                            size: 18,
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                log.action,
                                                style: const TextStyle(
                                                  color: ERPTheme.textPrimary,
                                                  fontWeight: FontWeight.w600,
                                                  fontSize: 13,
                                                ),
                                              ),
                                              const SizedBox(height: 2),
                                              Text(
                                                _formatDateTime(log.createdAt),
                                                style: const TextStyle(
                                                  color:
                                                      ERPTheme.textSecondary,
                                                  fontSize: 12,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  if (!isLast)
                                    const Divider(
                                        color: ERPTheme.divider,
                                        height: 1,
                                        indent: 64),
                                ],
                              );
                            }),
                          ),
                        ),
                ],

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