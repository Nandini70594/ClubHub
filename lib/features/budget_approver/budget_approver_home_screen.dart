// import 'package:flutter/material.dart';
// import 'package:go_router/go_router.dart';

// class BudgetApproverHomeScreen extends StatelessWidget {
//   const BudgetApproverHomeScreen({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Budget Approver Home'),
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           children: [
//             Card(
//               child: ListTile(
//                 leading: const Icon(Icons.account_balance_wallet_outlined),
//                 title: const Text('Budget Approval Requests'),
//                 subtitle: const Text('Review event budget submissions'),
//                 trailing: const Icon(Icons.arrow_forward_ios, size: 16),
//                 onTap: () {
//                   context.push('/budget-approver/budgets');
//                 },
//               ),
//             ),
//             const SizedBox(height: 12),
//             Card(
//               child: ListTile(
//                 leading: const Icon(Icons.receipt_long_outlined),
//                 title: const Text('Post Event Budget Proof Approval'),
//                 subtitle: const Text('Review bills, invoices, CO and PO'),
//                 trailing: const Icon(Icons.arrow_forward_ios, size: 16),
//                 onTap: () {
//                   context.push('/budget-approver/expenses');
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

class BudgetApproverHomeScreen extends StatelessWidget {
  const BudgetApproverHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FB),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        title: const Text(
          'Budget Approver',
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w700,
            color: Color(0xFF1A1F36),
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Divider(height: 1, color: Colors.grey.shade200),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            Text(
              'Approval Queue',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade500,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 12),
            _ApprovalModuleCard(
              icon: Icons.account_balance_wallet_outlined,
              iconColor: const Color(0xFF3B5BDB),
              iconBg: const Color(0xFFEEF2FF),
              title: 'Budget Approval Requests',
              subtitle: 'Review event budget submissions',
              onTap: () => context.push('/budget-approver/budgets'),
            ),
            const SizedBox(height: 10),
            _ApprovalModuleCard(
              icon: Icons.receipt_long_outlined,
              iconColor: const Color(0xFF0891B2),
              iconBg: const Color(0xFFE0F7FA),
              title: 'Post Event Budget Proof',
              subtitle: 'Review bills, invoices, CO and PO',
              onTap: () => context.push('/budget-approver/expenses'),
            ),
          ],
        ),
      ),
    );
  }
}

class _ApprovalModuleCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final Color iconBg;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _ApprovalModuleCard({
    required this.icon,
    required this.iconColor,
    required this.iconBg,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
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
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: iconBg,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: iconColor, size: 22),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1A1F36),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
                    ),
                  ],
                ),
              ),
              Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey.shade400),
            ],
          ),
        ),
      ),
    );
  }
}