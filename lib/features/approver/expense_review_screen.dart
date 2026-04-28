import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../models/event_expense_file_model.dart';
import '../../models/event_expense_model.dart';
import '../../providers/auth_provider.dart';

class ExpenseReviewScreen extends ConsumerStatefulWidget {
  final EventExpenseModel expense;

  const ExpenseReviewScreen({
    super.key,
    required this.expense,
  });

  @override
  ConsumerState<ExpenseReviewScreen> createState() =>
      _ExpenseReviewScreenState();
}

class _ExpenseReviewScreenState extends ConsumerState<ExpenseReviewScreen> {
  bool _loading = false;

  String _label(String type) {
    switch (type) {
      case 'BILL':
        return 'Bills / Receipts';
      case 'INVOICE':
        return 'Invoice';
      case 'CO':
        return 'Comparative Order (CO)';
      case 'PO':
        return 'Purchase Order (PO)';
      case 'OTHER':
        return 'Other Supporting Documents';
      default:
        return type;
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

  Future<void> _approve(String? remarks) async {
    if (remarks == null) return;
    setState(() => _loading = true);

    try {
      await ref.read(postEventServiceProvider).approveExpense(
            expenseId: widget.expense.id,
            eventId: widget.expense.eventId,
            remarks: remarks.isEmpty ? 'Approved' : remarks,
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

  Future<void> _requestChanges(String? remarks) async {
    if (remarks == null) return;
    setState(() => _loading = true);

    try {
      await ref.read(postEventServiceProvider).requestExpenseChanges(
            expenseId: widget.expense.id,
            remarks: remarks.isEmpty ? 'Changes requested' : remarks,
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

  Future<void> _reject(String? remarks) async {
    if (remarks == null) return;
    setState(() => _loading = true);

    try {
      await ref.read(postEventServiceProvider).rejectExpense(
            expenseId: widget.expense.id,
            remarks: remarks.isEmpty ? 'Rejected' : remarks,
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

  @override
  Widget build(BuildContext context) {
    final expense = widget.expense;
    final isPending = expense.status.toLowerCase() == 'pending';
    final postEventService = ref.read(postEventServiceProvider);

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
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 18, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Expense Review',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 18,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: FutureBuilder<List<EventExpenseFileModel>>(
              future: postEventService.getExpenseFiles(expense.id),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(color: Color(0xFF3B5BDB)),
                  );
                }

                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }

                final files = snapshot.data ?? [];

                return SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ── Expense Header Card ────────────────────────────────────
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF3B5BDB), Color(0xFF7091E6)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '₹${expense.actualAmount}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 24,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'Event Expense',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'Event ID: ${expense.eventId.substring(0, 8)}',
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 20),

                      // ── Expense Details Card ───────────────────────────────────
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey.shade200),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Expense Details',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF1A1F36),
                              ),
                            ),
                            const SizedBox(height: 12),
                            if (expense.clubName != null) ...[
                              _infoRow('Club Name', expense.clubName!),
                              const Divider(color: Color(0xFFE5E9F2), height: 12),
                            ],
                            _infoRow('Event ID', expense.eventId.substring(0, 8)),
                            const Divider(color: Color(0xFFE5E9F2), height: 12),
                            _infoRow('Total Amount', '₹${expense.actualAmount}'),
                            const Divider(color: Color(0xFFE5E9F2), height: 12),
                            _infoRow('Status', expense.status),
                            if (expense.approvedAt != null) ...[
                              const Divider(color: Color(0xFFE5E9F2), height: 12),
                              _infoRow('Approved At', _formatDateTime(expense.approvedAt)),
                            ],
                          ],
                        ),
                      ),

                      const SizedBox(height: 20),

                      // ── Supporting Files Card ─────────────────────────────────
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey.shade200),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Text(
                                  'Supporting Files',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFF1A1F36),
                                  ),
                                ),
                                const Spacer(),
                                if (files.isNotEmpty)
                                  Text(
                                    '${files.length} file${files.length > 1 ? 's' : ''}',
                                    style: const TextStyle(
                                      color: Color(0xFF6B7280),
                                      fontSize: 12,
                                    ),
                                  ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            files.isEmpty
                                ? Container(
                                    width: double.infinity,
                                    padding: const EdgeInsets.all(20),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFF4F6FB),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: const Center(
                                      child: Column(
                                        children: [
                                          Icon(
                                            Icons.folder_open_outlined,
                                            color: Color(0xFF6B7280),
                                            size: 32,
                                          ),
                                          SizedBox(height: 8),
                                          Text(
                                            'No supporting files uploaded',
                                            style: TextStyle(
                                              color: Color(0xFF6B7280),
                                              fontSize: 14,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  )
                                : Column(
                                    children: files.map((file) {
                                      return Container(
                                        margin: const EdgeInsets.only(bottom: 8),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFF4F6FB),
                                          borderRadius: BorderRadius.circular(8),
                                          border: Border.all(
                                            color: const Color(0xFFE5E9F2),
                                            width: 1,
                                          ),
                                        ),
                                        child: Padding(
                                          padding: const EdgeInsets.all(12),
                                          child: Row(
                                            children: [
                                              Container(
                                                width: 36,
                                                height: 36,
                                                decoration: BoxDecoration(
                                                  color: const Color(0xFF3B5BDB).withOpacity(0.1),
                                                  borderRadius: BorderRadius.circular(8),
                                                ),
                                                child: const Icon(
                                                  Icons.attach_file,
                                                  color: Color(0xFF3B5BDB),
                                                  size: 18,
                                                ),
                                              ),
                                              const SizedBox(width: 12),
                                              Expanded(
                                                child: Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      _label(file.fileType),
                                                      style: const TextStyle(
                                                        fontSize: 14,
                                                        fontWeight: FontWeight.w600,
                                                        color: Color(0xFF1A1F36),
                                                      ),
                                                    ),
                                                    const SizedBox(height: 2),
                                                    Text(
                                                      file.fileName,
                                                      style: const TextStyle(
                                                        fontSize: 12,
                                                        color: Color(0xFF6B7280),
                                                      ),
                                                      overflow: TextOverflow.ellipsis,
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              const SizedBox(width: 8),
                                              ElevatedButton.icon(
                                                onPressed: () => _openFile(file.storagePath),
                                                icon: const Icon(
                                                  Icons.visibility,
                                                  size: 16,
                                                ),
                                                label: const Text('View'),
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor: const Color(0xFF3B5BDB),
                                                  foregroundColor: Colors.white,
                                                  minimumSize: const Size(70, 32),
                                                  padding: const EdgeInsets.symmetric(
                                                    horizontal: 12,
                                                    vertical: 6,
                                                  ),
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius: BorderRadius.circular(6),
                                                  ),
                                                  elevation: 0,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      );
                                    }).toList(),
                                  ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 20),

                      // ── Action Buttons ───────────────────────────────────────
                      if (isPending)
                        _loading
                            ? const Center(
                                child: CircularProgressIndicator(color: Color(0xFF3B5BDB)),
                              )
                            : Column(
                                children: [
                                  SizedBox(
                                    width: double.infinity,
                                    height: 48,
                                    child: ElevatedButton.icon(
                                      onPressed: () => _showActionDialog('approve'),
                                      icon: const Icon(Icons.check_rounded, size: 18),
                                      label: const Text(
                                        'Approve Expense',
                                        style: TextStyle(
                                          fontWeight: FontWeight.w600,
                                          fontSize: 15,
                                        ),
                                      ),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: const Color(0xFF10B981),
                                        foregroundColor: Colors.white,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(10),
                                        ),
                                        elevation: 0,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  SizedBox(
                                    width: double.infinity,
                                    height: 48,
                                    child: ElevatedButton.icon(
                                      onPressed: () => _showActionDialog('request_changes'),
                                      icon: const Icon(Icons.edit_note_rounded, size: 18),
                                      label: const Text(
                                        'Request Changes',
                                        style: TextStyle(
                                          fontWeight: FontWeight.w600,
                                          fontSize: 15,
                                        ),
                                      ),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: const Color(0xFF6366F1),
                                        foregroundColor: Colors.white,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(10),
                                        ),
                                        elevation: 0,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  SizedBox(
                                    width: double.infinity,
                                    height: 48,
                                    child: OutlinedButton.icon(
                                      onPressed: () => _showActionDialog('reject'),
                                      icon: const Icon(Icons.close_rounded, size: 18),
                                      label: const Text(
                                        'Reject Expense',
                                        style: TextStyle(
                                          fontWeight: FontWeight.w600,
                                          fontSize: 15,
                                        ),
                                      ),
                                      style: OutlinedButton.styleFrom(
                                        foregroundColor: const Color(0xFFEF4444),
                                        side: const BorderSide(color: Color(0xFFEF4444)),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(10),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                    ],
                  ),
                );
              },
            ),
    );
  }

  void _showActionDialog(String action) {
    final controller = TextEditingController();
    final title = action == 'approve'
        ? 'Approve Expense'
        : action == 'request_changes'
            ? 'Request Changes'
            : 'Reject Expense';
    final hintText = action == 'approve'
        ? 'Add approval remarks (optional)'
        : 'Please specify the reason for $action';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: TextField(
          controller: controller,
          maxLines: 3,
          decoration: InputDecoration(
            hintText: hintText,
            border: const OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              switch (action) {
                case 'approve':
                  _approve(controller.text.trim());
                  break;
                case 'request_changes':
                  _requestChanges(controller.text.trim());
                  break;
                case 'reject':
                  _reject(controller.text.trim());
                  break;
              }
            },
            child: const Text('Submit'),
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
                color: Color(0xFF6B7280),
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                color: Color(0xFF1A1F36),
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDateTime(String? dateTimeStr) {
    if (dateTimeStr == null || dateTimeStr.isEmpty) return '';
    final dt = DateTime.parse(dateTimeStr).toLocal();
    final hour = dt.hour % 12 == 0 ? 12 : dt.hour % 12;
    final minute = dt.minute.toString().padLeft(2, '0');
    final amPm = dt.hour >= 12 ? 'PM' : 'AM';
    return '${dt.day}/${dt.month}/${dt.year} • $hour:$minute $amPm';
  }
}
