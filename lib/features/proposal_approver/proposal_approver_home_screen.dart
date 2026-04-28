import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../models/event_model.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/app_scaffold.dart';

// ── ERPTheme tokens (same as permission screen) ──────────────────────────
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
  static const Color statusApproved = Color(0xFF10B981);
  static const Color statusRejected = Color(0xFFEF4444);
  static const Color statusPending = Color(0xFFF59E0B);

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

class ProposalApproverHomeScreen extends ConsumerStatefulWidget {
  const ProposalApproverHomeScreen({super.key});

  @override
  ConsumerState<ProposalApproverHomeScreen> createState() => _ProposalApproverHomeScreenState();
}

class _ProposalApproverHomeScreenState extends ConsumerState<ProposalApproverHomeScreen> {
  int _reloadKey = 0;

  Future<void> _refresh() async {
    setState(() {
      _reloadKey++;
    });
  }

  String _formatDateTime(String? dateTimeStr) {
    if (dateTimeStr == null || dateTimeStr.isEmpty) return '';
    final dt = DateTime.parse(dateTimeStr).toLocal();
    final hour = dt.hour % 12 == 0 ? 12 : dt.hour % 12;
    final minute = dt.minute.toString().padLeft(2, '0');
    final amPm = dt.hour >= 12 ? 'PM' : 'AM';
    return '${dt.day}/${dt.month}/${dt.year} • $hour:$minute $amPm';
  }

  Widget _statusBadge(String status) {
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
      case 'CHANGES_REQUESTED':
        bg = ERPTheme.statusRejected.withOpacity(0.12);
        fg = ERPTheme.statusRejected;
        break;
      default:
        bg = ERPTheme.statusPending.withOpacity(0.12);
        fg = ERPTheme.statusPending;
    }
    
    String text = status == 'changes_requested' ? 'Changes Requested' : 
                  status.isEmpty ? 'Pending' : 
                  status[0].toUpperCase() + status.substring(1).toLowerCase();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: fg,
          fontSize: 11,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.4,
        ),
      ),
    );
  }

  Widget _pendingCard(EventModel proposal, BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: ERPTheme.cardDecoration,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () async {
          final changed = await context.push<bool>("/proposal-approver/review/${proposal.id}");
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
                  gradient: ERPTheme.headerGradient,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.description_outlined,
                  color: Colors.white,
                  size: 22,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      proposal.clubName ?? 'Unknown Club',
                      style: const TextStyle(
                        color: ERPTheme.primary,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      proposal.title,
                      style: const TextStyle(
                        color: ERPTheme.textPrimary,
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        _statusBadge(proposal.proposalStatus),
                        const SizedBox(width: 8),
                        Text(
                          proposal.eventDate,
                          style: const TextStyle(
                            color: ERPTheme.textSecondary,
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
                color: ERPTheme.accent,
                size: 22,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _reviewedCard(EventModel proposal, BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: ERPTheme.cardDecoration,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () async {
          final changed = await context.push<bool>("/proposal-approver/review/${proposal.id}");
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
                  color: ERPTheme.primarySurface,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.task_alt_outlined,
                  color: ERPTheme.primary,
                  size: 22,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      proposal.clubName ?? 'Unknown Club',
                      style: const TextStyle(
                        color: ERPTheme.primary,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      proposal.title,
                      style: const TextStyle(
                        color: ERPTheme.textPrimary,
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        _statusBadge(proposal.proposalStatus),
                        const SizedBox(width: 8),
                        Text(
                          proposal.eventDate,
                          style: const TextStyle(
                            color: ERPTheme.textSecondary,
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
                color: ERPTheme.accent,
                size: 22,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _emptyState(String message) {
    return RefreshIndicator(
      onRefresh: _refresh,
      color: ERPTheme.primary,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          const SizedBox(height: 120),
          Center(
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: ERPTheme.primarySurface,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.inbox_outlined,
                size: 40,
                color: ERPTheme.primary,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            message,
            style: const TextStyle(
              color: ERPTheme.textSecondary,
              fontSize: 14,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final userAsync = ref.watch(currentUserProfileProvider);

    return userAsync.when(
      data: (user) {
        if (user == null) {
          return Scaffold(
            backgroundColor: ERPTheme.bgPage,
            appBar: _buildAppBar('Proposal Approver'),
            body: const Center(child: Text('User profile not found')),
          );
        }

        final pendingFuture = ref.read(eventServiceProvider).getPendingProposalEventsForRole(user.role);
        final reviewedFuture = ref.read(eventServiceProvider).getReviewedProposalEventsForCurrentApprover();

        return DefaultTabController(
  length: 2,
  child: AppScaffold(
    title: 'ClubHub',
    currentRoute: '/proposal-approver',
    child: Scaffold(
            backgroundColor: ERPTheme.bgPage,
            appBar: _buildAppBar('Proposal Approver'),
            body: TabBarView(
              children: [
                // ── Pending Tab ──
                FutureBuilder<List<EventModel>>(
                  key: ValueKey('proposal_pending_$_reloadKey'),
                  future: pendingFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(
                        child: CircularProgressIndicator(color: ERPTheme.primary),
                      );
                    }
                    if (snapshot.hasError) {
                      return Center(child: Text('Error: ${snapshot.error}'));
                    }

                    final proposals = snapshot.data ?? [];
                    if (proposals.isEmpty) {
                      return _emptyState('No pending proposals');
                    }

                    return RefreshIndicator(
                      onRefresh: _refresh,
                      color: ERPTheme.primary,
                      child: ListView.builder(
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        itemCount: proposals.length,
                        itemBuilder: (context, index) => _pendingCard(proposals[index], context),
                      ),
                    );
                  },
                ),

                // ── Reviewed Tab ──
                FutureBuilder<List<EventModel>>(
                  key: ValueKey('proposal_reviewed_$_reloadKey'),
                  future: reviewedFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(
                        child: CircularProgressIndicator(color: ERPTheme.primary),
                      );
                    }
                    if (snapshot.hasError) {
                      return Center(child: Text('Error: ${snapshot.error}'));
                    }

                    final proposals = snapshot.data ?? [];
                    if (proposals.isEmpty) {
                      return _emptyState('No reviewed proposals');
                    }

                    return RefreshIndicator(
                      onRefresh: _refresh,
                      color: ERPTheme.primary,
                      child: ListView.builder(
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        itemCount: proposals.length,
                        itemBuilder: (context, index) => _reviewedCard(proposals[index], context),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          ),
        );
      },
      loading: () => Scaffold(
        backgroundColor: ERPTheme.bgPage,
        appBar: _buildAppBar('Proposal Approver'),
        body: const Center(
          child: CircularProgressIndicator(color: ERPTheme.primary),
        ),
      ),
      error: (error, _) => Scaffold(
        backgroundColor: ERPTheme.bgPage,
        appBar: _buildAppBar('Proposal Approver'),
        body: Center(child: Text('Error: $error')),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(String title) {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      flexibleSpace: Container(
        decoration: BoxDecoration(gradient: ERPTheme.headerGradient),
      ),
      title: Text(
        title,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w600,
          fontSize: 18,
        ),
      ),
      iconTheme: const IconThemeData(color: Colors.white),
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(48),
        child: Container(
          color: Colors.white.withOpacity(0.08),
          child: const TabBar(
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            indicatorColor: Colors.white,
            indicatorWeight: 3,
            labelStyle: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
            tabs: [
              Tab(text: 'Pending'),
              Tab(text: 'Reviewed'),
            ],
          ),
        ),
      ),
    );
  }
}
