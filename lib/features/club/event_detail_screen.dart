import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../models/budget_model.dart';
import '../../models/event_model.dart';
import '../../models/permission_request_model.dart';
import '../../models/stage_model.dart';
import '../../providers/auth_provider.dart';
import 'budget_submission_screen.dart';
import 'create_event_screen.dart';
import 'shared_widgets.dart';

class EventDetailScreen extends ConsumerStatefulWidget {
  final String eventId;
  const EventDetailScreen({super.key, required this.eventId});

  @override
  ConsumerState<EventDetailScreen> createState() => _EventDetailScreenState();
}

class _EventDetailScreenState extends ConsumerState<EventDetailScreen> {
  int _reloadKey = 0;

  Future<void> _reload() async {
    setState(() { _reloadKey++; });
  }

  Future<void> _openBudgetFile(String? storagePath) async {
    if (storagePath == null || storagePath.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('No file available to view.')));
      return;
    }
    try {
      final url = await ref.read(storageServiceProvider).getSignedFileUrl(storagePath);
      final launched = await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
      if (!launched && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Could not open file.')));
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error opening file: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final eventService = ref.read(eventServiceProvider);
    final permissionService = ref.read(permissionServiceProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FB),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF3D52A0), Color(0xFF7091E6)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        title: const Text(
          'Event Details',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 18,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: FutureBuilder<List<dynamic>>(
        key: ValueKey(_reloadKey),
        future: Future.wait<dynamic>([
          eventService.getEventById(widget.eventId),
          eventService.getStagesForEvent(widget.eventId),
          eventService.getBudgetForEvent(widget.eventId),
          permissionService.getLatestPermissionRequestForEvent(widget.eventId),
        ]),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: Color(0xFF3B5BDB)));
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}', style: const TextStyle(color: Color(0xFFDC2626))));
          }
          if (!snapshot.hasData) {
            return const Center(child: Text('No data found'));
          }

          final data = snapshot.data!;
          final event = data[0] as EventModel;
          final stages = data[1] as List<StageModel>;
          final budget = data[2] as BudgetModel?;
          final permissionRequest = data[3] as PermissionRequestModel?;
          final canOpenPermissions = budget != null && budget.status == 'approved';

          final currentUser = ref.read(currentUserProfileProvider).value;
          final isVerticalCoordinator = currentUser?.role == 'vertical_coordinator';

          return RefreshIndicator(
            color: const Color(0xFF3B5BDB),
            onRefresh: _reload,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _InfoCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 44, height: 44,
                              decoration: BoxDecoration(color: const Color(0xFFEEF2FF), borderRadius: BorderRadius.circular(10)),
                              child: const Icon(Icons.event_outlined, color: Color(0xFF3B5BDB), size: 20),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(event.title,
                                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Color(0xFF1A1F36))),
                                  const SizedBox(height: 4),
                                  Text('${event.eventDate} • ${event.venue ?? '-'}',
                                      style: TextStyle(fontSize: 12, color: Colors.grey.shade500)),
                                ],
                              ),
                            ),
                            _StageChip(pct: event.progressPct),
                          ],
                        ),
                        if (event.description != null && event.description!.isNotEmpty) ...[
                          const SizedBox(height: 12),
                          Divider(height: 1, color: Colors.grey.shade100),
                          const SizedBox(height: 12),
                          Text(event.description!, style: TextStyle(fontSize: 13, color: Colors.grey.shade600)),
                        ],
                        const SizedBox(height: 12),
                        Divider(height: 1, color: Colors.grey.shade100),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            _MetaChip(label: 'Proposal', value: event.proposalStatus, isStatus: true),
                            const SizedBox(width: 8),
                            _MetaChip(label: 'Stage', value: event.currentStage.toString(), isStatus: false),
                          ],
                        ),
                        if (event.proposalRemarks != null && event.proposalRemarks!.trim().isNotEmpty) ...[
                          const SizedBox(height: 10),
                          _RemarksBanner(message: event.proposalRemarks!),
                        ],
                      ],
                    ),
                  ),

                  if (event.proposalStatus == 'pending' || event.proposalStatus == 'changes_requested') ...[
                    const SizedBox(height: 10),
                    _ActionButton(
                      label: event.proposalStatus == 'changes_requested' ? 'Edit Proposal' : 'Edit Event',
                      icon: Icons.edit_outlined,
                      onPressed: () async {
                        final updated = await Navigator.push<bool>(context,
                            MaterialPageRoute(builder: (_) => CreateEventScreen(event: event)));
                        if (updated == true) await _reload();
                      },
                    ),
                  ],
                  if (event.proposalStatus == 'changes_requested') ...[
                    const SizedBox(height: 8),
                    _ActionButton(
                      label: 'Resubmit Proposal',
                      icon: Icons.send_outlined,
                      onPressed: () async {
                        await ref.read(eventServiceProvider).resubmitProposal(widget.eventId);
                        await _reload();
                      },
                    ),
                  ],
                  const SizedBox(height: 20),
                  SectionLabel(label: 'Budget'),
                  const SizedBox(height: 12),
                  if (event.proposalStatus != 'approved')
                    _LockedBanner(message: 'Budget submission unlocks after proposal approval.')
                  else if (budget == null)
                    _ActionButton(
                      label: 'Submit Budget',
                      icon: Icons.account_balance_wallet_outlined,
                      onPressed: () async {
                        final submitted = await context.push<bool>('/club/event/${widget.eventId}/budget');
                        if (submitted == true) await _reload();
                      },
                    )
                  else
                    _BudgetCard(
                      budget: budget,
                      onViewFile: () => _openBudgetFile(budget.storagePath),
                      onResubmit: budget.status == 'changes_requested' ? () async {
                        final submitted = await Navigator.push<bool>(context,
                            MaterialPageRoute(builder: (_) => BudgetSubmissionScreen(eventId: widget.eventId, existingBudget: budget)));
                        if (submitted == true) await _reload();
                      } : null,
                    ),
                  const SizedBox(height: 20),
                  SectionLabel(label: 'Permissions'),
                  const SizedBox(height: 12),
                  if (!canOpenPermissions)
                    _LockedBanner(message: 'Permissions unlock after budget approval.')
                  else if (permissionRequest == null)
                    _ActionButton(
                      label: 'Request Permissions',
                      icon: Icons.verified_user_outlined,
                      onPressed: () async {
                        final submitted = await context.push<bool>('/club/event/${widget.eventId}/permissions');
                        if (submitted == true) await _reload();
                      },
                    )
                  else
                    _PermissionCard(
                      request: permissionRequest,
                      onView: () async {
                        await context.push('/club/permission-request/${permissionRequest.id}');
                      },
                      onResubmit: permissionRequest.status == 'REJECTED' ? () async {
                        final submitted = await context.push<bool>(
                          '/club/event/${widget.eventId}/permissions',
                          extra: permissionRequest,
                        );
                        if (submitted == true) await _reload();
                      } : null,
                    ),
                  const SizedBox(height: 20),
                  SectionLabel(label: 'Event Conduction'),
                  const SizedBox(height: 12),
                  if (event.currentStage < 4)
                    _LockedBanner(message: 'Unlocks after permissions are approved.')
                  else if (event.currentStage == 4)
                    _ActionButton(
                      label: 'Mark Event as Conducted',
                      icon: Icons.check_circle_outline,
                      onPressed: () async {
                        await ref.read(eventServiceProvider).markEventConducted(widget.eventId);
                        await _reload();
                      },
                    )
                  else
                    _CompletedBanner(message: 'Event has been marked as conducted.'),
                  const SizedBox(height: 20),
                  SectionLabel(label: 'Expense Verification'),
                  const SizedBox(height: 12),
                  if (event.currentStage < 5)
                    _LockedBanner(message: 'Unlocks after event is conducted.')
                  else if (event.currentStage == 5)
                    _ActionButton(
                      label: 'Submit Expense Proofs',
                      icon: Icons.receipt_long_outlined,
                      onPressed: () async {
                        final submitted = await context.push<bool>('/club/event/${widget.eventId}/expenses');
                        if (submitted == true) await _reload();
                      },
                    )
                  else
                    _CompletedBanner(message: 'Expense proofs submitted and verified.'),
                  const SizedBox(height: 20),
                  SectionLabel(label: 'Closing File'),
                  const SizedBox(height: 12),
                  if (event.currentStage < 6)
                    _LockedBanner(message: 'Unlocks after expense approval.')
                  else if (event.currentStage == 6)
                    _ActionButton(
                      label: 'Submit Closing File',
                      icon: Icons.folder_zip_outlined,
                      onPressed: () async {
                        final submitted = await context.push<bool>('/club/event/${widget.eventId}/closing');
                        if (submitted == true) await _reload();
                      },
                    )
                  else
                    _CompletedBanner(message: 'Event closing file submitted. Event closed.'),
                  const SizedBox(height: 20),
                  if (!isVerticalCoordinator) ...[
                    SectionLabel(label: 'Stage Tracker'),
                    const SizedBox(height: 12),
                    ...stages.map((stage) => _StageTrackerRow(stage: stage)),
                    const SizedBox(height: 24),
                  ],
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final Widget child;
  const _InfoCard({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: child,
    );
  }
}

