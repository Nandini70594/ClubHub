// // import 'package:flutter/material.dart';
// // import 'package:flutter_riverpod/flutter_riverpod.dart';
// // import 'package:go_router/go_router.dart';

// // import '../../models/event_model.dart';
// // import '../../providers/auth_provider.dart';

// // class ClubDashboardScreen extends ConsumerStatefulWidget {
// //   const ClubDashboardScreen({super.key});

// //   @override
// //   ConsumerState<ClubDashboardScreen> createState() =>
// //       _ClubDashboardScreenState();
// // }

// // class _ClubDashboardScreenState extends ConsumerState<ClubDashboardScreen> {
// //   int _reloadKey = 0;

// //   Future<void> _refresh() async {
// //     setState(() {
// //       _reloadKey++;
// //     });
// //   }

// //   @override
// //   Widget build(BuildContext context) {
// //     final future = ref.read(eventServiceProvider).getEventsForCurrentUserClub();

// //     return Scaffold(
// //       appBar: AppBar(
// //         title: const Text('Club Dashboard'),
// //         actions: [
// //   TextButton.icon(
// //     onPressed: () {
// //       context.push('/archive');
// //     },
// //     icon: const Icon(Icons.history, color: Colors.white),
// //     label: const Text(
// //       'Archive',
// //       style: TextStyle(color: Colors.white),
// //     ),
// //   ),
// // ],
// //       ),
// //       floatingActionButton: FloatingActionButton(
// //         onPressed: () async {
// //           final created = await context.push<bool>('/club/create-event');
// //           if (created == true) {
// //             await _refresh();
// //           }
// //         },
// //         child: const Icon(Icons.add),
// //       ),
// //       body: FutureBuilder<List<EventModel>>(
// //         key: ValueKey(_reloadKey),
// //         future: future,
// //         builder: (context, snapshot) {
// //           if (snapshot.connectionState == ConnectionState.waiting) {
// //             return const Center(child: CircularProgressIndicator());
// //           }

// //           if (snapshot.hasError) {
// //             return Center(
// //               child: Text('Error: ${snapshot.error}'),
// //             );
// //           }

// //           final events = snapshot.data ?? [];

// //           if (events.isEmpty) {
// //             return RefreshIndicator(
// //               onRefresh: _refresh,
// //               child: ListView(
// //                 physics: const AlwaysScrollableScrollPhysics(),
// //                 children: const [
// //                   SizedBox(height: 200),
// //                   Center(child: Text('No events yet')),
// //                 ],
// //               ),
// //             );
// //           }

// //           return RefreshIndicator(
// //             onRefresh: _refresh,
// //             child: ListView.builder(
// //               physics: const AlwaysScrollableScrollPhysics(),
// //               itemCount: events.length,
// //               itemBuilder: (context, index) {
// //                 final event = events[index];
// //                 return Card(
// //                   margin: const EdgeInsets.all(12),
// //                   child: ListTile(
// //                     onTap: () {
// //                       context.push('/club/event/${event.id}');
// //                     },
// //                     title: Text(event.title),
// //                     subtitle: Text(
// //   '${event.eventDate} • Proposal: ${event.proposalStatus} • Stage ${event.currentStage}',
// // ),
// //                     trailing: Text('${event.progressPct}%'),
// //                   ),
// //                 );
// //               },
// //             ),
// //           );
// //         },
// //       ),
// //     );
// //   }
// // }


// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:go_router/go_router.dart';

// import '../../models/event_model.dart';
// import '../../providers/auth_provider.dart';

// class ClubDashboardScreen extends ConsumerStatefulWidget {
//   const ClubDashboardScreen({super.key});

//   @override
//   ConsumerState<ClubDashboardScreen> createState() =>
//       _ClubDashboardScreenState();
// }

// class _ClubDashboardScreenState extends ConsumerState<ClubDashboardScreen> {
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
//             body: Center(child: Text('No user found')),
//           );
//         }

