import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/presentation/providers/auth_provider.dart';
import 'features/auth/presentation/screens/login_screen.dart';
import 'features/collect/presentation/screens/collect_list_screen.dart';

class App extends ConsumerWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);

    return MaterialApp(
      title: 'Collecte CA',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      home: switch (authState) {
        AuthAuthenticated() => const CollectListScreen(),
        _ => const LoginScreen(),
      },
    );
  }
}
