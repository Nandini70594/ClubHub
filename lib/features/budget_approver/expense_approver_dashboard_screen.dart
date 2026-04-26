// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';

// import '../../models/event_expense_model.dart';
// import '../../providers/auth_provider.dart';
// import '../approver/expense_review_screen.dart';

// class ExpenseApproverDashboardScreen extends ConsumerStatefulWidget {
//   const ExpenseApproverDashboardScreen({super.key});

//   @override
//   ConsumerState<ExpenseApproverDashboardScreen> createState() =>
//       _ExpenseApproverDashboardScreenState();
// }

// class _ExpenseApproverDashboardScreenState
//     extends ConsumerState<ExpenseApproverDashboardScreen> {
//   int _reloadKey = 0;

//   Future<void> _refresh() async {
//     setState(() {
//       _reloadKey++;
//     });
//   }

//   String _formatDateTime(String? dateTimeStr) {
//     if (dateTimeStr == null || dateTimeStr.isEmpty) return '';

//     final dt = DateTime.parse(dateTimeStr).toLocal();
//     final hour = dt.hour % 12 == 0 ? 12 : dt.hour % 12;
//     final minute = dt.minute.toString().padLeft(2, '0');
//     final amPm = dt.hour >= 12 ? 'PM' : 'AM';

//     return '${dt.day}/${dt.month}/${dt.year} • $hour:$minute $amPm';
//   }

//   @override
//   Widget build(BuildContext context) {
//     final postEventService = ref.read(postEventServiceProvider);

//     final pendingFuture = postEventService.getPendingExpenses();
//     final reviewedFuture =
//         postEventService.getReviewedExpensesForCurrentApprover();

//     return DefaultTabController(
//       length: 2,
//       child: Scaffold(
//         appBar: AppBar(
//           title: const Text('Post Event Budget Proof Approval'),
//           bottom: const TabBar(
//             tabs: [
//               Tab(text: 'Pending'),
//               Tab(text: 'Reviewed'),
//             ],
//           ),
//         ),
//         body: TabBarView(
//           children: [
//             FutureBuilder<List<EventExpenseModel>>(
//               key: ValueKey('expense_pending_$_reloadKey'),
//               future: pendingFuture,
//               builder: (context, snapshot) {
//                 if (snapshot.connectionState == ConnectionState.waiting) {
//                   return const Center(child: CircularProgressIndicator());
//                 }

//                 if (snapshot.hasError) {
//                   return Center(child: Text('Error: ${snapshot.error}'));
//                 }

//                 final expenses = snapshot.data ?? [];

//                 if (expenses.isEmpty) {
//                   return RefreshIndicator(
//                     onRefresh: _refresh,
//                     child: ListView(
//                       physics: const AlwaysScrollableScrollPhysics(),
//                       children: const [
//                         SizedBox(height: 200),
//                         Center(child: Text('No pending expense proofs')),
//                       ],
//                     ),
//                   );
//                 }

//                 return RefreshIndicator(
//                   onRefresh: _refresh,
//                   child: ListView.builder(
//                     physics: const AlwaysScrollableScrollPhysics(),
//                     itemCount: expenses.length,
//                     itemBuilder: (context, index) {
//                       final expense = expenses[index];

//                       return Card(
//                         margin: const EdgeInsets.all(12),
//                         child: ListTile(
//                           onTap: () async {
//                             final changed = await Navigator.push<bool>(
//                               context,
//                               MaterialPageRoute(
//                                 builder: (_) =>
//                                     ExpenseReviewScreen(expense: expense),
//                               ),
//                             );

//                             if (changed == true) {
//                               await _refresh();
//                             }
//                           },
//                           title: Text('₹${expense.actualAmount}'),
//                           subtitle: Text(
//                             '${expense.status} • ${expense.summaryNote ?? '-'}',
//                           ),
//                           trailing:
//                               const Icon(Icons.arrow_forward_ios, size: 16),
//                         ),
//                       );
//                     },
//                   ),
//                 );
//               },
//             ),
//             FutureBuilder<List<EventExpenseModel>>(
//               key: ValueKey('expense_reviewed_$_reloadKey'),
//               future: reviewedFuture,
//               builder: (context, snapshot) {
//                 if (snapshot.connectionState == ConnectionState.waiting) {
//                   return const Center(child: CircularProgressIndicator());
//                 }

//                 if (snapshot.hasError) {
//                   return Center(child: Text('Error: ${snapshot.error}'));
//                 }

//                 final expenses = snapshot.data ?? [];

