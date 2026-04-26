// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:url_launcher/url_launcher.dart';

// import '../../models/budget_model.dart';
// import '../../providers/auth_provider.dart';

// class BudgetReviewScreen extends ConsumerStatefulWidget {
//   final BudgetModel budget;

//   const BudgetReviewScreen({
//     super.key,
//     required this.budget,
//   });

//   @override
//   ConsumerState<BudgetReviewScreen> createState() => _BudgetReviewScreenState();
// }

// class _BudgetReviewScreenState extends ConsumerState<BudgetReviewScreen> {
//   final _remarksController = TextEditingController();
//   bool _loading = false;

//   Future<void> _openFile() async {
//     final storagePath = widget.budget.storagePath;
//     if (storagePath == null || storagePath.isEmpty) {
//       if (!mounted) return;
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('No file available to view.')),
//       );
//       return;
//     }

//     try {
//       final url = await ref
//           .read(storageServiceProvider)
//           .getSignedFileUrl(storagePath);

//       final uri = Uri.parse(url);
//       final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);

//       if (!launched && mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(content: Text('Could not open file.')),
//         );
//       }
//     } catch (e) {
//       if (!mounted) return;
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Error opening file: $e')),
//       );
//     }
//   }

//   Future<void> _approve() async {
//     setState(() => _loading = true);
//     try {
//       await ref.read(eventServiceProvider).approveBudget(
//             budgetId: widget.budget.id,
//             eventId: widget.budget.eventId,
//             remarks: _remarksController.text.trim(),
//           );
//       if (!mounted) return;
//       Navigator.pop(context, true);
//     } catch (e) {
//       if (!mounted) return;
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text(e.toString())),
//       );
//     } finally {
//       if (mounted) setState(() => _loading = false);
//     }
//   }

//   Future<void> _requestChanges() async {
//     setState(() => _loading = true);
//     try {
//       await ref.read(eventServiceProvider).requestBudgetChanges(
//             budgetId: widget.budget.id,
//             eventId: widget.budget.eventId,
//             remarks: _remarksController.text.trim(),
//           );
//       if (!mounted) return;
//       Navigator.pop(context, true);
//     } catch (e) {
//       if (!mounted) return;
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text(e.toString())),
//       );
//     } finally {
//       if (mounted) setState(() => _loading = false);
//     }
//   }

//   Future<void> _reject() async {
//     setState(() => _loading = true);
//     try {
//       await ref.read(eventServiceProvider).rejectBudget(
//             budgetId: widget.budget.id,
//             eventId: widget.budget.eventId,
//             remarks: _remarksController.text.trim(),
//           );
//       if (!mounted) return;
//       Navigator.pop(context, true);
//     } catch (e) {
//       if (!mounted) return;
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text(e.toString())),
//       );
//     } finally {
//       if (mounted) setState(() => _loading = false);
//     }
//   }

//   @override
//   void dispose() {
//     _remarksController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     final budget = widget.budget;

//     return Scaffold(
//       appBar: AppBar(title: const Text('Budget Review')),
//       body: Padding(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           children: [
//             Align(
//               alignment: Alignment.centerLeft,
//               child: Text(
//                 'Total Requested: ₹${budget.totalRequested}',
//                 style: const TextStyle(
//                   fontSize: 18,
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),
//             ),
//             const SizedBox(height: 12),
//             Align(
//               alignment: Alignment.centerLeft,
//               child: Text('Status: ${budget.status}'),
//             ),
//             const SizedBox(height: 12),
//             Align(
//               alignment: Alignment.centerLeft,
//               child: Text('Note: ${budget.summaryNote ?? '-'}'),
//             ),
//             const SizedBox(height: 12),
//             Align(
//               alignment: Alignment.centerLeft,
//               child: Text(
//                 'Approval Number: ${budget.approvalNumber ?? 'Not generated yet'}',
//               ),
//             ),
//             const SizedBox(height: 12),
//             Align(
//               alignment: Alignment.centerLeft,
//               child: budget.fileName != null
//                   ? Row(
//                       children: [
//                         Expanded(
//                           child: Text('File: ${budget.fileName}'),
//                         ),
//                         TextButton(
//                           onPressed: _openFile,
//                           child: const Text('View File'),
//                         ),
//                       ],
//                     )
//                   : const Text('File: No file uploaded'),
//             ),
//             const SizedBox(height: 20),
//             if (budget.status == 'pending')
//               TextField(
//                 controller: _remarksController,
//                 maxLines: 3,
//                 decoration: const InputDecoration(
//                   labelText: 'Remarks',
//                   border: OutlineInputBorder(),
//                 ),
//               ),
//             const SizedBox(height: 20),
//             if (budget.status == 'pending') ...[
//               SizedBox(
//                 width: double.infinity,
//                 child: ElevatedButton(
//                   onPressed: _loading ? null : _approve,
//                   child: const Text('Approve Budget'),
//                 ),
//               ),
//               const SizedBox(height: 10),
//               SizedBox(
//                 width: double.infinity,
//                 child: ElevatedButton(
//                   onPressed: _loading ? null : _requestChanges,
//                   child: const Text('Request Budget Changes'),
//                 ),
//               ),
//               const SizedBox(height: 10),
//               SizedBox(
//                 width: double.infinity,
//                 child: ElevatedButton(
//                   onPressed: _loading ? null : _reject,
//                   child: const Text('Reject Budget'),
//                 ),
//               ),
//             ],
//           ],
//         ),
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../models/budget_model.dart';
import '../../providers/auth_provider.dart';

