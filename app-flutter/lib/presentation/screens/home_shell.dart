import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../controllers/nexus_controller.dart';
import '../theme.dart';
import '../widgets/sheets.dart';
import 'feed_screen.dart';
import 'chat_screen.dart';
import 'profile_screen.dart';
import 'discover_screen.dart';
import 'shop_screen.dart';
import 'group_screen.dart';

class HomeShell extends ConsumerStatefulWidget {
  const HomeShell({super.key});
  @override
  ConsumerState<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends ConsumerState<HomeShell> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(nexusProvider.notifier).load());
  }

  @override
  Widget build(BuildContext context) {
    final s = ref.watch(nexusProvider), c = ref.read(nexusProvider.notifier);
    final light = s.screen == 'profile';
    return Scaffold(
      backgroundColor: light ? Tokens.paper : Tokens.surface,
      body: SafeArea(
        child: Column(
          children: [
            if (s.error != null)
              MaterialBanner(
                content: Text(s.error!),
                actions: [
                  TextButton(onPressed: c.load, child: const Text('Retry')),
                  TextButton(
                    onPressed: c.clearError,
                    child: const Text('Dismiss'),
                  ),
                ],
              ),
            if (s.busy) const LinearProgressIndicator(),
            Expanded(
              child: switch (s.screen) {
                'chat' => const ChatScreen(),
                'profile' => const ProfileScreen(),
                'discover' => const DiscoverScreen(),
                'business' => const ShopScreen(),
                'group' => const GroupScreen(),
                _ => const FeedScreen(),
              },
            ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        height: 64,
        decoration: BoxDecoration(
          color: light ? Tokens.paper : const Color(0xFF101315),
          border: Border(
            top: BorderSide(color: light ? Tokens.line : Tokens.card2),
          ),
        ),
        child: SafeArea(
          top: false,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              for (final item in const [
                ('feed', Icons.home),
                ('discover', Icons.search),
                ('create', Icons.add_box),
                ('chat', Icons.chat_bubble),
                ('profile', Icons.person),
              ])
                IconButton(
                  tooltip: item.$1 == 'create' ? 'Share something' : item.$1,
                  color: s.screen == item.$1
                      ? (light ? Tokens.ink : Colors.white)
                      : Tokens.muted,
                  onPressed: () => item.$1 == 'create'
                      ? openComposer(context, ref)
                      : c.go(item.$1),
                  icon: Icon(item.$2),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
