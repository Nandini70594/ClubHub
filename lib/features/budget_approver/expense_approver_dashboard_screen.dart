import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/event_expense_model.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/app_scaffold.dart';
import '../approver/expense_review_screen.dart';

class ExpenseApproverDashboardScreen extends ConsumerStatefulWidget {
  const ExpenseApproverDashboardScreen({super.key});

  @override
  ConsumerState<ExpenseApproverDashboardScreen> createState() =>
      _ExpenseApproverDashboardScreenState();
}

class _ExpenseApproverDashboardScreenState
    extends ConsumerState<ExpenseApproverDashboardScreen>
    with SingleTickerProviderStateMixin {
  int _reloadKey = 0;
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _refresh() async {
    setState(() => _reloadKey++);
  }

  String _formatDateTime(String? dateTimeStr) {
    if (dateTimeStr == null || dateTimeStr.isEmpty) return '';

    final dt = DateTime.parse(dateTimeStr).toLocal();
    final hour = dt.hour % 12 == 0 ? 12 : dt.hour % 12;
    final minute = dt.minute.toString().padLeft(2, '0');
    final amPm = dt.hour >= 12 ? 'PM' : 'AM';

    return '${dt.day}/${dt.month}/${dt.year} • $hour:$minute $amPm';
  }

  Future<void> _viewExpenseFiles(EventExpenseModel expense) async {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ExpenseReviewScreen(expense: expense),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final postEventService = ref.read(postEventServiceProvider);

    final pendingFuture = postEventService.getPendingExpenses();
    final reviewedFuture =
        postEventService.getReviewedExpensesForCurrentApprover();

    return AppScaffold(
      title: 'Post Event Budget Proof',
      currentRoute: '/budget-approver/expenses',
      child: Column(
        children: [
          Container(
            color: Colors.white,
            child: TabBar(
              controller: _tabController,
              labelColor: const Color(0xFF3B5BDB),
              unselectedLabelColor: const Color(0xFF6B7280),
              indicatorColor: const Color(0xFF3B5BDB),
              indicatorWeight: 3,
              labelStyle: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
              tabs: const [
                Tab(text: 'Pending'),
                Tab(text: 'Reviewed'),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                FutureBuilder<List<EventExpenseModel>>(
                  key: ValueKey('expense_pending_$_reloadKey'),
                  future: pendingFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(
                        child: CircularProgressIndicator(color: Color(0xFF3B5BDB)),
                      );
                    }
                    if (snapshot.hasError) {
                      return Center(child: Text('Error: ${snapshot.error}'));
                    }
                    final expenses = snapshot.data ?? [];
                    if (expenses.isEmpty) {
                      return _emptyState('No pending expenses');
                    }
                    return RefreshIndicator(
                      onRefresh: _refresh,
                      color: const Color(0xFF3B5BDB),
                      child: ListView.builder(
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        itemCount: expenses.length,
                        itemBuilder: (context, index) =>
                            _pendingExpenseCard(expenses[index], context),
                ),
              );
            },
          ),

          FutureBuilder<List<EventExpenseModel>>(
            key: ValueKey('expense_reviewed_$_reloadKey'),
            future: reviewedFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(color: Color(0xFF3B5BDB)),
                );
              }
              if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              }
              final expenses = snapshot.data ?? [];
              if (expenses.isEmpty) {
                return _emptyState('No reviewed expenses');
              }
              return RefreshIndicator(
                onRefresh: _refresh,
                color: const Color(0xFF3B5BDB),
                child: ListView.builder(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  itemCount: expenses.length,
                  itemBuilder: (context, index) =>
                      _reviewedExpenseCard(expenses[index], context),
                ),
              );
            },
          ),
        ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _emptyState(String message) {
    return RefreshIndicator(
      onRefresh: _refresh,
      color: const Color(0xFF3B5BDB),
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          const SizedBox(height: 80),
          Center(
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: const Color(0xFF3B5BDB).withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.receipt_long_outlined,
                    size: 40,
                    color: Color(0xFF3B5BDB),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  message,
                  style: const TextStyle(
                    color: Color(0xFF6B7280),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _pendingExpenseCard(EventExpenseModel expense, BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () async {
          final changed = await Navigator.push<bool>(
            context,
            MaterialPageRoute(
              builder: (_) => ExpenseReviewScreen(expense: expense),
            ),
          );
          if (changed == true) await _refresh();
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF3B5BDB), Color(0xFF7091E6)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.receipt_long_outlined,
                  color: Colors.white,
                  size: 22,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            '₹${expense.actualAmount}',
                            style: const TextStyle(
                              color: Color(0xFF1A1F36),
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                          ),
                        ),
                        IconButton(
                          onPressed: () => _viewExpenseFiles(expense),
                          icon: const Icon(
                            Icons.visibility,
                            color: Color(0xFF3B5BDB),
                            size: 20,
                          ),
                          tooltip: 'View Expense Files',
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        _statusBadge(expense.status),
                        const SizedBox(width: 8),
                        if (expense.clubName != null)
                          Flexible(
                            child: Text(
                              expense.clubName!,
                              style: const TextStyle(
                                color: Color(0xFF6B7280),
                                fontSize: 12,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          )
                        else
                          const Text(
                            'Event Expense',
                            style: TextStyle(
                              color: Color(0xFF6B7280),
                              fontSize: 12,
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              const Icon(
                Icons.chevron_right_rounded,
                color: Color(0xFF3B5BDB),
                size: 22,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _reviewedExpenseCard(EventExpenseModel expense, BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ExpenseReviewScreen(expense: expense),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: const Color(0xFF3B5BDB).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.task_alt_outlined,
                  color: Color(0xFF3B5BDB),
                  size: 22,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            '₹${expense.actualAmount}',
                            style: const TextStyle(
                              color: Color(0xFF1A1F36),
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                          ),
                        ),
                        IconButton(
                          onPressed: () => _viewExpenseFiles(expense),
                          icon: const Icon(
                            Icons.visibility,
                            color: Color(0xFF3B5BDB),
                            size: 20,
                          ),
                          tooltip: 'View Expense Files',
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        _statusBadge(expense.status),
                        const SizedBox(width: 8),
                        if (expense.clubName != null)
                          Flexible(
                            child: Text(
                              expense.clubName!,
                              style: const TextStyle(
                                color: Color(0xFF6B7280),
                                fontSize: 12,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          )
                        else
                          const Text(
                            'No club',
                            style: TextStyle(
                              color: Color(0xFF6B7280),
                              fontSize: 12,
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              if (expense.approvedAt != null)
                Text(
                  _formatDateTime(expense.approvedAt),
                  style: const TextStyle(
                    color: Color(0xFF6B7280),
                    fontSize: 11,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _statusBadge(String status) {
    Color bg, fg;
    switch (status.toLowerCase()) {
      case 'approved':
        bg = const Color(0xFF10B981).withOpacity(0.12);
        fg = const Color(0xFF10B981);
        break;
      case 'rejected':
        bg = const Color(0xFFEF4444).withOpacity(0.12);
        fg = const Color(0xFFEF4444);
        break;
      case 'changes_requested':
      case 'changes requested':
        bg = const Color(0xFF6366F1).withOpacity(0.12);
        fg = const Color(0xFF6366F1);
        break;
      default:
        bg = const Color(0xFFF59E0B).withOpacity(0.12);
        fg = const Color(0xFFF59E0B);
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status.toUpperCase(),
        style: TextStyle(
          color: fg,
          fontSize: 10,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.4,
        ),
      ),
    );
  }
}