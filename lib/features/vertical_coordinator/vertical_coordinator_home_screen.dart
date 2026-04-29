import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../widgets/app_scaffold.dart';
import '../approver/approver_dashboard_screen.dart';
import '../approver/permission_approver_dashboard_screen.dart';

class VerticalCoordinatorHomeScreen extends StatelessWidget {
  const VerticalCoordinatorHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Vertical Coordinator',
      currentRoute: '/vertical-coordinator',
      showBottomNav: true,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.only(left: 4, bottom: 14, top: 4),
              child: Text(
                'Quick Access',
                style: TextStyle(
                  color: Color(0xFF6B7280),
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5,
                ),
              ),
            ),
            _NavCard(
              icon: Icons.description_outlined,
              title: 'Event Proposals',
              subtitle: 'Review proposals forwarded by faculty',
onTap: () {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const ApproverDashboardScreen(),
      ),
    );
  },            ),
            const SizedBox(height: 12),
            _NavCard(
              icon: Icons.assignment_turned_in_outlined,
              title: 'Resource Permissions',
              subtitle: 'Review permission requests',
 onTap: () {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const PermissionApproverDashboardScreen(),
      ),
    );
  },            ),
            const SizedBox(height: 12),
            _NavCard(
              icon: Icons.archive_outlined,
              title: 'Event Archive',
              subtitle: 'View archived events of all clubs',
              onTap: () => context.push('/archive'),
            ),
          ],
        ),
      ),
    );
  }
}

class _NavCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _NavCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E9F2)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF3B5BDB).withOpacity(0.06),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF3B5BDB), Color(0xFF7091E6)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: Colors.white, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: Color(0xFF1A1F36),
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        color: Color(0xFF6B7280),
                        fontSize: 13,
                      ),
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
}
