import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'core/config/env.dart';
import 'core/router/app_router.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

debugPrint("SUPABASE URL = ${Env.supabaseUrl}");
  debugPrint("SUPABASE KEY LENGTH = ${Env.supabaseAnonKey.length}");
  
  await Supabase.initialize(
    url: Env.supabaseUrl,
    anonKey: Env.supabaseAnonKey,
  );

  runApp(const ProviderScope(child: ClubFlowApp()));
}

class ClubFlowApp extends ConsumerWidget {
  const ClubFlowApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);

    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'ClubHub',
      routerConfig: router,
      theme: ThemeData(
        fontFamily: 'Inter',
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF3B5BDB),
        ),
        useMaterial3: true,
      ),
    );
  }
}
