import '../core/router/app_router.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../providers/auth_provider.dart';
import '../providers/club_provider.dart';
import 'nav_config.dart';

class AppScaffold extends ConsumerWidget {
  final String? title;
  final String currentRoute;
  final Widget child;
  final bool showBottomNav;
  final Widget? floatingActionButton;
  final List<Widget>? actions;

  const AppScaffold({
    super.key,
    this.title,
    required this.currentRoute,
    required this.child,
    this.showBottomNav = true,
    this.floatingActionButton,
    this.actions,
  });

  static const _primary = Color(0xFF3B5BDB);
  static const _bg = Color(0xFFF4F6FB);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(currentUserProfileProvider);

    return userAsync.when(
      loading: () => const Scaffold(
        backgroundColor: _bg,
        body: Center(child: CircularProgressIndicator(color: _primary)),
      ),
      error: (e, _) => Scaffold(
        backgroundColor: _bg,
        body: Center(child: Text('Error: $e')),
      ),
      data: (user) {
        if (user == null) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator(color: _primary)),
          );
        }

        final tabs = tabsForRole(user.role);
        final currentIndex = _indexFor(tabs, currentRoute);

        return Scaffold(
          backgroundColor: _bg,
          appBar: _buildAppBar(context, ref, user),
          body: child,
          bottomNavigationBar: showBottomNav
              ? _buildBottomNav(context, tabs, currentIndex)
              : null,
          floatingActionButton: floatingActionButton,
        );
      },
    );
  }

  PreferredSizeWidget _buildAppBar(
    BuildContext context,
    WidgetRef ref,
    dynamic user,
  ) {
    String headerTitle;

    if (user.role == 'club_lead') {
      final clubAsync = ref.read(currentClubProvider);
      final clubName = clubAsync.whenOrNull(data: (c) => c?.clubName);
      headerTitle = title != null
          ? '$title - ${clubName ?? 'Club'}'
          : (clubName ?? 'ClubFlow');
    } else if (title != null) {
      headerTitle = title!;
    } else {
      headerTitle = 'ClubFlow';
    }

    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      surfaceTintColor: Colors.transparent,
      automaticallyImplyLeading: false,
      leading: Navigator.canPop(context)
      ? IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        )
      : null,
      title: Row(
        children: [
          Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              color: _primary,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.hub_rounded, color: Colors.white, size: 18),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              headerTitle,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: Color(0xFF1A1F36),
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
      actions: [
        Container(
          margin: const EdgeInsets.symmetric(vertical: 10),
          padding: const EdgeInsets.symmetric(horizontal: 10),
          decoration: BoxDecoration(
            color: const Color(0xFFEEF2FF),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Center(
            child: Text(
              roleLabel(user.role),
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: _primary,
              ),
            ),
          ),
        ),
        const SizedBox(width: 4),

        if (actions != null) ...actions!,

        IconButton(
          tooltip: 'Sign out',
          icon: const Icon(Icons.logout_rounded, size: 20, color: Color(0xFF64748B)),
          onPressed: () => _confirmLogout(context, ref),
        ),
        const SizedBox(width: 4),
      ],
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Divider(height: 1, color: Colors.grey.shade200),
      ),
    );
  }

  Widget _buildBottomNav(
    BuildContext context,
    List<NavTab> tabs,
    int currentIndex,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 60,
          child: Row(
            children: List.generate(tabs.length, (i) {
              final tab = tabs[i];
              final isActive = i == currentIndex;
              return Expanded(
                child: InkWell(
                  onTap: () {
                      context.go(tab.route);                    
                  },
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        isActive ? tab.activeIcon : tab.icon,
                        size: 22,
                        color: isActive ? _primary : const Color(0xFFADB5BD),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        tab.label,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: isActive ? FontWeight.w700 : FontWeight.w400,
                          color: isActive ? _primary : const Color(0xFFADB5BD),
                        ),
                      ),
                      const SizedBox(height: 3),
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        width: isActive ? 4 : 0,
                        height: isActive ? 4 : 0,
                        decoration: BoxDecoration(
                          color: _primary,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }

  int _indexFor(List<NavTab> tabs, String route) {
    for (int i = 0; i < tabs.length; i++) {
      if (tabs[i].route == route) return i;
    }
    for (int i = 0; i < tabs.length; i++) {
      if (route.startsWith(tabs[i].route) && tabs[i].route != '/') return i;
    }
    return 0;
  }

  Future<void> _confirmLogout(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Sign out?',
          style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
        ),
        content: const Text('Are you sure?.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: _primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Sign out'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      await ref.read(authServiceProvider).signOut();
      if (context.mounted) context.go(AppRoutes.login);
    }
  }
}