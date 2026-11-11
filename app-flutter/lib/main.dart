import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'data/api_client.dart';
import 'data/mock_repository.dart';
import 'data/real_repository.dart';
import 'data/vault.dart';
import 'domain/repository.dart';
import 'presentation/controllers/auth_controller.dart';
import 'presentation/controllers/providers.dart';
import 'presentation/screens/auth_screen.dart';
import 'presentation/screens/home_shell.dart';
import 'presentation/theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  const mock = bool.fromEnvironment('NEXUS_MOCK', defaultValue: false);
  const base = String.fromEnvironment('NEXUS_API_URL');
  final NexusRepository repo = mock
      ? await MockRepository.load()
      : RealRepository(ApiClient(base, SecureVault()));
  runApp(
    ProviderScope(
      overrides: [repositoryProvider.overrideWithValue(repo)],
      child: const NexusApp(),
    ),
  );
}

class NexusApp extends ConsumerWidget {
  const NexusApp({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) => MaterialApp(
    title: 'Nexus',
    debugShowCheckedModeBanner: false,
    theme: Tokens.dark,
    home: ref.watch(authProvider.select((s) => s.stage)) == 'home'
        ? const HomeShell()
        : const AuthScreen(),
  );
}
