// // import 'package:flutter/material.dart';
// // import 'package:flutter_riverpod/flutter_riverpod.dart';
// // import 'package:go_router/go_router.dart';

// // import '../../models/budget_model.dart';
// // import '../../models/event_model.dart';
// // import '../../providers/auth_provider.dart';
// // import 'budget_review_screen.dart';

// // class ApproverDashboardScreen extends ConsumerStatefulWidget {
// //   const ApproverDashboardScreen({super.key});

// //   @override
// //   ConsumerState<ApproverDashboardScreen> createState() =>
// //       _ApproverDashboardScreenState();
// // }

// // class _ApproverDashboardScreenState
// //     extends ConsumerState<ApproverDashboardScreen> {
// //   int _reloadKey = 0;

// //   Future<void> _refresh() async {
// //     setState(() {
// //       _reloadKey++;
// //     });
// //   }

// //   @override
// //   Widget build(BuildContext context) {
// //     final proposalFuture = ref.read(eventServiceProvider).getPendingProposalEvents();
// //     final budgetFuture = ref.read(eventServiceProvider).getPendingBudgets();

// //     return DefaultTabController(
// //       length: 2,
// //       child: Scaffold(
// //         appBar: AppBar(
// //           title: const Text('Approver Dashboard'),
// //           bottom: const TabBar(
// //             tabs: [
// //               Tab(text: 'Proposals'),
// //               Tab(text: 'Budgets'),
// //             ],
// //           ),
// //         ),
// //         body: TabBarView(
// //           children: [
// //             FutureBuilder<List<EventModel>>(
// //               key: ValueKey('proposal_$_reloadKey'),
// //               future: proposalFuture,
// //               builder: (context, snapshot) {
// //                 if (snapshot.connectionState == ConnectionState.waiting) {
// //                   return const Center(child: CircularProgressIndicator());
// //                 }
// //                 if (snapshot.hasError) {
// //                   return Center(child: Text('Error: ${snapshot.error}'));
// //                 }
// //                 final events = snapshot.data ?? [];
// //                 if (events.isEmpty) {
// //                   return RefreshIndicator(
// //                     onRefresh: _refresh,
// //                     child: ListView(
// //                       physics: const AlwaysScrollableScrollPhysics(),
// //                       children: const [
// //                         SizedBox(height: 200),
// //                         Center(child: Text('No pending proposals')),
// //                       ],
// //                     ),
// //                   );
// //                 }
// //                 return RefreshIndicator(
// //                   onRefresh: _refresh,
// //                   child: ListView.builder(
// //                     physics: const AlwaysScrollableScrollPhysics(),
// //                     itemCount: events.length,
// //                     itemBuilder: (context, index) {
// //                       final event = events[index];
// //                       return Card(
// //                         margin: const EdgeInsets.all(12),
// //                         child: ListTile(
// //                           onTap: () async {
// //                             final changed = await context.push<bool>(
// //                               '/approver/proposal/${event.id}',
// //                             );
// //                             if (changed == true) {
// //                               await _refresh();
// //                             }
// //                           },
// //                           title: Text(event.title),
// //                           subtitle: Text(
// //                             '${event.eventDate} • ${event.venue ?? '-'} • ${event.proposalStatus}',
// //                           ),
// //                           trailing: const Icon(Icons.arrow_forward_ios, size: 16),
// //                         ),
// //                       );
// //                     },
// //                   ),
// //                 );
// //               },
// //             ),
// //             FutureBuilder<List<BudgetModel>>(
// //               key: ValueKey('budget_$_reloadKey'),
// //               future: budgetFuture,
// //               builder: (context, snapshot) {
// //                 if (snapshot.connectionState == ConnectionState.waiting) {
// //                   return const Center(child: CircularProgressIndicator());
// //                 }
// //                 if (snapshot.hasError) {
// //                   return Center(child: Text('Error: ${snapshot.error}'));
// //                 }
// //                 final budgets = snapshot.data ?? [];
// //                 if (budgets.isEmpty) {
// //                   return RefreshIndicator(
// //                     onRefresh: _refresh,
// //                     child: ListView(
// //                       physics: const AlwaysScrollableScrollPhysics(),
// //                       children: const [
// //                         SizedBox(height: 200),
// //                         Center(child: Text('No pending budgets')),
// //                       ],
// //                     ),
// //                   );
// //                 }
// //                 return RefreshIndicator(
// //                   onRefresh: _refresh,
// //                   child: ListView.builder(
// //                     physics: const AlwaysScrollableScrollPhysics(),
// //                     itemCount: budgets.length,
// //                     itemBuilder: (context, index) {
// //                       final budget = budgets[index];
// //                       return Card(
// //                         margin: const EdgeInsets.all(12),
// //                         child: ListTile(
// //                           onTap: () async {
// //                             final changed = await Navigator.push<bool>(
// //                               context,
// //                               MaterialPageRoute(
// //                                 builder: (_) => BudgetReviewScreen(budget: budget),
// //                               ),
// //                             );
// //                             if (changed == true) {
// //                               await _refresh();
// //                             }
// //                           },
// //                           title: Text('Budget for Event ${budget.eventId.substring(0, 6)}'),
// //                           subtitle: Text(
// //                             '₹${budget.totalRequested} • ${budget.status}',
// //                           ),
// //                           trailing: const Icon(Icons.arrow_forward_ios, size: 16),
// //                         ),
// //                       );
// //                     },
// //                   ),
// //                 );
// //               },
// //             ),
// //           ],
// //         ),
// //       ),
// //     );
// //   }
// // }


// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:go_router/go_router.dart';

// import '../../models/budget_model.dart';
// import '../../models/event_model.dart';
// import '../../providers/auth_provider.dart';
// import 'budget_review_screen.dart';

// class ApproverDashboardScreen extends ConsumerStatefulWidget {
//   const ApproverDashboardScreen({super.key});

//   @override
//   ConsumerState<ApproverDashboardScreen> createState() =>
//       _ApproverDashboardScreenState();
// }

// class _ApproverDashboardScreenState
//     extends ConsumerState<ApproverDashboardScreen> {
//   int _reloadKey = 0;

//   Future<void> _refresh() async {
//     setState(() {
//       _reloadKey++;
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     final userAsync = ref.watch(currentUserProfileProvider);

//     return userAsync.when(
//       data: (user) {
//         if (user == null) {
//           return const Scaffold(
//             body: Center(child: Text('No user')),
//           );
//         }

//         final proposalFuture = ref
//             .read(eventServiceProvider)
//             .getPendingProposalEventsForRole(user.role);

//         final budgetFuture =
//             ref.read(eventServiceProvider).getPendingBudgets();

//         final archiveFuture = ref
//             .read(eventServiceProvider)
//             .getArchivedEventsForRole(user.role);

//         return DefaultTabController(
//           length: 3,
//           child: Scaffold(
//             appBar: AppBar(
//               title: const Text('Approver Dashboard'),
//               bottom: const TabBar(
//                 tabs: [
//                   Tab(text: 'Proposals'),
//                   Tab(text: 'Budgets'),
//                   Tab(text: 'Past Events'),
//                 ],
//               ),
//             ),
//             body: TabBarView(
//               children: [
//                 // 🔹 Proposals
//                 _buildEventList(proposalFuture, 'No pending proposals'),

//                 // 🔹 Budgets
//                 _buildBudgetList(budgetFuture),

//                 // 🔹 Past Events
//                 _buildArchiveList(archiveFuture),
//               ],
//             ),
//           ),
//         );
//       },
//       loading: () =>
//           const Scaffold(body: Center(child: CircularProgressIndicator())),
//       error: (e, _) =>
//           Scaffold(body: Center(child: Text('Error: $e'))),
//     );
//   }

