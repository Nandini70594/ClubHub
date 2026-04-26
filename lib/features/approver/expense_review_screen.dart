// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:url_launcher/url_launcher.dart';

// import '../../models/event_expense_file_model.dart';
// import '../../models/event_expense_model.dart';
// import '../../providers/auth_provider.dart';

// class ExpenseReviewScreen extends ConsumerStatefulWidget {
//   final EventExpenseModel expense;

//   const ExpenseReviewScreen({
//     super.key,
//     required this.expense,
//   });

//   @override
//   ConsumerState<ExpenseReviewScreen> createState() =>
//       _ExpenseReviewScreenState();
// }

// class _ExpenseReviewScreenState extends ConsumerState<ExpenseReviewScreen> {
//   bool _loading = false;

//   String _label(String type) {
//     switch (type) {
//       case 'BILL':
//         return 'Bills / Receipts';
//       case 'INVOICE':
//         return 'Invoice';
//       case 'CO':
//         return 'Comparative Order (CO)';
//       case 'PO':
//         return 'Purchase Order (PO)';
//       case 'OTHER':
//         return 'Other Supporting Documents';
//       default:
//         return type;
//     }
//   }

//   Future<void> _openFile(String storagePath) async {
//     try {
//       final url = await ref
//           .read(storageServiceProvider)
//           .getSignedFileUrl(storagePath);

//       final launched = await launchUrl(
//         Uri.parse(url),
//         mode: LaunchMode.externalApplication,
//       );

//       if (!launched && mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(content: Text('Could not open file')),
//         );
//       }
//     } catch (e) {
//       if (!mounted) return;
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Failed to open file: $e')),
//       );
//     }
//   }

//   Future<String?> _remarksDialog(String title) async {
//     final controller = TextEditingController();

//     return showDialog<String>(
//       context: context,
//       builder: (_) => AlertDialog(
//         title: Text(title),
//         content: TextField(
//           controller: controller,
//           maxLines: 3,
//           decoration: const InputDecoration(
//             hintText: 'Enter remarks',
//             border: OutlineInputBorder(),
//           ),
//         ),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context),
//             child: const Text('Cancel'),
//           ),
//           ElevatedButton(
//             onPressed: () => Navigator.pop(context, controller.text.trim()),
//             child: const Text('Submit'),
//           ),
//         ],
//       ),
//     );
//   }

//   Future<void> _approve() async {
//     final remarks = await _remarksDialog('Approve Expenses');
//     if (remarks == null) return;

//     setState(() => _loading = true);

//     try {
//       await ref.read(postEventServiceProvider).approveExpense(
//             expenseId: widget.expense.id,
//             eventId: widget.expense.eventId,
//             remarks: remarks.isEmpty ? 'Approved' : remarks,
//           );

//       if (!mounted) return;
//       Navigator.pop(context, true);
//     } catch (e) {
//       if (!mounted) return;
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Error: $e')),
//       );
//     } finally {
//       if (mounted) setState(() => _loading = false);
//     }
//   }

//   Future<void> _requestChanges() async {
//     final remarks = await _remarksDialog('Request Changes');
//     if (remarks == null) return;

//     setState(() => _loading = true);

//     try {
//       await ref.read(postEventServiceProvider).requestExpenseChanges(
//             expenseId: widget.expense.id,
//             remarks: remarks.isEmpty ? 'Changes requested' : remarks,
//           );

//       if (!mounted) return;
//       Navigator.pop(context, true);
//     } catch (e) {
//       if (!mounted) return;
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Error: $e')),
//       );
//     } finally {
//       if (mounted) setState(() => _loading = false);
//     }
//   }

//   Future<void> _reject() async {
//     final remarks = await _remarksDialog('Reject Expenses');
//     if (remarks == null) return;

//     setState(() => _loading = true);

//     try {
//       await ref.read(postEventServiceProvider).rejectExpense(
//             expenseId: widget.expense.id,
//             remarks: remarks.isEmpty ? 'Rejected' : remarks,
//           );

//       if (!mounted) return;
//       Navigator.pop(context, true);
//     } catch (e) {
//       if (!mounted) return;
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Error: $e')),
//       );
//     } finally {
//       if (mounted) setState(() => _loading = false);
//     }
//   }

