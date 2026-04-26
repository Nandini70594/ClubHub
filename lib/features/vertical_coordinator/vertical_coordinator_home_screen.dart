// import 'package:flutter/material.dart';
// import 'package:go_router/go_router.dart';

// class VerticalCoordinatorHomeScreen extends StatelessWidget {
//   const VerticalCoordinatorHomeScreen({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Vertical Coordinator Home'),
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           children: [
//             Card(
//               child: ListTile(
//                 leading: const Icon(Icons.description_outlined),
//                 title: const Text('Event Proposals'),
//                 subtitle: const Text('Review proposals forwarded by faculty'),
//                 trailing: const Icon(Icons.arrow_forward_ios, size: 16),
//                 onTap: () {
//                   context.push('/proposal-approver/proposals');
//                 },
//               ),
//             ),
//             const SizedBox(height: 12),
//             Card(
//               child: ListTile(
//                 leading: const Icon(Icons.assignment_turned_in_outlined),
//                 title: const Text('Resource Permissions'),
//                 subtitle: const Text('Review permission requests'),
//                 trailing: const Icon(Icons.arrow_forward_ios, size: 16),
//                 onTap: () {
//                   context.push('/permission-approver');
//                 },
//               ),
//             ),
//             const SizedBox(height: 12),
//             Card(
//               child: ListTile(
//                 leading: const Icon(Icons.history),
//                 title: const Text('Event Archive'),
//                 subtitle: const Text('View archived events of all clubs'),
//                 trailing: const Icon(Icons.arrow_forward_ios, size: 16),
//                 onTap: () {
//                   context.push('/archive');
//                 },
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }


import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

// ── ERPTheme tokens ────────────────────────────────────────────────────────
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
// ────────────────────────────────────────────────────────────────────────────

class VerticalCoordinatorHomeScreen extends StatelessWidget {
  const VerticalCoordinatorHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ERPTheme.bgPage,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        flexibleSpace: Container(
          decoration: BoxDecoration(gradient: ERPTheme.headerGradient),
        ),
        title: const Text(
          'Vertical Coordinator Home',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 18,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.only(left: 4, bottom: 14, top: 4),
              child: Text(
                'Quick Access',
                style: TextStyle(
                  color: ERPTheme.textSecondary,
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
              onTap: () => context.push('/proposal-approver/proposals'),
            ),
            const SizedBox(height: 12),
            _NavCard(
              icon: Icons.assignment_turned_in_outlined,
              title: 'Resource Permissions',
              subtitle: 'Review permission requests',
              onTap: () => context.push('/permission-approver'),
            ),
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
      decoration: ERPTheme.cardDecoration,
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
                  gradient: ERPTheme.headerGradient,
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
                        color: ERPTheme.textPrimary,
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        color: ERPTheme.textSecondary,
                        fontSize: 13,
                      ),
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
}