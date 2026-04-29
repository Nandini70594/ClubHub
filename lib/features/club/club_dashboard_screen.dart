import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/router/app_router.dart';
import '../../models/event_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/club_provider.dart';
import '../../widgets/app_scaffold.dart';
import 'package:go_router/go_router.dart';

class ClubDashboardScreen extends ConsumerStatefulWidget {
  const ClubDashboardScreen({super.key});

  @override
  ConsumerState<ClubDashboardScreen> createState() => _ClubDashboardScreenState();
}

class _ClubDashboardScreenState extends ConsumerState<ClubDashboardScreen> {
  int _reloadKey = 0;

  Future<void> _refresh() async => setState(() => _reloadKey++);

  @override
  Widget build(BuildContext context) {
    final userAsync   = ref.watch(currentUserProfileProvider);
    final clubAsync   = ref.watch(currentClubProvider);
    final clubName    = clubAsync.whenOrNull(data: (c) => c?.clubName);

    return userAsync.when(
      loading: () => const AppScaffold(
        currentRoute: AppRoutes.club,
        child: Center(child: CircularProgressIndicator(color: Color(0xFF3B5BDB))),
      ),
      error: (e, _) => AppScaffold(
        currentRoute: AppRoutes.club,
        child: Center(child: Text('Error: $e')),
      ),
      data: (user) {
        if (user == null) {
          return const AppScaffold(
            currentRoute: AppRoutes.club,
            child: Center(child: Text('No user found')),
          );
        }

        return DefaultTabController(
          length: 2,
          child: AppScaffold(
            title: 'ClubHub',
            currentRoute: AppRoutes.club,
            child: Column(
              children: [
                Container(
                  color: Colors.white,
                  child: TabBar(
                    labelColor: const Color(0xFF3B5BDB),
                    unselectedLabelColor: Colors.grey.shade500,
                    labelStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                    unselectedLabelStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w400),
                    indicatorColor: const Color(0xFF3B5BDB),
                    indicatorWeight: 2.5,
                    tabs: const [Tab(text: 'Active Events'), Tab(text: 'Past Events')],
                  ),
                ),
                Divider(height: 1, color: Colors.grey.shade200),
                Expanded(
                  child: TabBarView(
                    children: [
                      _ActiveEventsTab(reloadKey: _reloadKey, onRefresh: _refresh),
                      _PastEventsTab(
                        key: ValueKey('past_tab_$_reloadKey'),
                        role: user.role,
                        onRefresh: _refresh,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
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
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Text('Error: ${snapshot.error}',
                  style: const TextStyle(color: Color(0xFFDC2626), fontSize: 13)),
            ),
          );
        }
        final events = (snapshot.data ?? []).where((e) => e.status != 'closed').toList();
        if (events.isEmpty) return _EmptyView(onRefresh: onRefresh, message: 'No active events');

        return RefreshIndicator(
          color: const Color(0xFF3B5BDB),
          onRefresh: onRefresh,
          child: ListView.builder(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16),
            itemCount: events.length,
            itemBuilder: (context, i) {
              final event = events[i];
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

class _PastEventsTab extends ConsumerStatefulWidget {
  final String role;
  final Future<void> Function() onRefresh;
  const _PastEventsTab({super.key, required this.role, required this.onRefresh});

  @override
  ConsumerState<_PastEventsTab> createState() => _PastEventsTabState();
}

class _PastEventsTabState extends ConsumerState<_PastEventsTab> {
  final _searchController = TextEditingController();
  String _query  = '';
  List<EventModel>? _allEvents;
  bool   _loading = true;
  String? _error;
  Timer? _debounceTimer;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearch);
    _fetchEvents();
  }

  void _onSearch() {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 300), () {
      if (mounted) {
        final newQuery = _searchController.text.toLowerCase();
        if (_query != newQuery) {
          setState(() => _query = newQuery);
        }
      }
    });
  }

  Future<void> _fetchEvents() async {
    setState(() { _loading = true; _error = null; });
    try {
      final events = await ref.read(eventServiceProvider).getArchivedEventsForRole(widget.role);
      if (mounted) setState(() { _allEvents = events; _loading = false; });
    } catch (e) {
      if (mounted) setState(() { _error = e.toString(); _loading = false; });
    }
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _searchController.removeListener(_onSearch);
    _searchController.dispose();
    super.dispose();
  }

  List<EventModel> get _filtered {
    if (_query.isEmpty) return _allEvents ?? [];
    return (_allEvents ?? []).where((e) =>
      e.title.toLowerCase().contains(_query) ||
      (e.venue?.toLowerCase().contains(_query) ?? false) ||
      e.eventDate.toLowerCase().contains(_query),
    ).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
          child: TextField(
            controller: _searchController,
            style: const TextStyle(fontSize: 14, color: Color(0xFF1A1F36)),
            decoration: InputDecoration(
              hintText: 'Search past events…',
              hintStyle: TextStyle(fontSize: 14, color: Colors.grey.shade400),
              prefixIcon: const Icon(Icons.search, size: 20, color: Color(0xFF9CA3AF)),
              suffixIcon: _query.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear, size: 18, color: Color(0xFF9CA3AF)),
                      onPressed: () {
                        _searchController.clear();
                        setState(() => _query = '');
                      },
                    )
                  : null,
              filled: true,
              fillColor: Colors.white,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey.shade200),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey.shade200),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFF3B5BDB), width: 1.5),
              ),
            ),
            onChanged: (value) {
              final newQuery = value.toLowerCase();
              if (_query != newQuery) {
                _debounceTimer?.cancel();
                _debounceTimer = Timer(const Duration(milliseconds: 300), () {
                  if (mounted) {
                    setState(() => _query = newQuery);
                  }
                });
              }
            },
          ),
        ),

        Expanded(
          child: _loading
              ? const Center(child: CircularProgressIndicator(color: Color(0xFF3B5BDB)))
              : _error != null
                  ? Center(child: Text('Error: $_error',
                        style: const TextStyle(color: Color(0xFFDC2626), fontSize: 13)))
                  : _filtered.isEmpty
                      ? _EmptyView(
                          onRefresh: widget.onRefresh,
                          message: _query.isEmpty ? 'No past events' : 'No results for "$_query"',
                        )
                      : RefreshIndicator(
                          color: const Color(0xFF3B5BDB),
                          onRefresh: () async {
                            await _fetchEvents();
                            await widget.onRefresh();
                          },
                          child: ListView.builder(
                            physics: const AlwaysScrollableScrollPhysics(),
                            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                            itemCount: _filtered.length,
                            itemBuilder: (context, i) {
                              final event = _filtered[i];
                              return _EventCard(
                                event: event,
                                onTap: () => context.push('/club/event/${event.id}'),
                                trailing: _ClosedBadge(),
                                subtitle: '${event.eventDate} • ${event.venue ?? '-'}',
                              );
                            },
                          ),
                        ),
        ),
      ],
    );
  }
}

