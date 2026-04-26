import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

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

    if (profile == null) {
      context.go('/login');
      return;
    }

    switch (profile.role) {
      case 'club_lead':
        context.go('/club');
        break;
      case 'proposal_approver':
        context.go('/proposal-approver');
        break;
      case 'budget_approver':
        context.go('/budget-approver');
        break;
      case 'admin':
        context.go('/admin');
        break;
      default:
        context.go('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }
}