import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../controllers/nexus_controller.dart';
import '../widgets/post_card.dart';
import '../widgets/notifications.dart';

class FeedScreen extends ConsumerWidget {
  const FeedScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(nexusProvider),
        c = ref.read(nexusProvider.notifier),
        posts = ref.watch(rankedPostsProvider);
    return Stack(
      children: [
        PageView.builder(
          key: ValueKey('${s.filter}-${posts.length}'),
          scrollDirection: Axis.vertical,
          itemCount: posts.length,
          itemBuilder: (_, i) => PostCard(post: posts[i]),
        ),
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xDD0C0F11), Color(0x000C0F11)],
              ),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    for (final f in const [
                      ('foryou', 'For You'),
                      ('nearby', 'Nearby'),
                    ])
                      TextButton(
                        onPressed: () => c.filter(f.$1),
                        child: Text(
                          f.$2,
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            color: s.filter == f.$1
                                ? Colors.white
                                : Colors.white54,
                            decoration: s.filter == f.$1
                                ? TextDecoration.underline
                                : null,
                          ),
                        ),
                      ),
                    IconButton(
                      tooltip: 'Search',
                      onPressed: () => c.go('discover'),
                      icon: const Icon(Icons.search),
                    ),
                    IconButton(
                      tooltip: 'Notifications',
                      onPressed: () => showModalBottomSheet<void>(
                        context: context,
                        isScrollControlled: true,
                        builder: (_) => const FractionallySizedBox(
                          heightFactor: .92,
                          child: NotificationsPanel(),
                        ),
                      ),
                      icon: Badge(
                        isLabelVisible: s.notifications.any((n) => n.unread),
                        child: const Icon(Icons.notifications_none),
                      ),
                    ),
                  ],
                ),
                if (s.filter == 'nearby')
                  const Padding(
                    padding: EdgeInsets.all(8),
                    child: Text(
                      'Friends & following first · then people within 2 km',
                      style: TextStyle(fontSize: 11),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