//         return DefaultTabController(
//           length: 2,
//           child: Scaffold(
//             appBar: AppBar(
//               title: const Text('Club Dashboard'),
//               bottom: const TabBar(
//                 tabs: [
//                   Tab(text: 'Active Events'),
//                   Tab(text: 'Past Events'),
//                 ],
//               ),
//             ),
//             floatingActionButton: FloatingActionButton(
//               onPressed: () async {
//                 final created = await context.push<bool>('/club/create-event');
//                 if (created == true) {
//                   await _refresh();
//                 }
//               },
//               child: const Icon(Icons.add),
//             ),
//             body: TabBarView(
//               children: [
//                 _ActiveEventsTab(
//                   reloadKey: _reloadKey,
//                   onRefresh: _refresh,
//                 ),
//                 _PastEventsTab(
//                   reloadKey: _reloadKey,
//                   role: user.role,
//                   onRefresh: _refresh,
//                 ),
//               ],
//             ),
//           ),
//         );
//       },
//       loading: () => const Scaffold(
//         body: Center(child: CircularProgressIndicator()),
//       ),
//       error: (error, _) => Scaffold(
//         body: Center(child: Text('Error: $error')),
//       ),
//     );
//   }
// }

// class _ActiveEventsTab extends ConsumerWidget {
//   final int reloadKey;
//   final Future<void> Function() onRefresh;

//   const _ActiveEventsTab({
//     required this.reloadKey,
//     required this.onRefresh,
//   });

//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     return FutureBuilder<List<EventModel>>(
//       key: ValueKey('active_$reloadKey'),
//       future: ref.read(eventServiceProvider).getEventsForCurrentUserClub(),
//       builder: (context, snapshot) {
//         if (snapshot.connectionState == ConnectionState.waiting) {
//           return const Center(child: CircularProgressIndicator());
//         }

//         if (snapshot.hasError) {
//           return Center(child: Text('Error: ${snapshot.error}'));
//         }

//         final events = (snapshot.data ?? [])
//             .where((event) => event.status != 'closed')
//             .toList();

//         if (events.isEmpty) {
//           return RefreshIndicator(
//             onRefresh: onRefresh,
//             child: ListView(
//               physics: const AlwaysScrollableScrollPhysics(),
//               children: const [
//                 SizedBox(height: 200),
//                 Center(child: Text('No active events')),
//               ],
//             ),
//           );
//         }

//         return RefreshIndicator(
//           onRefresh: onRefresh,
//           child: ListView.builder(
//             physics: const AlwaysScrollableScrollPhysics(),
//             itemCount: events.length,
//             itemBuilder: (context, index) {
//               final event = events[index];

//               return Card(
//                 margin: const EdgeInsets.all(12),
//                 child: ListTile(
//                   onTap: () {
//                     context.push('/club/event/${event.id}');
//                   },
//                   title: Text(event.title),
//                   subtitle: Text(
//                     '${event.eventDate} • Proposal: ${event.proposalStatus} • Stage ${event.currentStage}',
//                   ),
//                   trailing: Text('${event.progressPct}%'),
//                 ),
//               );
//             },
//           ),
//         );
//       },
//     );
//   }
// }

// class _PastEventsTab extends ConsumerWidget {
//   final int reloadKey;
//   final String role;
//   final Future<void> Function() onRefresh;

//   const _PastEventsTab({
//     required this.reloadKey,
//     required this.role,
//     required this.onRefresh,
//   });

//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     return FutureBuilder<List<EventModel>>(
//       key: ValueKey('past_$reloadKey'),
//       future: ref.read(eventServiceProvider).getArchivedEventsForRole(role),
//       builder: (context, snapshot) {
//         if (snapshot.connectionState == ConnectionState.waiting) {
//           return const Center(child: CircularProgressIndicator());
//         }

//         if (snapshot.hasError) {
//           return Center(child: Text('Error: ${snapshot.error}'));
//         }

//         final events = snapshot.data ?? [];

//         if (events.isEmpty) {
//           return RefreshIndicator(
//             onRefresh: onRefresh,
//             child: ListView(
//               physics: const AlwaysScrollableScrollPhysics(),
//               children: const [
//                 SizedBox(height: 200),
//                 Center(child: Text('No past events')),
//               ],
//             ),
//           );
//         }

//         return RefreshIndicator(
//           onRefresh: onRefresh,
//           child: ListView.builder(
//             physics: const AlwaysScrollableScrollPhysics(),
//             itemCount: events.length,
//             itemBuilder: (context, index) {
//               final event = events[index];

