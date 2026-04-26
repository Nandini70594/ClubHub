// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:go_router/go_router.dart';

// import '../../models/event_model.dart';
// import '../../providers/auth_provider.dart';

// class EventArchiveScreen extends ConsumerStatefulWidget {
//   const EventArchiveScreen({super.key});

//   @override
//   ConsumerState<EventArchiveScreen> createState() => _EventArchiveScreenState();
// }

// class _EventArchiveScreenState extends ConsumerState<EventArchiveScreen> {
//   String _search = '';

//   @override
//   Widget build(BuildContext context) {
//     final userAsync = ref.watch(currentUserProfileProvider);

//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Event Archive'),
//       ),
//       body: userAsync.when(
//         data: (user) {
//           if (user == null) {
//             return const Center(child: Text('No user found'));
//           }

//           return FutureBuilder<List<EventModel>>(
//             future: ref
//                 .read(eventServiceProvider)
//                 .getArchivedEventsForRole(user.role),
//             builder: (context, snapshot) {
//               if (snapshot.connectionState == ConnectionState.waiting) {
//                 return const Center(child: CircularProgressIndicator());
//               }

//               if (snapshot.hasError) {
//                 return Center(child: Text('Error: ${snapshot.error}'));
//               }

//               var events = snapshot.data ?? [];

//               final query = _search.toLowerCase().trim();

//               events = events.where((event) {
//                 final title = event.title.toLowerCase();
//                 final clubName = (event.clubName ?? '').toLowerCase();
//                 final clubCode = (event.clubCode ?? '').toLowerCase();

//                 return title.contains(query) ||
//                     clubName.contains(query) ||
//                     clubCode.contains(query);
//               }).toList();

//               return Column(
//                 children: [
//                   Padding(
//                     padding: const EdgeInsets.all(12),
//                     child: TextField(
//                       decoration: const InputDecoration(
//                         hintText: 'Search by event name or club',
//                         prefixIcon: Icon(Icons.search),
//                         border: OutlineInputBorder(),
//                       ),
//                       onChanged: (value) {
//                         setState(() {
//                           _search = value;
//                         });
//                       },
//                     ),
//                   ),
//                   Expanded(
//                     child: events.isEmpty
//                         ? const Center(child: Text('No archived events found'))
//                         : ListView.builder(
//                             itemCount: events.length,
//                             itemBuilder: (context, index) {
//                               final event = events[index];

//                               return Card(
//                                 margin: const EdgeInsets.symmetric(
//                                   horizontal: 12,
//                                   vertical: 8,
//                                 ),
//                                 child: ListTile(
//                                   onTap: () {
//                                     context.push('/club/event/${event.id}');
//                                   },
//                                   title: Text(event.title),
//                                   subtitle: Text(
//                                     '${event.clubName ?? 'Club'}'
//                                     '${event.clubCode != null ? ' (${event.clubCode})' : ''}\n'
//                                     '${event.eventDate} • ${event.venue ?? '-'}',
//                                   ),
//                                   trailing: const Chip(
//                                     label: Text('Closed'),
//                                   ),
//                                 ),
//                               );
//                             },
//                           ),
//                   ),
//                 ],
//               );
//             },
//           );
//         },
//         loading: () => const Center(child: CircularProgressIndicator()),
//         error: (error, _) => Center(child: Text('Error: $error')),
//       ),
//     );
//   }
// }


import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../models/event_model.dart';
import '../../providers/auth_provider.dart';

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

class EventArchiveScreen extends ConsumerStatefulWidget {
  const EventArchiveScreen({super.key});

  @override
  ConsumerState<EventArchiveScreen> createState() => _EventArchiveScreenState();
}

class _EventArchiveScreenState extends ConsumerState<EventArchiveScreen> {
  String _search = '';

