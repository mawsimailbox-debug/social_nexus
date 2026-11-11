import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../controllers/nexus_controller.dart';
import '../controllers/providers.dart';
import '../controllers/device_actions.dart';
import '../theme.dart';
import '../widgets/common.dart';
import '../widgets/shop_content.dart';

class ShopScreen extends ConsumerWidget {
  const ShopScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(nexusProvider), c = ref.read(nexusProvider.notifier);
    final demo = ref.watch(repositoryProvider).isDemo;
    return Column(
      children: [
        Expanded(
          child: ListView(
            children: [
              SizedBox(
                height: 216,
                child: Stack(
                  children: [
                    const Photo(height: 190, width: double.infinity),
                    Positioned(
                      top: 12,
                      left: 14,
                      child: IconButton.filled(
                        tooltip: 'Back',
                        onPressed: () => c.go('discover'),
                        icon: const Icon(Icons.arrow_back_ios_new),
                      ),
                    ),
                    Positioned(
                      left: 18,
                      bottom: 0,
                      child: Container(
                        width: 76,
                        height: 76,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: Tokens.card,
                          borderRadius: BorderRadius.circular(22),
                          border: Border.all(color: Tokens.surface, width: 3),
                        ),
                        child: const Text(
                          'SK',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w800,
                            color: Tokens.tan,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(18, 10, 18, 18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      s.shop['title'] as String? ?? '',
                      style: const TextStyle(
                        fontSize: 19,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    if (demo)
                      const Text(
                        'Cafe & tea shop · Open · closes 21:00',
                        style: TextStyle(fontSize: 11.5, color: Tokens.muted),
                      ),
                    if (demo)
                      const Text(
                        '4.8 ★ (216) · 800 m away · 1.2k followers',
                        style: TextStyle(fontSize: 11.5, color: Tokens.muted),
                      ),
                    const SizedBox(height: 14),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        TextButton.icon(
                          onPressed: demo ? () => c.guard(callShop) : null,
                          icon: const Icon(Icons.call),
                          label: const Text('Call'),
                        ),
                        IconButton(
                          tooltip: 'Directions',
                          onPressed: demo ? () => c.guard(directions) : null,
                          icon: const Icon(Icons.directions),
                        ),
                        IconButton(
                          tooltip: 'Message',
                          onPressed: demo ? () => c.go('chat') : null,
                          icon: const Icon(Icons.chat_bubble),
                        ),
                        IconButton(
                          tooltip: 'Save shop',
                          onPressed: c.saveShop,
                          icon: const Icon(Icons.bookmark_border),
                        ),
                      ],
                    ),
                    const ShopContent(),
                  ],
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                child: FilledButton(
                  onPressed: demo ? () => c.guard(callShop) : null,
                  child: const Text('Call shop'),
                ),
              ),
              const SizedBox(width: 9),
              OutlinedButton(
                onPressed: demo ? () => c.guard(directions) : null,
                child: const Text('Directions'),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