//                 if (expenses.isEmpty) {
//                   return RefreshIndicator(
//                     onRefresh: _refresh,
//                     child: ListView(
//                       physics: const AlwaysScrollableScrollPhysics(),
//                       children: const [
//                         SizedBox(height: 200),
//                         Center(child: Text('No reviewed expense proofs')),
//                       ],
//                     ),
//                   );
//                 }

//                 return RefreshIndicator(
//                   onRefresh: _refresh,
//                   child: ListView.builder(
//                     physics: const AlwaysScrollableScrollPhysics(),
//                     itemCount: expenses.length,
//                     itemBuilder: (context, index) {
//                       final expense = expenses[index];

//                       return Card(
//                         margin: const EdgeInsets.all(12),
//                         child: ListTile(
//                           onTap: () async {
//                             await Navigator.push(
//                               context,
//                               MaterialPageRoute(
//                                 builder: (_) =>
//                                     ExpenseReviewScreen(expense: expense),
//                               ),
//                             );
//                           },
//                           title: Text('₹${expense.actualAmount}'),
//                           subtitle: Text(
//                             '${expense.status} • ${expense.remarks ?? '-'}',
//                           ),
//                           trailing: Text(
//                             _formatDateTime(expense.approvedAt),
//                             style: const TextStyle(fontSize: 11),
//                           ),
//                         ),
//                       );
//                     },
//                   ),
//                 );
//               },
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }


import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/event_expense_model.dart';
import '../../providers/auth_provider.dart';
import '../approver/expense_review_screen.dart';

class ExpenseApproverDashboardScreen extends ConsumerStatefulWidget {
  const ExpenseApproverDashboardScreen({super.key});

  @override
  ConsumerState<ExpenseApproverDashboardScreen> createState() =>
      _ExpenseApproverDashboardScreenState();
}

