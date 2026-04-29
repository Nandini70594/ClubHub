import 'package:flutter/material.dart';

class NavTab {
  final String label;
  final IconData icon;
  final IconData activeIcon;
  final String route;

  const NavTab({
    required this.label,
    required this.icon,
    required this.activeIcon,
    required this.route,
  });
}

List<NavTab> tabsForRole(String role) {
  switch (role) {
    case 'club_lead':
      return const [
        NavTab(
          label: 'Dashboard',
          icon: Icons.dashboard_outlined,
          activeIcon: Icons.dashboard,
          route: '/club',
        ),
        NavTab(
          label: 'Events',
          icon: Icons.event_outlined,
          activeIcon: Icons.event,
          route: '/club/create-event',
        ),
        NavTab(
          label: 'Profile',
          icon: Icons.person_outline,
          activeIcon: Icons.person,
          route: '/profile',
        ),
      ];

    case 'admin':
      return const [
        NavTab(
          label: 'Dashboard',
          icon: Icons.dashboard_outlined,
          activeIcon: Icons.dashboard,
          route: '/admin',
        ),
        NavTab(
          label: 'Profile',
          icon: Icons.person_outline,
          activeIcon: Icons.person,
          route: '/profile',
        ),
      ];

    case 'proposal_approver':
      return const [
        NavTab(
          label: 'Dashboard',
          icon: Icons.dashboard_outlined,
          activeIcon: Icons.dashboard,
          route: '/proposal-approver',
        ),
        NavTab(
          label: 'Profile',
          icon: Icons.person_outline,
          activeIcon: Icons.person,
          route: '/profile',
        ),
      ];

    case 'budget_approver':
      return const [
        NavTab(
          label: 'Dashboard',
          icon: Icons.dashboard_outlined,
          activeIcon: Icons.dashboard,
          route: '/budget-approver',
        ),
        NavTab(
          label: 'Profile',
          icon: Icons.person_outline,
          activeIcon: Icons.person,
          route: '/profile',
        ),
      ];

    case 'resource_incharge':
      return const [
        NavTab(
          label: 'Dashboard',
          icon: Icons.dashboard_outlined,
          activeIcon: Icons.dashboard,
          route: '/permission-approver',
        ),
        NavTab(
          label: 'Profile',
          icon: Icons.person_outline,
          activeIcon: Icons.person,
          route: '/profile',
        ),
      ];

    case 'director':
    case 'vertical_coordinator':
      return const [
        NavTab(
          label: 'Dashboard',
          icon: Icons.dashboard_outlined,
          activeIcon: Icons.dashboard,
          route: '/vertical-coordinator',
        ),
        NavTab(
          label: 'Profile',
          icon: Icons.person_outline,
          activeIcon: Icons.person,
          route: '/profile',
        ),
      ];

    default:
      return const [
        NavTab(
          label: 'Home',
          icon: Icons.home_outlined,
          activeIcon: Icons.home,
          route: '/login',
        ),
      ];
  }
}

String roleLabel(String role) {
  switch (role) {
    case 'club_lead':
      return 'Club Lead';
    case 'admin':
      return 'Admin';
    case 'proposal_approver':
      return 'Proposal Approver';
    case 'budget_approver':
      return 'Budget Approver';
    case 'resource_incharge':
      return 'Resource Incharge';
    case 'director':
      return 'Director';
    case 'vertical_coordinator':
      return 'Vertical Coordinator';
    default:
      return role;
  }
}