// ── Design tokens ─────────────────────────────────────────────────────────────
const _kPrimary    = Color(0xFF3B5BDB);
const _kPrimaryBg  = Color(0xFFEEF2FF);
const _kSurface    = Colors.white;
const _kBackground = Color(0xFFF4F6FB);
const _kTextDark   = Color(0xFF1A1F36);
const _kTextMid    = Color(0xFF6B7280);
const _kBorder     = Color(0xFFE5E7EB);
const _kRadius     = 12.0;
const _kGreen      = Color(0xFF16A34A);
const _kGreenBg    = Color(0xFFF0FDF4);
const _kRed        = Color(0xFFDC2626);
const _kRedBg      = Color(0xFFFEF2F2);
const _kAmber      = Color(0xFFD97706);
const _kAmberBg    = Color(0xFFFFFBEB);
// ─────────────────────────────────────────────────────────────────────────────

class BudgetReviewScreen extends ConsumerStatefulWidget {
  final BudgetModel budget;

  const BudgetReviewScreen({super.key, required this.budget});

  @override
  ConsumerState<BudgetReviewScreen> createState() => _BudgetReviewScreenState();
}

class _BudgetReviewScreenState extends ConsumerState<BudgetReviewScreen> {
  final _remarksController = TextEditingController();
  bool _loading = false;

  @override
  void dispose() {
    _remarksController.dispose();
    super.dispose();
  }