  @override
  Widget build(BuildContext context) {
    final userAsync = ref.watch(currentUserProfileProvider);

    return Scaffold(
      backgroundColor: ERPTheme.bgPage,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        flexibleSpace: Container(
          decoration: BoxDecoration(gradient: ERPTheme.headerGradient),
        ),
        title: const Text(
          'Event Archive',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 18,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: userAsync.when(
        data: (user) {
          if (user == null) {
            return const Center(child: Text('No user found'));
          }

          return FutureBuilder<List<EventModel>>(
            future: ref
                .read(eventServiceProvider)
                .getArchivedEventsForRole(user.role),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(color: ERPTheme.primary),
                );
              }

              if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              }

              var events = snapshot.data ?? [];

              final query = _search.toLowerCase().trim();

              events = events.where((event) {
                final title = event.title.toLowerCase();
                final clubName = (event.clubName ?? '').toLowerCase();
                final clubCode = (event.clubCode ?? '').toLowerCase();
                return title.contains(query) ||
                    clubName.contains(query) ||
                    clubCode.contains(query);
              }).toList();

              return Column(
                children: [
                  // ── Search Bar ───────────────────────────────────────
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                    child: Container(
                      decoration: ERPTheme.cardDecoration,
                      child: TextField(
                        style: const TextStyle(
                          color: ERPTheme.textPrimary,
                          fontSize: 14,
                        ),
                        decoration: InputDecoration(
                          hintText: 'Search by event name or club...',
                          hintStyle: const TextStyle(
                            color: ERPTheme.textSecondary,
                            fontSize: 14,
                          ),
                          prefixIcon: const Icon(
                            Icons.search_rounded,
                            color: ERPTheme.accent,
                            size: 20,
                          ),
                          suffixIcon: _search.isNotEmpty
                              ? IconButton(
                                  icon: const Icon(
                                    Icons.close_rounded,
                                    color: ERPTheme.textSecondary,
                                    size: 18,
                                  ),
                                  onPressed: () =>
                                      setState(() => _search = ''),
                                )
                              : null,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          filled: true,
                          fillColor: Colors.white,
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 14),
                        ),
                        onChanged: (value) {
                          setState(() {
                            _search = value;
                          });
                        },
                      ),
                    ),
                  ),

                  // ── Results count label ──────────────────────────────
                  if (events.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 4),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          '${events.length} event${events.length == 1 ? '' : 's'} found',
                          style: const TextStyle(
                            color: ERPTheme.textSecondary,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),

                  // ── List ─────────────────────────────────────────────
                  Expanded(
                    child: events.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(20),
                                  decoration: const BoxDecoration(
                                    color: ERPTheme.primarySurface,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.archive_outlined,
                                    size: 40,
                                    color: ERPTheme.primary,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                const Text(
                                  'No archived events found',
                                  style: TextStyle(
                                    color: ERPTheme.textSecondary,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
                            itemCount: events.length,
                            itemBuilder: (context, index) {
                              final event = events[index];
                              return Container(
                                margin: const EdgeInsets.only(bottom: 10),
                                decoration: ERPTheme.cardDecoration,
                                child: InkWell(
                                  borderRadius: BorderRadius.circular(12),
                                  onTap: () {
                                    context.push('/club/event/${event.id}');
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.all(14),
                                    child: Row(
                                      children: [
                                        Container(
                                          width: 44,
                                          height: 44,
                                          decoration: BoxDecoration(
                                            color: ERPTheme.primarySurface,
                                            borderRadius:
                                                BorderRadius.circular(10),
                                          ),
                                          child: const Icon(
                                            Icons.event_outlined,
                                            color: ERPTheme.primary,
                                            size: 22,
                                          ),
                                        ),
                                        const SizedBox(width: 14),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                event.title,
                                                style: const TextStyle(
                                                  color: ERPTheme.textPrimary,
                                                  fontWeight: FontWeight.w600,
                                                  fontSize: 14,
                                                ),
                                                maxLines: 1,
                                                overflow:
                                                    TextOverflow.ellipsis,
                                              ),
                                              const SizedBox(height: 4),
                                              Text(
                                                [
                                                  if (event.clubName != null)
                                                    event.clubName!,
                                                  if (event.clubCode != null)
                                                    '(${event.clubCode})',
                                                ].join(' '),
                                                style: const TextStyle(
                                                  color: ERPTheme.primary,
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                              const SizedBox(height: 2),
                                              Text(
                                                '${event.eventDate}${event.venue != null ? ' • ${event.venue}' : ''}',
                                                style: const TextStyle(
                                                  color:
                                                      ERPTheme.textSecondary,
                                                  fontSize: 12,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 10, vertical: 4),
                                          decoration: BoxDecoration(
                                            color: ERPTheme.primarySurface,
                                            borderRadius:
                                                BorderRadius.circular(20),
                                          ),
                                          child: const Text(
                                            'Closed',
                                            style: TextStyle(
                                              color: ERPTheme.primary,
                                              fontSize: 11,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                  ),
                ],
              );
            },
          );
        },
        loading: () => const Center(
          child: CircularProgressIndicator(color: ERPTheme.primary),
        ),
        error: (error, _) => Center(child: Text('Error: $error')),
      ),
    );
  }
}