//   Widget _buildEventList(
//       Future<List<EventModel>> future, String emptyText) {
//     return FutureBuilder<List<EventModel>>(
//       future: future,
//       builder: (context, snapshot) {
//         if (!snapshot.hasData) {
//           return const Center(child: CircularProgressIndicator());
//         }

//         final events = snapshot.data!;

//         if (events.isEmpty) {
//           return Center(child: Text(emptyText));
//         }

//         return ListView.builder(
//           itemCount: events.length,
//           itemBuilder: (context, index) {
//             final event = events[index];

//             return ListTile(
//               title: Text(event.title),
//               subtitle: Text(event.eventDate),
//             );
//           },
//         );
//       },
//     );
//   }

//   Widget _buildBudgetList(Future<List<BudgetModel>> future) {
//     return FutureBuilder<List<BudgetModel>>(
//       future: future,
//       builder: (context, snapshot) {
//         if (!snapshot.hasData) {
//           return const Center(child: CircularProgressIndicator());
//         }

//         final budgets = snapshot.data!;

//         if (budgets.isEmpty) {
//           return const Center(child: Text('No budgets'));
//         }

//         return ListView.builder(
//           itemCount: budgets.length,
//           itemBuilder: (context, index) {
//             final budget = budgets[index];

//             return ListTile(
//               title: Text('Budget ${budget.eventId.substring(0, 6)}'),
//               subtitle: Text('₹${budget.totalRequested}'),
//             );
//           },
//         );
//       },
//     );
//   }

//   Widget _buildArchiveList(Future<List<EventModel>> future) {
//     return FutureBuilder<List<EventModel>>(
//       future: future,
//       builder: (context, snapshot) {
//         if (!snapshot.hasData) {
//           return const Center(child: CircularProgressIndicator());
//         }

//         final events = snapshot.data!;

//         if (events.isEmpty) {
//           return const Center(child: Text('No past events'));
//         }

//         return ListView.builder(
//           itemCount: events.length,
//           itemBuilder: (context, index) {
//             final event = events[index];

//             return ListTile(
//               title: Text(event.title),
//               subtitle: Text(event.eventDate),
//               trailing: const Text('Closed'),
//             );
//           },
//         );
//       },
//     );
//   }
// }


import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../models/budget_model.dart';
import '../../models/event_model.dart';
import '../../providers/auth_provider.dart';
import 'budget_review_screen.dart';

// ── Design tokens ─────────────────────────────────────────────────────────────
const _kPrimary    = Color(0xFF3B5BDB);
const _kPrimaryBg  = Color(0xFFEEF2FF);
const _kSurface    = Colors.white;
const _kBackground = Color(0xFFF4F6FB);
const _kTextDark   = Color(0xFF1A1F36);
const _kTextMid    = Color(0xFF6B7280);
const _kBorder     = Color(0xFFE5E7EB);
const _kRadius     = 12.0;
// ─────────────────────────────────────────────────────────────────────────────

class ApproverDashboardScreen extends ConsumerStatefulWidget {
  const ApproverDashboardScreen({super.key});

  @override
  ConsumerState<ApproverDashboardScreen> createState() =>
      _ApproverDashboardScreenState();
}