class _StageChip extends StatelessWidget {
  final int pct;
  const _StageChip({required this.pct});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text('$pct%', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Color(0xFF3B5BDB))),
        const SizedBox(height: 4),
        SizedBox(
          width: 36,
          child: LinearProgressIndicator(
            value: pct / 100,
            backgroundColor: const Color(0xFFE0E7FF),
            color: const Color(0xFF3B5BDB),
            minHeight: 3,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
      ],
    );
  }
}

class _MetaChip extends StatelessWidget {
  final String label;
  final String value;
  final bool isStatus;
  const _MetaChip({required this.label, required this.value, required this.isStatus});

  @override
  Widget build(BuildContext context) {
    Color bg = const Color(0xFFEEF2FF);
    Color fg = const Color(0xFF3B5BDB);
    if (isStatus) {
      final s = value.toLowerCase();
      if (s.contains('approved')) { bg = const Color(0xFFF0FDF4); fg = const Color(0xFF16A34A); }
      else if (s.contains('reject')) { bg = const Color(0xFFFEF2F2); fg = const Color(0xFFDC2626); }
      else if (s.contains('changes')) { bg = const Color(0xFFFFFBEB); fg = const Color(0xFFD97706); }
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(6)),
      child: Text('$label: $value', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: fg)),
    );
  }
}