//               return Card(
//                 margin: const EdgeInsets.all(12),
//                 child: ListTile(
//                   onTap: () {
//                     context.push('/club/event/${event.id}');
//                   },
//                   title: Text(event.title),
//                   subtitle: Text(
//                     '${event.eventDate} • ${event.venue ?? '-'}',
//                   ),
//                   trailing: const Text('Closed'),
//                 ),
//               );
//             },
//           ),
//         );
//       },
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../models/event_model.dart';
import '../../providers/auth_provider.dart';
import 'shared_widgets.dart';

class ClubDashboardScreen extends ConsumerStatefulWidget {
  const ClubDashboardScreen({super.key});

  @override
  ConsumerState<ClubDashboardScreen> createState() => _ClubDashboardScreenState();
}

class _ClubDashboardScreenState extends ConsumerState<ClubDashboardScreen> {
  int _reloadKey = 0;

  Future<void> _refresh() async {
    setState(() { _reloadKey++; });
  }

  @override
  Widget build(BuildContext context) {
    final userAsync = ref.watch(currentUserProfileProvider);

    return userAsync.when(
      data: (user) {
        if (user == null) {
          return const Scaffold(body: Center(child: Text('No user found')));
        }
        return DefaultTabController(
          length: 2,
          child: Scaffold(
            backgroundColor: const Color(0xFFF4F6FB),
            appBar: AppBar(
              backgroundColor: Colors.white,
              elevation: 0,
              surfaceTintColor: Colors.transparent,
              title: const Text(
                'Club Dashboard',
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: Color(0xFF1A1F36)),
              ),
              bottom: PreferredSize(
                preferredSize: const Size.fromHeight(49),
                child: Column(
                  children: [
                    Divider(height: 1, color: Colors.grey.shade200),
                    TabBar(
                      labelColor: const Color(0xFF3B5BDB),
                      unselectedLabelColor: Colors.grey.shade500,
                      labelStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                      unselectedLabelStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w400),
                      indicatorColor: const Color(0xFF3B5BDB),
                      indicatorWeight: 2.5,
                      tabs: const [Tab(text: 'Active Events'), Tab(text: 'Past Events')],
                    ),
                  ],
                ),
              ),
            ),
            floatingActionButton: FloatingActionButton(
              onPressed: () async {
                final created = await context.push<bool>('/club/create-event');
                if (created == true) await _refresh();
              },
              backgroundColor: const Color(0xFF3B5BDB),
              foregroundColor: Colors.white,
              elevation: 2,
              child: const Icon(Icons.add),
            ),
            body: TabBarView(
              children: [
                _ActiveEventsTab(reloadKey: _reloadKey, onRefresh: _refresh),
                _PastEventsTab(reloadKey: _reloadKey, role: user.role, onRefresh: _refresh),
              ],
            ),
          ),
        );
      },
      loading: () => const Scaffold(body: Center(child: CircularProgressIndicator(color: Color(0xFF3B5BDB)))),
      error: (error, _) => Scaffold(body: Center(child: Text('Error: $error'))),
    );
  }
}

class _ActiveEventsTab extends ConsumerWidget {
  final int reloadKey;
  final Future<void> Function() onRefresh;
  const _ActiveEventsTab({required this.reloadKey, required this.onRefresh});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return FutureBuilder<List<EventModel>>(
      key: ValueKey('active_$reloadKey'),
      future: ref.read(eventServiceProvider).getEventsForCurrentUserClub(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator(color: Color(0xFF3B5BDB)));
        }
        if (snapshot.hasError) {
          return Center(child: Padding(padding: const EdgeInsets.all(24), child: Text('Error: ${snapshot.error}', style: const TextStyle(color: Color(0xFFDC2626), fontSize: 13))));
        }
        final events = (snapshot.data ?? []).where((e) => e.status != 'closed').toList();
        if (events.isEmpty) {
          return _EmptyEventsView(onRefresh: onRefresh, message: 'No active events');
        }
        return RefreshIndicator(
          color: const Color(0xFF3B5BDB),
          onRefresh: onRefresh,
          child: ListView.builder(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16),
            itemCount: events.length,
            itemBuilder: (context, index) {
              final event = events[index];
              return _EventCard(
                event: event,
                onTap: () => context.push('/club/event/${event.id}'),
                trailing: _ProgressBadge(pct: event.progressPct),
                subtitle: '${event.eventDate} • Stage ${event.currentStage}',
                statusLabel: event.proposalStatus,
              );
            },
          ),
        );
      },
    );
  }
}

