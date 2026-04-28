import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../models/budget_model.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/app_scaffold.dart';
import '../approver/budget_review_screen.dart';

class BudgetApproverDashboardScreen extends ConsumerStatefulWidget {
  const BudgetApproverDashboardScreen({super.key});

  @override
  ConsumerState<BudgetApproverDashboardScreen> createState() =>
      _BudgetApproverDashboardScreenState();
}

class _BudgetApproverDashboardScreenState
    extends ConsumerState<BudgetApproverDashboardScreen>
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

  Future<void> _openBudgetFile(BudgetModel budget) async {
    final storagePath = budget.storagePath;
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

      final uri = Uri.parse(url);
      final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);

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

  @override
  Widget build(BuildContext context) {
    final pendingFuture = ref.read(eventServiceProvider).getPendingBudgets();
    final reviewedFuture =
        ref.read(eventServiceProvider).getReviewedBudgetsForCurrentApprover();

    return AppScaffold(
      title: 'Budget Approver',
      currentRoute: '/budget-approver',
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
            FutureBuilder<List<BudgetModel>>(
              key: ValueKey('budget_pending_$_reloadKey'),
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
                final budgets = snapshot.data ?? [];
                if (budgets.isEmpty) {
                  return _emptyState('No pending budgets');
                }
                return RefreshIndicator(
                  onRefresh: _refresh,
                  color: const Color(0xFF3B5BDB),
                  child: ListView.builder(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    itemCount: budgets.length,
                    itemBuilder: (context, index) =>
                        _pendingBudgetCard(budgets[index], context),
                  ),
                );
              },
            ),

            // ── Reviewed Tab ──
            FutureBuilder<List<BudgetModel>>(
              key: ValueKey('budget_reviewed_$_reloadKey'),
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
                final budgets = snapshot.data ?? [];
                if (budgets.isEmpty) {
                  return _emptyState('No reviewed budgets');
                }
                return RefreshIndicator(
                  onRefresh: _refresh,
                  color: const Color(0xFF3B5BDB),
                  child: ListView.builder(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    itemCount: budgets.length,
                    itemBuilder: (context, index) =>
                        _reviewedBudgetCard(budgets[index], context),
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
                    Icons.account_balance_wallet_outlined,
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

  Widget _pendingBudgetCard(BudgetModel budget, BuildContext context) {
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
              builder: (_) => BudgetReviewScreen(budget: budget),
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
                  Icons.account_balance_wallet_outlined,
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
                            '₹${budget.totalRequested}',
                            style: const TextStyle(
                              color: Color(0xFF1A1F36),
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                          ),
                        ),
                        if (budget.storagePath != null || budget.fileName != null)
                          IconButton(
                            onPressed: () => _openBudgetFile(budget),
                            icon: const Icon(
                              Icons.visibility,
                              color: Color(0xFF3B5BDB),
                              size: 20,
                            ),
                            tooltip: 'View Budget File',
                          ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        _statusBadge(budget.status),
                        const SizedBox(width: 8),
                        if (budget.clubName != null)
                          Flexible(
                            child: Text(
                              budget.clubName!,
                              style: const TextStyle(
                                color: Color(0xFF6B7280),
                                fontSize: 12,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          )
                        else
                          const Text(
                            'Budget File',
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

  Widget _reviewedBudgetCard(BudgetModel budget, BuildContext context) {
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
              builder: (_) => BudgetReviewScreen(budget: budget),
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
                            '₹${budget.totalRequested}',
                            style: const TextStyle(
                              color: Color(0xFF1A1F36),
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                          ),
                        ),
                        if (budget.storagePath != null || budget.fileName != null)
                          IconButton(
                            onPressed: () => _openBudgetFile(budget),
                            icon: const Icon(
                              Icons.visibility,
                              color: Color(0xFF3B5BDB),
                              size: 20,
                            ),
                            tooltip: 'View Budget File',
                          ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        _statusBadge(budget.status),
                        const SizedBox(width: 8),
                        if (budget.clubName != null)
                          Flexible(
                            child: Text(
                              budget.clubName!,
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
              if (budget.approvedAt != null)
                Text(
                  _formatDateTime(budget.approvedAt),
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