class _RemarksBanner extends StatelessWidget {
  final String message;
  const _RemarksBanner({required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(color: const Color(0xFFFFFBEB), borderRadius: BorderRadius.circular(8), border: Border.all(color: const Color(0xFFFDE68A))),
      child: Row(children: [
        const Icon(Icons.info_outline, size: 15, color: Color(0xFFD97706)),
        const SizedBox(width: 8),
        Expanded(child: Text(message, style: const TextStyle(fontSize: 12, color: Color(0xFFD97706)))),
      ]),
    );
  }
}

class _LockedBanner extends StatelessWidget {
  final String message;
  const _LockedBanner({required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(color: Colors.grey.shade50, borderRadius: BorderRadius.circular(10), border: Border.all(color: Colors.grey.shade200)),
      child: Row(children: [
        Icon(Icons.lock_outline, size: 15, color: Colors.grey.shade400),
        const SizedBox(width: 8),
        Expanded(child: Text(message, style: TextStyle(fontSize: 12, color: Colors.grey.shade500))),
      ]),
    );
  }
}

class _CompletedBanner extends StatelessWidget {
  final String message;
  const _CompletedBanner({required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(color: const Color(0xFFF0FDF4), borderRadius: BorderRadius.circular(10), border: Border.all(color: const Color(0xFFBBF7D0))),
      child: Row(children: [
        const Icon(Icons.check_circle_outline, size: 15, color: Color(0xFF16A34A)),
        const SizedBox(width: 8),
        Expanded(child: Text(message, style: const TextStyle(fontSize: 12, color: Color(0xFF16A34A)))),
      ]),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onPressed;
  const _ActionButton({required this.label, required this.icon, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 46,
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, size: 18),
        label: Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF3B5BDB),
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      ),
    );
  }
}

class _BudgetCard extends StatelessWidget {
  final BudgetModel budget;
  final VoidCallback onViewFile;
  final VoidCallback? onResubmit;
  const _BudgetCard({required this.budget, required this.onViewFile, this.onResubmit});