  Future<void> _openFile() async {
    final storagePath = widget.budget.storagePath;
    if (storagePath == null || storagePath.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No file available to view.')),
      );
      return;
    }
    try {
      final url = await ref
          .read(storageServiceProvider)
          .getSignedFileUrl(storagePath);
      final launched =
          await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
      if (!launched && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not open file.')),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error opening file: $e')),
      );
    }
  }

  Future<void> _approve() async {
    setState(() => _loading = true);
    try {
      await ref.read(eventServiceProvider).approveBudget(
            budgetId: widget.budget.id,
            eventId:  widget.budget.eventId,
            remarks:  _remarksController.text.trim(),
          );
      if (!mounted) return;
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(e.toString())));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _requestChanges() async {
    setState(() => _loading = true);
    try {
      await ref.read(eventServiceProvider).requestBudgetChanges(
            budgetId: widget.budget.id,
            eventId:  widget.budget.eventId,
            remarks:  _remarksController.text.trim(),
          );
      if (!mounted) return;
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(e.toString())));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _reject() async {
    setState(() => _loading = true);
    try {
      await ref.read(eventServiceProvider).rejectBudget(
            budgetId: widget.budget.id,
            eventId:  widget.budget.eventId,
            remarks:  _remarksController.text.trim(),
          );
      if (!mounted) return;
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(e.toString())));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final budget = widget.budget;
    final isPending = budget.status.toLowerCase() == 'pending';

    return Scaffold(
      backgroundColor: _kBackground,
      appBar: AppBar(
        backgroundColor: _kSurface,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new,
              size: 18, color: _kTextDark),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Budget Review',
          style: TextStyle(
              fontSize: 17, fontWeight: FontWeight.w700, color: _kTextDark),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Divider(height: 1, color: Colors.grey.shade200),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // ── Summary card ───────────────────────────────────────────
            _SurfaceCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 44, height: 44,
                        decoration: BoxDecoration(
                          color: _kGreenBg,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(
                            Icons.account_balance_wallet_outlined,
                            color: _kGreen, size: 22),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '₹${budget.totalRequested}',
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w700,
                                color: _kTextDark,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text('Total Requested',
                                style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey.shade500)),
                          ],
                        ),
                      ),
                      _StatusChip(status: budget.status),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Divider(height: 1, color: Colors.grey.shade100),
                  const SizedBox(height: 14),

                  _DetailRow(
                    icon: Icons.sticky_note_2_outlined,
                    label: 'Note',
                    value: budget.summaryNote ?? '-',
                  ),
                  const SizedBox(height: 8),
                  _DetailRow(
                    icon: Icons.tag_outlined,
                    label: 'Approval No.',
                    value: budget.approvalNumber ?? 'Not generated yet',
                  ),

                  // File row
                  if (budget.fileName != null) ...[
                    const SizedBox(height: 12),
                    Divider(height: 1, color: Colors.grey.shade100),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Icon(Icons.attach_file_outlined,
                            size: 14, color: Colors.grey.shade400),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            budget.fileName!,
                            style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: _kTextDark),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        GestureDetector(
                          onTap: _openFile,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: _kPrimaryBg,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Text('View File',
                                style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: _kPrimary)),
                          ),
                        ),
                      ],
                    ),
                  ] else ...[
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(Icons.insert_drive_file_outlined,
                            size: 14, color: Colors.grey.shade300),
                        const SizedBox(width: 6),
                        Text('No file uploaded',
                            style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey.shade400)),
                      ],
                    ),
                  ],
                ],
              ),
            ),

            // ── Remarks field (pending only) ───────────────────────────
            if (isPending) ...[
              const SizedBox(height: 22),
              _SectionLabel(label: 'Remarks'),
              const SizedBox(height: 10),
              _SurfaceCard(
                child: TextField(
                  controller: _remarksController,
                  maxLines: 3,
                  style: const TextStyle(fontSize: 13, color: _kTextDark),
                  decoration: InputDecoration(
                    hintText: 'Add your remarks here…',
                    hintStyle: TextStyle(
                        fontSize: 13, color: Colors.grey.shade400),
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
              ),

              // ── Action buttons ─────────────────────────────────────
              const SizedBox(height: 22),
              _SectionLabel(label: 'Decision'),
              const SizedBox(height: 12),

              _ActionButton(
                label: 'Approve Budget',
                icon: Icons.check_circle_outline,
                color: _kGreen,
                bgColor: _kGreenBg,
                loading: _loading,
                onTap: _approve,
              ),
              const SizedBox(height: 10),
              _ActionButton(
                label: 'Request Changes',
                icon: Icons.edit_note_outlined,
                color: _kAmber,
                bgColor: _kAmberBg,
                loading: _loading,
                onTap: _requestChanges,
              ),
              const SizedBox(height: 10),
              _ActionButton(
                label: 'Reject Budget',
                icon: Icons.cancel_outlined,
                color: _kRed,
                bgColor: _kRedBg,
                loading: _loading,
                onTap: _reject,
              ),
            ],

            const SizedBox(height: 28),
          ],
        ),
      ),
    );
  }
}

// ── Shared widgets ────────────────────────────────────────────────────────────
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
  const _DetailRow(
      {required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 14, color: Colors.grey.shade400),
        const SizedBox(width: 6),
        Text('$label: ',
            style:
                TextStyle(fontSize: 12, color: Colors.grey.shade500)),
        Expanded(
          child: Text(value,
              style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: _kTextDark)),
        ),
      ],
    );
  }
}

class _StatusChip extends StatelessWidget {
  final String status;
  const _StatusChip({required this.status});

  @override
  Widget build(BuildContext context) {
    final s = status.toLowerCase();
    Color bg, fg;
    if (s.contains('approved') || s.contains('approve')) {
      bg = _kGreenBg; fg = _kGreen;
    } else if (s.contains('reject')) {
      bg = _kRedBg; fg = _kRed;
    } else if (s.contains('change')) {
      bg = _kAmberBg; fg = _kAmber;
    } else {
      bg = _kPrimaryBg; fg = _kPrimary;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration:
          BoxDecoration(color: bg, borderRadius: BorderRadius.circular(6)),
      child: Text(status,
          style: TextStyle(
              fontSize: 11, fontWeight: FontWeight.w600, color: fg)),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final Color bgColor;
  final bool loading;
  final VoidCallback onTap;

  const _ActionButton({
    required this.label,
    required this.icon,
    required this.color,
    required this.bgColor,
    required this.loading,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: ElevatedButton.icon(
        onPressed: loading ? null : onTap,
        icon: loading
            ? SizedBox(
                width: 16, height: 16,
                child: CircularProgressIndicator(
                    color: color, strokeWidth: 2),
              )
            : Icon(icon, size: 18),
        label: Text(label,
            style: const TextStyle(
                fontSize: 13, fontWeight: FontWeight.w600)),
        style: ElevatedButton.styleFrom(
          backgroundColor: bgColor,
          foregroundColor: color,
          disabledBackgroundColor: bgColor.withOpacity(0.5),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(_kRadius),
            side: BorderSide(color: color.withOpacity(0.3)),
          ),
        ),
      ),
    );
  }
}