//   Widget _buildGroupedFiles(List<EventExpenseFileModel> files) {
//     if (files.isEmpty) {
//       return const Text('No files uploaded');
//     }

//     final grouped = <String, List<EventExpenseFileModel>>{};

//     for (final file in files) {
//       grouped.putIfAbsent(file.fileType, () => []).add(file);
//     }

//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: grouped.entries.map((entry) {
//         return Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             const SizedBox(height: 12),
//             Text(
//               _label(entry.key),
//               style: const TextStyle(
//                 fontWeight: FontWeight.bold,
//                 fontSize: 16,
//               ),
//             ),
//             const SizedBox(height: 6),
//             ...entry.value.map((file) {
//               return Card(
//                 child: ListTile(
//                   title: Text(file.fileName),
//                   subtitle: Text(file.storagePath),
//                   trailing: TextButton(
//                     onPressed: () => _openFile(file.storagePath),
//                     child: const Text('View'),
//                   ),
//                 ),
//               );
//             }),
//           ],
//         );
//       }).toList(),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     final expense = widget.expense;
//     final postEventService = ref.read(postEventServiceProvider);

//     return Scaffold(
//       appBar: AppBar(title: const Text('Expense Review')),
//       body: FutureBuilder<List<EventExpenseFileModel>>(
//         future: postEventService.getExpenseFiles(expense.id),
//         builder: (context, snapshot) {
//           if (snapshot.connectionState == ConnectionState.waiting) {
//             return const Center(child: CircularProgressIndicator());
//           }

//           if (snapshot.hasError) {
//             return Center(child: Text('Error: ${snapshot.error}'));
//           }

//           final files = snapshot.data ?? [];