class _ApproverDashboardScreenState
    extends ConsumerState<ApproverDashboardScreen>
    with SingleTickerProviderStateMixin {
  int _reloadKey = 0;
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _refresh() async {
    setState(() => _reloadKey++);
  }

  @override
  Widget build(BuildContext context) {
    final userAsync = ref.watch(currentUserProfileProvider);

    return userAsync.when(
      data: (user) {
        if (user == null) {
          return const Scaffold(body: Center(child: Text('No user')));
        }

        final proposalFuture = ref
            .read(eventServiceProvider)
            .getPendingProposalEventsForRole(user.role);
        final budgetFuture =
            ref.read(eventServiceProvider).getPendingBudgets();
        final archiveFuture = ref
            .read(eventServiceProvider)
            .getArchivedEventsForRole(user.role);

        return Scaffold(
          backgroundColor: _kBackground,
          appBar: AppBar(
            backgroundColor: _kSurface,
            elevation: 0,
            surfaceTintColor: Colors.transparent,
            title: const Text(
              'Approver Dashboard',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: _kTextDark,
              ),
            ),
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(49),
              child: Column(
                children: [
                  Divider(height: 1, color: Colors.grey.shade200),
                  TabBar(
                    controller: _tabController,
                    labelColor: _kPrimary,
                    unselectedLabelColor: _kTextMid,
                    labelStyle: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                    unselectedLabelStyle: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                    indicatorColor: _kPrimary,
                    indicatorWeight: 2.5,
                    tabs: const [
                      Tab(text: 'Proposals'),
                      Tab(text: 'Budgets'),
                      Tab(text: 'Past Events'),
                    ],
                  ),
                ],
              ),
            ),
          ),
          body: TabBarView(
            controller: _tabController,
            children: [
              _buildEventList(
                key: ValueKey('proposal_$_reloadKey'),
                future: proposalFuture,
                emptyText: 'No pending proposals',
                emptyIcon: Icons.inbox_outlined,
                onTap: (event) async {
                  final changed =
                      await context.push<bool>('/approver/proposal/${event.id}');
                  if (changed == true) await _refresh();
                },
              ),
              _buildBudgetList(
                key: ValueKey('budget_$_reloadKey'),
                future: budgetFuture,
              ),
              _buildEventList(
                key: ValueKey('archive_$_reloadKey'),
                future: archiveFuture,
                emptyText: 'No past events',
                emptyIcon: Icons.history_outlined,
                trailing: (_) => _StatusChip(label: 'Closed', color: _kTextMid),
              ),
            ],
          ),
        );
      },
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator(color: _kPrimary)),
      ),
      error: (e, _) => Scaffold(
        body: Center(
          child: Text('Error: $e',
              style: const TextStyle(color: Color(0xFFDC2626))),
        ),
      ),
    );
  }

  // ── Proposals / Archive list ───────────────────────────────────────────────
  Widget _buildEventList({
    required Key key,
    required Future<List<EventModel>> future,
    required String emptyText,
    required IconData emptyIcon,
    Future<void> Function(EventModel)? onTap,
    Widget Function(EventModel)? trailing,
  }) {
    return FutureBuilder<List<EventModel>>(
      key: key,
      future: future,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
              child: CircularProgressIndicator(color: _kPrimary));
        }
        if (snapshot.hasError) {
          return Center(
            child: Text('Error: ${snapshot.error}',
                style: const TextStyle(color: Color(0xFFDC2626))),
          );
        }

        final events = snapshot.data ?? [];

        if (events.isEmpty) {
          return _EmptyState(icon: emptyIcon, message: emptyText);
        }

        return RefreshIndicator(
          onRefresh: _refresh,
          color: _kPrimary,
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: events.length,
            itemBuilder: (context, index) {
              final event = events[index];
              return _EventCard(
                event: event,
                trailing: trailing?.call(event),
                onTap: onTap != null ? () => onTap(event) : null,
              );
            },
          ),
        );
      },
    );
  }

  // ── Budget list ────────────────────────────────────────────────────────────
  Widget _buildBudgetList({
    required Key key,
    required Future<List<BudgetModel>> future,
  }) {
    return FutureBuilder<List<BudgetModel>>(
      key: key,
      future: future,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
              child: CircularProgressIndicator(color: _kPrimary));
        }
        if (snapshot.hasError) {
          return Center(
            child: Text('Error: ${snapshot.error}',
                style: const TextStyle(color: Color(0xFFDC2626))),
          );
        }

        final budgets = snapshot.data ?? [];

        if (budgets.isEmpty) {
          return const _EmptyState(
            icon: Icons.account_balance_wallet_outlined,
            message: 'No pending budgets',
          );
        }

        return RefreshIndicator(
          onRefresh: _refresh,
          color: _kPrimary,
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: budgets.length,
            itemBuilder: (context, index) {
              final budget = budgets[index];
              return _BudgetCard(
                budget: budget,
                onTap: () async {
                  final changed = await Navigator.push<bool>(
                    context,
                    MaterialPageRoute(
                      builder: (_) => BudgetReviewScreen(budget: budget),
                    ),
                  );
                  if (changed == true) await _refresh();
                },
              );
            },
          ),
        );
      },
    );
  }
}

