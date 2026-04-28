import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../models/event_model.dart';
import '../../providers/auth_provider.dart';

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

class EventArchiveScreen extends ConsumerStatefulWidget {
  const EventArchiveScreen({super.key});

  @override
  ConsumerState<EventArchiveScreen> createState() => _EventArchiveScreenState();
}

class _EventArchiveScreenState extends ConsumerState<EventArchiveScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<EventModel> _allEvents = [];
  List<EventModel> _filteredEvents = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
    _loadEvents();
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    final query = _searchController.text.toLowerCase().trim();
    setState(() {
      _filteredEvents = _allEvents.where((event) {
        final title = event.title.toLowerCase();
        final clubName = (event.clubName ?? '').toLowerCase();
        final clubCode = (event.clubCode ?? '').toLowerCase();
        return title.contains(query) ||
            clubName.contains(query) ||
            clubCode.contains(query);
      }).toList();
    });
  }

  Future<void> _loadEvents() async {
    final userAsync = ref.read(currentUserProfileProvider);
    final user = userAsync.value;
    if (user == null) return;

    try {
      final events = await ref
          .read(eventServiceProvider)
          .getArchivedEventsForRole(user.role);
      setState(() {
        _allEvents = events;
        _filteredEvents = events;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final userAsync = ref.watch(currentUserProfileProvider);

    return userAsync.when(
      data: (user) {
        if (user == null) {
          return Scaffold(
            backgroundColor: ERPTheme.bgPage,
            appBar: _buildAppBar('Event Archive'),
            body: const Center(child: Text('No user found')),
          );
        }

        if (_isLoading) {
          return Scaffold(
            backgroundColor: ERPTheme.bgPage,
            appBar: _buildAppBar('Event Archive'),
            body: const Center(
              child: CircularProgressIndicator(color: ERPTheme.primary),
            ),
          );
        }

        return Scaffold(
          backgroundColor: ERPTheme.bgPage,
          appBar: _buildAppBar('Event Archive'),
          body: Column(
            children: [
              // Search bar
              Container(
                color: Colors.white,
                padding: const EdgeInsets.all(16),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: ERPTheme.divider),
                    boxShadow: [
                      BoxShadow(
                        color: ERPTheme.primary.withOpacity(0.06),
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: TextField(
                    controller: _searchController,
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
                        color: ERPTheme.primary,
                        size: 20,
                      ),
                      suffixIcon: _searchController.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(
                                Icons.close_rounded,
                                color: ERPTheme.textSecondary,
                                size: 18,
                              ),
                              onPressed: () {
                                _searchController.clear();
                                _onSearchChanged();
                              },
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
                  ),
                ),
              ),

              // Results count
              if (_filteredEvents.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 20, vertical: 8),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      '${_filteredEvents.length} event${_filteredEvents.length == 1 ? '' : 's'} found',
                      style: const TextStyle(
                        color: ERPTheme.textSecondary,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),

              // List
              Expanded(
                child: _filteredEvents.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
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
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        itemCount: _filteredEvents.length,
                        itemBuilder: (context, index) {
                          final event = _filteredEvents[index];
                          return _EventCard(event: event);
                        },
                      ),
              ),
            ],
          ),
        );
      },
      loading: () => Scaffold(
        backgroundColor: ERPTheme.bgPage,
        appBar: _buildAppBar('Event Archive'),
        body: const Center(
          child: CircularProgressIndicator(color: ERPTheme.primary),
        ),
      ),
      error: (error, _) => Scaffold(
        backgroundColor: ERPTheme.bgPage,
        appBar: _buildAppBar('Event Archive'),
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
    );
  }
}

class _EventCard extends StatelessWidget {
  final EventModel event;

  const _EventCard({required this.event});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: ERPTheme.cardDecoration,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          context.push('/club/event/${event.id}');
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
                  Icons.event_outlined,
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
                      event.clubName ?? 'Unknown Club',
                      style: const TextStyle(
                        color: ERPTheme.primary,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      event.title,
                      style: const TextStyle(
                        color: ERPTheme.textPrimary,
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    if (event.clubCode != null)
                      Text(
                        '(${event.clubCode})',
                        style: const TextStyle(
                          color: ERPTheme.textSecondary,
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    const SizedBox(height: 2),
                    Text(
                      '${event.eventDate}${event.venue != null ? ' • ${event.venue}' : ''}',
                      style: const TextStyle(
                        color: ERPTheme.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: ERPTheme.primarySurface,
                  borderRadius: BorderRadius.circular(20),
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