  @override
  Widget build(BuildContext context) {
    final s = budget.status.toLowerCase();
    Color statusBg = const Color(0xFFEEF2FF); Color statusFg = const Color(0xFF3B5BDB);
    if (s.contains('approved')) { statusBg = const Color(0xFFF0FDF4); statusFg = const Color(0xFF16A34A); }
    else if (s.contains('reject')) { statusBg = const Color(0xFFFEF2F2); statusFg = const Color(0xFFDC2626); }
    else if (s.contains('changes')) { statusBg = const Color(0xFFFFFBEB); statusFg = const Color(0xFFD97706); }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey.shade100)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text('₹${budget.totalRequested}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Color(0xFF1A1F36))),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(color: statusBg, borderRadius: BorderRadius.circular(6)),
                child: Text(budget.status, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: statusFg)),
              ),
            ],
          ),
          if (budget.summaryNote?.isNotEmpty == true) ...[
            const SizedBox(height: 10),
            Divider(height: 1, color: Colors.grey.shade100),
            const SizedBox(height: 10),
            Text(budget.summaryNote!, style: TextStyle(fontSize: 13, color: Colors.grey.shade600)),
          ],
          const SizedBox(height: 10),
          Divider(height: 1, color: Colors.grey.shade100),
          const SizedBox(height: 10),
          Row(children: [
            Icon(Icons.tag_outlined, size: 14, color: Colors.grey.shade400),
            const SizedBox(width: 6),
            Text('Approval No: ${budget.approvalNumber ?? 'Not generated yet'}',
                style: TextStyle(fontSize: 12, color: Colors.grey.shade500)),
          ]),
          if (budget.remarks?.isNotEmpty == true) ...[
            const SizedBox(height: 8),
            _RemarksBanner(message: budget.remarks!),
          ],
          if (budget.fileName != null) ...[
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: onViewFile,
                icon: const Icon(Icons.insert_drive_file_outlined, size: 16),
                label: Text(budget.fileName!),
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFF3B5BDB),
                  side: const BorderSide(color: Color(0xFF3B5BDB)),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),
            ),
          ],
          if (onResubmit != null) ...[
            const SizedBox(height: 10),
            _ActionButton(label: 'Resubmit Budget', icon: Icons.send_outlined, onPressed: onResubmit!),
          ],
        ],
      ),
    );
  }
}

class _PermissionCard extends StatelessWidget {
  final PermissionRequestModel request;
  final VoidCallback onView;
  final VoidCallback? onResubmit;
  const _PermissionCard({required this.request, required this.onView, this.onResubmit});

  @override
  Widget build(BuildContext context) {
    final s = request.status.toLowerCase();
    Color statusBg = const Color(0xFFEEF2FF); Color statusFg = const Color(0xFF3B5BDB);
    if (s.contains('approved')) { statusBg = const Color(0xFFF0FDF4); statusFg = const Color(0xFF16A34A); }
    else if (s.contains('reject')) { statusBg = const Color(0xFFFEF2F2); statusFg = const Color(0xFFDC2626); }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey.shade100)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Expanded(child: Text(request.purpose, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF1A1F36)))),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(color: statusBg, borderRadius: BorderRadius.circular(6)),
              child: Text(request.status, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: statusFg)),
            ),
          ]),
          const SizedBox(height: 8),
          Text('Approver: ${request.currentApproverRole ?? '-'}', style: TextStyle(fontSize: 12, color: Colors.grey.shade500)),
          if (request.decisionRemarks?.isNotEmpty == true) ...[
            const SizedBox(height: 8),
            _RemarksBanner(message: request.decisionRemarks!),
          ],
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: onView,
              icon: const Icon(Icons.open_in_new_outlined, size: 16),
              label: const Text('View Permission Request'),
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFF3B5BDB),
                side: const BorderSide(color: Color(0xFF3B5BDB)),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),
          ),
          if (onResubmit != null) ...[
            const SizedBox(height: 8),
            _ActionButton(label: 'Resubmit Permission Request', icon: Icons.send_outlined, onPressed: onResubmit!),
          ],
        ],
      ),
    );
  }
}

class _StageTrackerRow extends StatelessWidget {
  final StageModel stage;
  const _StageTrackerRow({required this.stage});

  @override
  Widget build(BuildContext context) {
    final isDone = stage.completedAt != null;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: isDone ? const Color(0xFFF0FDF4) : Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: isDone ? const Color(0xFFBBF7D0) : Colors.grey.shade100),
        ),
        child: Row(
          children: [
            Container(
              width: 28, height: 28,
              decoration: BoxDecoration(
                color: isDone ? const Color(0xFF16A34A) : const Color(0xFFEEF2FF),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: isDone
                    ? const Icon(Icons.check, size: 14, color: Colors.white)
                    : Text(stage.stageNumber.toString(), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF3B5BDB))),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(stage.stageName,
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600,
                      color: isDone ? const Color(0xFF16A34A) : const Color(0xFF1A1F36))),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: isDone ? const Color(0xFFDCFCE7) : Colors.grey.shade100,
                borderRadius: BorderRadius.circular(5),
              ),
              child: Text(stage.status,
                  style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600,
                      color: isDone ? const Color(0xFF16A34A) : Colors.grey.shade500)),
            ),
          ],
        ),
      ),
    );
  }
}