// ── Event card ─────────────────────────────────────────────────────────────
class _EventCard extends StatelessWidget {
  final EventModel event;
  final Widget? trailing;
  final VoidCallback? onTap;

  const _EventCard({required this.event, this.trailing, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(_kRadius),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: _kSurface,
            borderRadius: BorderRadius.circular(_kRadius),
            border: Border.all(color: _kBorder),
          ),
          child: Row(
            children: [
              Container(
                width: 40, height: 40,
                decoration: BoxDecoration(
                  color: _kPrimaryBg,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.event_outlined,
                    color: _kPrimary, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      event.title,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: _kTextDark,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.calendar_today_outlined,
                            size: 11, color: Colors.grey.shade400),
                        const SizedBox(width: 4),
                        Text(
                          event.eventDate.toString(),
                          style: TextStyle(
                              fontSize: 11, color: Colors.grey.shade500),
                        ),
                        if (event.venue != null) ...[
                          const SizedBox(width: 8),
                          Icon(Icons.location_on_outlined,
                              size: 11, color: Colors.grey.shade400),
                          const SizedBox(width: 3),
                          Flexible(
                            child: Text(
                              event.venue!,
                              style: TextStyle(
                                  fontSize: 11, color: Colors.grey.shade500),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              trailing ??
                  (onTap != null
                      ? Icon(Icons.arrow_forward_ios,
                          size: 14, color: Colors.grey.shade400)
                      : const SizedBox.shrink()),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Budget card ────────────────────────────────────────────────────────────
class _BudgetCard extends StatelessWidget {
  final BudgetModel budget;
  final VoidCallback onTap;

  const _BudgetCard({required this.budget, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(_kRadius),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: _kSurface,
            borderRadius: BorderRadius.circular(_kRadius),
            border: Border.all(color: _kBorder),
          ),
          child: Row(
            children: [
              Container(
                width: 40, height: 40,
                decoration: BoxDecoration(
                  color: const Color(0xFFF0FDF4),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.account_balance_wallet_outlined,
                    color: Color(0xFF16A34A), size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Budget · ${budget.eventId.substring(0, 6).toUpperCase()}',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: _kTextDark,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '₹${budget.totalRequested}',
                      style: TextStyle(
                          fontSize: 12, color: Colors.grey.shade500),
                    ),
                  ],
                ),
              ),
              _StatusChip(
                label: budget.status,
                color: budget.status.toLowerCase() == 'pending'
                    ? _kPrimary
                    : const Color(0xFF16A34A),
              ),
              const SizedBox(width: 8),
              Icon(Icons.arrow_forward_ios,
                  size: 14, color: Colors.grey.shade400),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Reusable widgets ───────────────────────────────────────────────────────
class _StatusChip extends StatelessWidget {
  final String label;
  final Color color;

  const _StatusChip({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: TextStyle(
            fontSize: 11, fontWeight: FontWeight.w600, color: color),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final IconData icon;
  final String message;

  const _EmptyState({required this.icon, required this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 64, height: 64,
            decoration: BoxDecoration(
              color: _kPrimaryBg,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: _kPrimary, size: 30),
          ),
          const SizedBox(height: 16),
          Text(
            message,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.grey.shade500,
            ),
          ),
        ],
      ),
    );
  }
}