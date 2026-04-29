import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/app_user.dart';
import '../../models/permission_request_model.dart';
import '../../providers/auth_provider.dart';
import 'permission_review_screen.dart';
import '../../widgets/app_scaffold.dart';

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

class PermissionApproverDashboardScreen extends ConsumerStatefulWidget {
  const PermissionApproverDashboardScreen({super.key});

  @override
  ConsumerState<PermissionApproverDashboardScreen> createState() =>
      _PermissionApproverDashboardScreenState();
}

class _PermissionApproverDashboardScreenState
    extends ConsumerState<PermissionApproverDashboardScreen> {
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
      default:
        bg = ERPTheme.statusPending.withOpacity(0.12);
        fg = ERPTheme.statusPending;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status,
        style: TextStyle(
          color: fg,
          fontSize: 11,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.4,
        ),
      ),
    );
  }

  Widget _pendingCard(PermissionRequestModel request, BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: ERPTheme.cardDecoration,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () async {
          final changed = await Navigator.push<bool>(
            context,
            MaterialPageRoute(
              builder: (_) => PermissionReviewScreen(request: request),
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
                  gradient: ERPTheme.headerGradient,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.assignment_outlined,
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
  request.purpose,
  style: const TextStyle(
    color: ERPTheme.textPrimary,
    fontWeight: FontWeight.w600,
    fontSize: 14,
  ),
  maxLines: 2,
  overflow: TextOverflow.ellipsis,
),
const SizedBox(height: 4),
Text(
  'Club: ${request.clubName ?? '-'}',
  style: const TextStyle(
    color: ERPTheme.textSecondary,
    fontSize: 12,
    fontWeight: FontWeight.w500,
  ),
  overflow: TextOverflow.ellipsis,
),
const SizedBox(height: 6),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        _statusBadge(request.status),
                        const SizedBox(width: 8),
                        if (request.currentApproverRole != null)
                          Flexible(
                            child: Text(
                              'Approver: ${request.currentApproverRole}',
                              style: const TextStyle(
                                color: ERPTheme.textSecondary,
                                fontSize: 12,
                              ),
                              overflow: TextOverflow.ellipsis,
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

  Widget _reviewedCard(PermissionRequestModel request, BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: ERPTheme.cardDecoration,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => PermissionReviewScreen(request: request),
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
  request.purpose,
  style: const TextStyle(
    color: ERPTheme.textPrimary,
    fontWeight: FontWeight.w600,
    fontSize: 14,
  ),
  maxLines: 2,
  overflow: TextOverflow.ellipsis,
),
const SizedBox(height: 4),
Text(
  'Club: ${request.clubName ?? '-'}',
  style: const TextStyle(
    color: ERPTheme.textSecondary,
    fontSize: 12,
    fontWeight: FontWeight.w500,
  ),
  overflow: TextOverflow.ellipsis,
),
const SizedBox(height: 6),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        _statusBadge(request.status),
                        const SizedBox(width: 8),
                        Flexible(
                          child: Text(
                            request.decisionRemarks ?? '-',
                            style: const TextStyle(
                              color: ERPTheme.textSecondary,
                              fontSize: 12,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Text(
                _formatDateTime(request.decidedAt),
                style: const TextStyle(
                  fontSize: 11,
                  color: ERPTheme.textSecondary,
                ),
                textAlign: TextAlign.right,
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
          const SizedBox(height: 80),
          Center(
            child: Column(
              children: [
                Container(
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
                const SizedBox(height: 16),
                Text(
                  message,
                  style: const TextStyle(
                    color: ERPTheme.textSecondary,
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

  @override
  Widget build(BuildContext context) {
    final userService = ref.read(userServiceProvider);
    final permissionService = ref.read(permissionServiceProvider);

    return FutureBuilder<AppUser?>(
      future: userService.getCurrentUserProfile(),
      builder: (context, userSnapshot) {
        if (userSnapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            backgroundColor: ERPTheme.bgPage,
            body: Center(
              child: CircularProgressIndicator(color: ERPTheme.primary),
            ),
          );
        }

        if (userSnapshot.hasError) {
          return Scaffold(
            backgroundColor: ERPTheme.bgPage,
            appBar: _buildAppBar('Permission Approver'),
            body: Center(child: Text('Error: ${userSnapshot.error}')),
          );
        }

        final user = userSnapshot.data;
        if (user == null) {
          return Scaffold(
            backgroundColor: ERPTheme.bgPage,
            appBar: _buildAppBar('Permission Approver'),
            body: const Center(child: Text('User profile not found')),
          );
        }

        final pendingFuture = permissionService.getPendingRequestsForRole(
          user.role,
        );
        final reviewedFuture = permissionService.getReviewedRequestsForRole(
          user.role,
        );

        return DefaultTabController(
          length: 2,
          child: AppScaffold(
            title: 'ClubHub',
            currentRoute: '/permission-approver',
            child: Scaffold(
              backgroundColor: ERPTheme.bgPage,
              appBar: AppBar(
                backgroundColor: Colors.transparent,
                elevation: 0,
                flexibleSpace: Container(
                  decoration: BoxDecoration(gradient: ERPTheme.headerGradient),
                ),
                title: const Text(
                  'ClubHub',
                  style: TextStyle(
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
                    child: TabBar(
                      labelColor: Colors.white,
                      unselectedLabelColor: Colors.white70,
                      indicatorColor: Colors.white,
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
                ),
              ),
              body: TabBarView(
                children: [
                  FutureBuilder<List<PermissionRequestModel>>(
                    key: ValueKey('permission_pending_$_reloadKey'),
                    future: pendingFuture,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(
                          child: CircularProgressIndicator(
                            color: ERPTheme.primary,
                          ),
                        );
                      }

                      if (snapshot.hasError) {
                        return Center(child: Text('Error: ${snapshot.error}'));
                      }

                      final requests = snapshot.data ?? [];
                      if (requests.isEmpty) {
                        return _emptyState('No pending permission requests');
                      }

                      return RefreshIndicator(
                        onRefresh: _refresh,
                        color: ERPTheme.primary,
                        child: ListView.builder(
                          physics: const AlwaysScrollableScrollPhysics(),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          itemCount: requests.length,
                          itemBuilder: (context, index) =>
                              _pendingCard(requests[index], context),
                        ),
                      );
                    },
                  ),
                  FutureBuilder<List<PermissionRequestModel>>(
                    key: ValueKey('permission_reviewed_$_reloadKey'),
                    future: reviewedFuture,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(
                          child: CircularProgressIndicator(
                            color: ERPTheme.primary,
                          ),
                        );
                      }

                      if (snapshot.hasError) {
                        return Center(child: Text('Error: ${snapshot.error}'));
                      }

                      final requests = snapshot.data ?? [];
                      if (requests.isEmpty) {
                        return _emptyState('No reviewed permission requests');
                      }

                      return RefreshIndicator(
                        onRefresh: _refresh,
                        color: ERPTheme.primary,
                        child: ListView.builder(
                          physics: const AlwaysScrollableScrollPhysics(),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          itemCount: requests.length,
                          itemBuilder: (context, index) =>
                              _reviewedCard(requests[index], context),
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
    );
  }

  AppBar _buildAppBar(String title) {
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
    );
  }
}
