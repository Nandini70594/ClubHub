import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/router/app_router.dart';
import '../../providers/auth_provider.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkUser();
  }

  Future<void> _checkUser() async {
    final profile = await ref.read(currentUserProfileProvider.future);
    if (!mounted) return;

    final route = initialRouteForRole(profile?.role);

    // Replace splash so the user can't go back to it
    context.go(route);
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Color(0xFFF4F6FB),
      body: Center(
        child: CircularProgressIndicator(color: Color(0xFF3B5BDB)),
      ),
    );
  }
}