//           return SingleChildScrollView(
//             padding: const EdgeInsets.all(16),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Card(
//                   child: Padding(
//                     padding: const EdgeInsets.all(16),
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Text(
//                           'Actual Amount: ₹${expense.actualAmount}',
//                           style: const TextStyle(
//                             fontWeight: FontWeight.bold,
//                           ),
//                         ),
//                         const SizedBox(height: 8),
//                         Text('Status: ${expense.status}'),
//                         const SizedBox(height: 8),
//                         Text('Summary: ${expense.summaryNote ?? '-'}'),
//                         if (expense.remarks != null &&
//                             expense.remarks!.trim().isNotEmpty) ...[
//                           const SizedBox(height: 8),
//                           Text('Remarks: ${expense.remarks}'),
//                         ],
//                       ],
//                     ),
//                   ),
//                 ),
//                 const SizedBox(height: 20),
//                 const Text(
//                   'Uploaded Documents',
//                   style: TextStyle(
//                     fontSize: 18,
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//                 _buildGroupedFiles(files),
//                 const SizedBox(height: 24),
//                 if (expense.status == 'pending') ...[
//                   SizedBox(
//                     width: double.infinity,
//                     child: ElevatedButton(
//                       onPressed: _loading ? null : _approve,
//                       child: Text(_loading ? 'Please wait...' : 'Approve'),
//                     ),
//                   ),
//                   const SizedBox(height: 8),
//                   SizedBox(
//                     width: double.infinity,
//                     child: OutlinedButton(
//                       onPressed: _loading ? null : _requestChanges,
//                       child: const Text('Request Changes'),
//                     ),
//                   ),
//                   const SizedBox(height: 8),
//                   SizedBox(
//                     width: double.infinity,
//                     child: OutlinedButton(
//                       onPressed: _loading ? null : _reject,
//                       child: const Text('Reject'),
//                     ),
//                   ),
//                 ],
//               ],
//             ),
//           );
//         },
//       ),
//     );
//   }
// }


import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../models/event_expense_file_model.dart';
import '../../models/event_expense_model.dart';
import '../../providers/auth_provider.dart';

// ── Design tokens ─────────────────────────────────────────────────────────────
const _kPrimary    = Color(0xFF3B5BDB);
const _kPrimaryBg  = Color(0xFFEEF2FF);
const _kSurface    = Colors.white;
const _kBackground = Color(0xFFF4F6FB);
const _kTextDark   = Color(0xFF1A1F36);
const _kBorder     = Color(0xFFE5E7EB);
const _kRadius     = 12.0;
const _kGreen      = Color(0xFF16A34A);
const _kGreenBg    = Color(0xFFF0FDF4);
const _kRed        = Color(0xFFDC2626);
const _kRedBg      = Color(0xFFFEF2F2);
const _kAmber      = Color(0xFFD97706);
const _kAmberBg    = Color(0xFFFFFBEB);
// ─────────────────────────────────────────────────────────────────────────────

class ExpenseReviewScreen extends ConsumerStatefulWidget {
  final EventExpenseModel expense;

  const ExpenseReviewScreen({super.key, required this.expense});

  @override
  ConsumerState<ExpenseReviewScreen> createState() =>
      _ExpenseReviewScreenState();
}

class _ExpenseReviewScreenState extends ConsumerState<ExpenseReviewScreen> {
  bool _loading = false;

  String _label(String type) {
    switch (type) {
      case 'BILL':    return 'Bills / Receipts';
      case 'INVOICE': return 'Invoice';
      case 'CO':      return 'Comparative Order (CO)';
      case 'PO':      return 'Purchase Order (PO)';
      case 'OTHER':   return 'Other Supporting Documents';
      default:        return type;
    }
  }

  IconData _iconFor(String type) {
    switch (type) {
      case 'BILL':    return Icons.receipt_long_outlined;
      case 'INVOICE': return Icons.description_outlined;
      case 'CO':      return Icons.compare_arrows_outlined;
      case 'PO':      return Icons.shopping_bag_outlined;
      case 'OTHER':   return Icons.folder_outlined;
      default:        return Icons.insert_drive_file_outlined;
    }
  }

  Future<void> _openFile(String storagePath) async {
    try {
      final url = await ref
          .read(storageServiceProvider)
          .getSignedFileUrl(storagePath);
      final launched = await launchUrl(
        Uri.parse(url),
        mode: LaunchMode.externalApplication,
      );
      if (!launched && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not open file')),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Failed to open file: $e')));
    }
  }

  Future<String?> _remarksDialog(String title) async {
    final controller = TextEditingController();

    return showDialog<String>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: _kSurface,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(_kRadius)),
        title: Text(title,
            style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: _kTextDark)),
        content: TextField(
          controller: controller,
          maxLines: 3,
          style: const TextStyle(fontSize: 13, color: _kTextDark),
          decoration: InputDecoration(
            hintText: 'Enter remarks…',
            hintStyle:
                TextStyle(fontSize: 13, color: Colors.grey.shade400),
            filled: true,
            fillColor: _kBackground,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: _kBorder),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: _kBorder),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: _kPrimary),
            ),
          ),
        ),
        actionsPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel',
                style: TextStyle(color: Colors.grey.shade500)),
          ),
          ElevatedButton(
            onPressed: () =>
                Navigator.pop(context, controller.text.trim()),
            style: ElevatedButton.styleFrom(
              backgroundColor: _kPrimary,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('Submit',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }

  Future<void> _approve() async {
    final remarks = await _remarksDialog('Approve Expenses');
    if (remarks == null) return;
    setState(() => _loading = true);
    try {
      await ref.read(postEventServiceProvider).approveExpense(
            expenseId: widget.expense.id,
            eventId:   widget.expense.eventId,
            remarks:   remarks.isEmpty ? 'Approved' : remarks,
          );
      if (!mounted) return;
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _requestChanges() async {
    final remarks = await _remarksDialog('Request Changes');
    if (remarks == null) return;
    setState(() => _loading = true);
    try {
      await ref.read(postEventServiceProvider).requestExpenseChanges(
            expenseId: widget.expense.id,
            remarks:   remarks.isEmpty ? 'Changes requested' : remarks,
          );
      if (!mounted) return;
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _reject() async {
    final remarks = await _remarksDialog('Reject Expenses');
    if (remarks == null) return;
    setState(() => _loading = true);
    try {
      await ref.read(postEventServiceProvider).rejectExpense(
            expenseId: widget.expense.id,
            remarks:   remarks.isEmpty ? 'Rejected' : remarks,
          );
      if (!mounted) return;
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  // ── Grouped file list ──────────────────────────────────────────────────────
  Widget _buildGroupedFiles(List<EventExpenseFileModel> files) {
    if (files.isEmpty) {
      return _SurfaceCard(
        child: Row(
          children: [
            Icon(Icons.folder_off_outlined,
                size: 16, color: Colors.grey.shade300),
            const SizedBox(width: 8),
            Text('No files uploaded',
                style:
                    TextStyle(fontSize: 13, color: Colors.grey.shade400)),
          ],
        ),
      );
    }

    final grouped = <String, List<EventExpenseFileModel>>{};
    for (final file in files) {
      grouped.putIfAbsent(file.fileType, () => []).add(file);
    }

    return Column(
      children: grouped.entries.map((entry) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: _SurfaceCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Group header
                Row(
                  children: [
                    Container(
                      width: 32, height: 32,
                      decoration: BoxDecoration(
                        color: _kPrimaryBg,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(_iconFor(entry.key),
                          color: _kPrimary, size: 16),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      _label(entry.key),
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: _kTextDark,
                      ),
                    ),
                  ],
                ),

                // Files
                ...entry.value.map((file) {
                  return Padding(
                    padding: const EdgeInsets.only(top: 10),
                    child: Column(
                      children: [
                        Divider(height: 1, color: Colors.grey.shade100),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            Icon(Icons.attach_file_outlined,
                                size: 13,
                                color: Colors.grey.shade400),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                file.fileName,
                                style: const TextStyle(
                                    fontSize: 12, color: _kTextDark),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(width: 8),
                            GestureDetector(
                              onTap: () => _openFile(file.storagePath),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 5),
                                decoration: BoxDecoration(
                                  color: _kPrimaryBg,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: const Text('View',
                                    style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600,
                                        color: _kPrimary)),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                }),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final expense = widget.expense;
    final isPending = expense.status.toLowerCase() == 'pending';
    final postEventService = ref.read(postEventServiceProvider);

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
          'Expense Review',
          style: TextStyle(
              fontSize: 17, fontWeight: FontWeight.w700, color: _kTextDark),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Divider(height: 1, color: Colors.grey.shade200),
        ),
      ),
      body: FutureBuilder<List<EventExpenseFileModel>>(
        future: postEventService.getExpenseFiles(expense.id),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
                child: CircularProgressIndicator(color: _kPrimary));
          }
          if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}',
                  style: const TextStyle(color: _kRed)),
            );
          }

          final files = snapshot.data ?? [];

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                // ── Summary card ─────────────────────────────────────
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
                            child: const Icon(Icons.receipt_outlined,
                                color: _kGreen, size: 22),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '₹${expense.actualAmount}',
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w700,
                                    color: _kTextDark,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text('Actual Amount',
                                    style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey.shade500)),
                              ],
                            ),
                          ),
                          _StatusChip(status: expense.status),
                        ],
                      ),
                      const SizedBox(height: 14),
                      Divider(height: 1, color: Colors.grey.shade100),
                      const SizedBox(height: 14),
                      _DetailRow(
                        icon: Icons.sticky_note_2_outlined,
                        label: 'Summary',
                        value: expense.summaryNote ?? '-',
                      ),
                      if (expense.remarks != null &&
                          expense.remarks!.trim().isNotEmpty) ...[
                        const SizedBox(height: 8),
                        _DetailRow(
                          icon: Icons.info_outline,
                          label: 'Remarks',
                          value: expense.remarks!,
                        ),
                      ],
                    ],
                  ),
                ),

                const SizedBox(height: 22),

                // ── Documents ────────────────────────────────────────
                _SectionLabel(label: 'Uploaded Documents'),
                const SizedBox(height: 10),
                _buildGroupedFiles(files),

                // ── Action buttons (pending only) ─────────────────────
                if (isPending) ...[
                  const SizedBox(height: 10),
                  _SectionLabel(label: 'Decision'),
                  const SizedBox(height: 12),

                  _ActionButton(
                    label: 'Approve Expenses',
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
                    label: 'Reject Expenses',
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
          );
        },
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
            style: TextStyle(fontSize: 12, color: Colors.grey.shade500)),
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