class _PastEventsTab extends ConsumerWidget {
  final int reloadKey;
  final String role;
  final Future<void> Function() onRefresh;
  const _PastEventsTab({required this.reloadKey, required this.role, required this.onRefresh});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return FutureBuilder<List<EventModel>>(
      key: ValueKey('past_$reloadKey'),
      future: ref.read(eventServiceProvider).getArchivedEventsForRole(role),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator(color: Color(0xFF3B5BDB)));
        }
        if (snapshot.hasError) {
          return Center(child: Padding(padding: const EdgeInsets.all(24), child: Text('Error: ${snapshot.error}', style: const TextStyle(color: Color(0xFFDC2626), fontSize: 13))));
        }
        final events = snapshot.data ?? [];
        if (events.isEmpty) {
          return _EmptyEventsView(onRefresh: onRefresh, message: 'No past events');
        }
        return RefreshIndicator(
          color: const Color(0xFF3B5BDB),
          onRefresh: onRefresh,
          child: ListView.builder(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16),
            itemCount: events.length,
            itemBuilder: (context, index) {
              final event = events[index];
              return _EventCard(
                event: event,
                onTap: () => context.push('/club/event/${event.id}'),
                trailing: _ClosedBadge(),
                subtitle: '${event.eventDate} • ${event.venue ?? '-'}',
              );
            },
          ),
        );
      },
    );
  }
}

// ── Shared sub-widgets ───────────────────────────────────────────────────────

class _EventCard extends StatelessWidget {
  final EventModel event;
  final VoidCallback onTap;
  final Widget trailing;
  final String subtitle;
  final String? statusLabel;

  const _EventCard({
    required this.event,
    required this.onTap,
    required this.trailing,
    required this.subtitle,
    this.statusLabel,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Material(
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
                    color: const Color(0xFFEEF2FF),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.event_outlined, color: Color(0xFF3B5BDB), size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        event.title,
                        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF1A1F36)),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 3),
                      Text(subtitle, style: TextStyle(fontSize: 12, color: Colors.grey.shade500)),
                      if (statusLabel != null) ...[
                        const SizedBox(height: 5),
                        _ProposalChip(status: statusLabel!),
                      ],
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                trailing,
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ProgressBadge extends StatelessWidget {
  final int pct;
  const _ProgressBadge({required this.pct});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          '$pct%',
          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Color(0xFF3B5BDB)),
        ),
        const SizedBox(height: 4),
        SizedBox(
          width: 36,
          child: LinearProgressIndicator(
            value: pct / 100,
            backgroundColor: const Color(0xFFE0E7FF),
            color: const Color(0xFF3B5BDB),
            minHeight: 3,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
      ],
    );
  }
}

class _ClosedBadge extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text('Closed', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Colors.grey.shade500)),
    );
  }
}

class _ProposalChip extends StatelessWidget {
  final String status;
  const _ProposalChip({required this.status});

  @override
  Widget build(BuildContext context) {
    final s = status.toLowerCase();
    Color bg; Color fg;
    if (s.contains('approved')) { bg = const Color(0xFFF0FDF4); fg = const Color(0xFF16A34A); }
    else if (s.contains('reject')) { bg = const Color(0xFFFEF2F2); fg = const Color(0xFFDC2626); }
    else if (s.contains('changes')) { bg = const Color(0xFFFFFBEB); fg = const Color(0xFFD97706); }
    else { bg = const Color(0xFFEEF2FF); fg = const Color(0xFF3B5BDB); }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(5)),
      child: Text(status, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: fg)),
    );
  }
}

class _EmptyEventsView extends StatelessWidget {
  final Future<void> Function() onRefresh;
  final String message;
  const _EmptyEventsView({required this.onRefresh, required this.message});

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      color: const Color(0xFF3B5BDB),
      onRefresh: onRefresh,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          const SizedBox(height: 120),
          Icon(Icons.event_busy_outlined, size: 48, color: Colors.grey.shade300),
          const SizedBox(height: 12),
          Center(child: Text(message, style: TextStyle(fontSize: 14, color: Colors.grey.shade400))),
        ],
      ),
    );
  }
}