class _ExpenseApproverDashboardScreenState
    extends ConsumerState<ExpenseApproverDashboardScreen> {
  int _reloadKey = 0;

  Future<void> _refresh() async {
    setState(() { _reloadKey++; });
  }

  String _formatDateTime(String? dateTimeStr) {
    if (dateTimeStr == null || dateTimeStr.isEmpty) return '';
    final dt = DateTime.parse(dateTimeStr).toLocal();
    final hour = dt.hour % 12 == 0 ? 12 : dt.hour % 12;
    final minute = dt.minute.toString().padLeft(2, '0');
    final amPm = dt.hour >= 12 ? 'PM' : 'AM';
    return '${dt.day}/${dt.month}/${dt.year} • $hour:$minute $amPm';
  }

  @override
  Widget build(BuildContext context) {
    final postEventService = ref.read(postEventServiceProvider);
    final pendingFuture = postEventService.getPendingExpenses();
    final reviewedFuture = postEventService.getReviewedExpensesForCurrentApprover();

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: const Color(0xFFF4F6FB),
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          surfaceTintColor: Colors.transparent,
          title: const Text(
            'Post Event Budget Proof',
            style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: Color(0xFF1A1F36)),
          ),
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(49),
            child: Column(
              children: [
                Divider(height: 1, color: Colors.grey.shade200),
                TabBar(
                  labelColor: const Color(0xFF0891B2),
                  unselectedLabelColor: Colors.grey.shade500,
                  labelStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                  unselectedLabelStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w400),
                  indicatorColor: const Color(0xFF0891B2),
                  indicatorWeight: 2.5,
                  tabs: const [Tab(text: 'Pending'), Tab(text: 'Reviewed')],
                ),
              ],
            ),
          ),
        ),
        body: TabBarView(
          children: [
            // Pending
            FutureBuilder<List<EventExpenseModel>>(
              key: ValueKey('expense_pending_$_reloadKey'),
              future: pendingFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator(color: Color(0xFF0891B2)));
                }
                if (snapshot.hasError) {
                  return Center(child: Padding(padding: const EdgeInsets.all(24), child: Text('Error: ${snapshot.error}', style: const TextStyle(color: Color(0xFFDC2626), fontSize: 13))));
                }
                final expenses = snapshot.data ?? [];
                if (expenses.isEmpty) {
                  return RefreshIndicator(
                    color: const Color(0xFF0891B2),
                    onRefresh: _refresh,
                    child: ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      children: [
                        const SizedBox(height: 120),
                        Icon(Icons.inbox_outlined, size: 48, color: Colors.grey.shade300),
                        const SizedBox(height: 12),
                        Center(child: Text('No pending expense proofs', style: TextStyle(fontSize: 14, color: Colors.grey.shade400))),
                      ],
                    ),
                  );
                }
                return RefreshIndicator(
                  color: const Color(0xFF0891B2),
                  onRefresh: _refresh,
                  child: ListView.builder(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(16),
                    itemCount: expenses.length,
                    itemBuilder: (context, index) {
                      final expense = expenses[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: Material(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          child: InkWell(
                            onTap: () async {
                              final changed = await Navigator.push<bool>(
                                context,
                                MaterialPageRoute(builder: (_) => ExpenseReviewScreen(expense: expense)),
                              );
                              if (changed == true) await _refresh();
                            },
                            borderRadius: BorderRadius.circular(12),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Colors.grey.shade100),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    width: 44, height: 44,
                                    decoration: BoxDecoration(color: const Color(0xFFE0F7FA), borderRadius: BorderRadius.circular(10)),
                                    child: const Icon(Icons.receipt_long_outlined, color: Color(0xFF0891B2), size: 20),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text('₹${expense.actualAmount}', style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: Color(0xFF1A1F36))),
                                        const SizedBox(height: 3),
                                        Text(expense.summaryNote ?? '-', style: TextStyle(fontSize: 12, color: Colors.grey.shade500), maxLines: 1, overflow: TextOverflow.ellipsis),
                                      ],
                                    ),
                                  ),
                                  _StatusChip(status: expense.status),
                                  const SizedBox(width: 8),
                                  Icon(Icons.arrow_forward_ios, size: 13, color: Colors.grey.shade400),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
            // Reviewed
            FutureBuilder<List<EventExpenseModel>>(
              key: ValueKey('expense_reviewed_$_reloadKey'),
              future: reviewedFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator(color: Color(0xFF0891B2)));
                }
                if (snapshot.hasError) {
                  return Center(child: Padding(padding: const EdgeInsets.all(24), child: Text('Error: ${snapshot.error}', style: const TextStyle(color: Color(0xFFDC2626), fontSize: 13))));
                }
                final expenses = snapshot.data ?? [];
                if (expenses.isEmpty) {
                  return RefreshIndicator(
                    color: const Color(0xFF0891B2),
                    onRefresh: _refresh,
                    child: ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      children: [
                        const SizedBox(height: 120),
                        Icon(Icons.inbox_outlined, size: 48, color: Colors.grey.shade300),
                        const SizedBox(height: 12),
                        Center(child: Text('No reviewed expense proofs', style: TextStyle(fontSize: 14, color: Colors.grey.shade400))),
                      ],
                    ),
                  );
                }
                return RefreshIndicator(
                  color: const Color(0xFF0891B2),
                  onRefresh: _refresh,
                  child: ListView.builder(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(16),
                    itemCount: expenses.length,
                    itemBuilder: (context, index) {
                      final expense = expenses[index];
                      final dateStr = _formatDateTime(expense.approvedAt);
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: Material(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          child: InkWell(
                            onTap: () async {
                              await Navigator.push(
                                context,
                                MaterialPageRoute(builder: (_) => ExpenseReviewScreen(expense: expense)),
                              );
                            },
                            borderRadius: BorderRadius.circular(12),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Colors.grey.shade100),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    width: 44, height: 44,
                                    decoration: BoxDecoration(color: const Color(0xFFF0FDF4), borderRadius: BorderRadius.circular(10)),
                                    child: const Icon(Icons.check_circle_outline, color: Color(0xFF16A34A), size: 20),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text('₹${expense.actualAmount}', style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: Color(0xFF1A1F36))),
                                        const SizedBox(height: 3),
                                        Text(expense.remarks ?? '-', style: TextStyle(fontSize: 12, color: Colors.grey.shade500)),
                                      ],
                                    ),
                                  ),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      _StatusChip(status: expense.status),
                                      if (dateStr.isNotEmpty) ...[
                                        const SizedBox(height: 4),
                                        Text(dateStr, style: TextStyle(fontSize: 10, color: Colors.grey.shade400)),
                                      ],
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  final String status;
  const _StatusChip({required this.status});

  @override
  Widget build(BuildContext context) {
    final s = status.toLowerCase();
    Color bg; Color fg;
    if (s.contains('approved')) { bg = const Color(0xFFF0FDF4); fg = const Color(0xFF16A34A); }
    else if (s.contains('reject')) { bg = const Color(0xFFFEF2F2); fg = const Color(0xFFDC2626); }
    else { bg = const Color(0xFFFFFBEB); fg = const Color(0xFFD97706); }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(6)),
      child: Text(status, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: fg)),
    );
  }
}