class _EventCard extends StatelessWidget {
  final EventModel event;
  final VoidCallback onTap;
  final Widget trailing;
  final String subtitle;
  final String? statusLabel;

  const _EventCard({
    required this.event, required this.onTap,
    required this.trailing, required this.subtitle, this.statusLabel,
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
                  width: 44, height: 44,
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
                      Text(event.title,
                          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF1A1F36)),
                          maxLines: 1, overflow: TextOverflow.ellipsis),
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
        Text('$pct%', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Color(0xFF3B5BDB))),
        const SizedBox(height: 4),
        SizedBox(
          width: 36,
          child: LinearProgressIndicator(value: pct / 100,
              backgroundColor: const Color(0xFFE0E7FF),
              color: const Color(0xFF3B5BDB),
              minHeight: 3, borderRadius: BorderRadius.circular(2)),
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
      decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(6)),
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
    Color bg, fg;
    if (s.contains('approved'))     { bg = const Color(0xFFF0FDF4); fg = const Color(0xFF16A34A); }
    else if (s.contains('reject'))  { bg = const Color(0xFFFEF2F2); fg = const Color(0xFFDC2626); }
    else if (s.contains('changes')) { bg = const Color(0xFFFFFBEB); fg = const Color(0xFFD97706); }
    else                            { bg = const Color(0xFFEEF2FF); fg = const Color(0xFF3B5BDB); }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(5)),
      child: Text(status, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: fg)),
    );
  }
}

class _EmptyView extends StatelessWidget {
  final Future<void> Function() onRefresh;
  final String message;
  const _EmptyView({required this.onRefresh, required this.message});
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
          Center(child: Text(message,
              style: TextStyle(fontSize: 14, color: Colors.grey.shade400))),
        ],
      ),
    );
  }
}
