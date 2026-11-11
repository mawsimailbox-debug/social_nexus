import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../controllers/nexus_controller.dart';
import '../theme.dart';
import 'comments_sheet.dart';
import 'sheets.dart';

class NotificationsPanel extends ConsumerWidget {
  const NotificationsPanel({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(nexusProvider), c = ref.read(nexusProvider.notifier);
    return Column(
      children: [
        Row(
          children: [
            const SizedBox(width: 16),
            const Expanded(
              child: Text(
                'Notifications',
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800),
              ),
            ),
            TextButton(
              onPressed: () => c.markRead(),
              child: const Text('Mark all read'),
            ),
            IconButton(
              tooltip: 'Close',
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.close),
            ),
          ],
        ),
        Expanded(
          child: ListView(
            children: [
              for (final n in s.notifications)
                ListTile(
                  tileColor: n.unread ? Tokens.tan.withValues(alpha: .1) : null,
                  leading: Icon(switch (n.category) {
                    'comment' => Icons.chat_bubble,
                    'react' => Icons.favorite,
                    'share' => Icons.ios_share,
                    'group' => Icons.groups,
                    _ => Icons.storefront,
                  }, color: Tokens.tan),
                  title: Text(n.title, style: const TextStyle(fontSize: 12.5)),
                  subtitle: Text(n.subtitle),
                  onTap: () {
                    c.markRead(n);
                    Navigator.pop(context);
                    switch (n.category) {
                      case 'group':
                        c.go('group');
                      case 'biz':
                        c.go('business');
                      case 'comment':
                        final matches = s.posts.where(
                          (p) => p.id == (n.target.isEmpty ? 'p2' : n.target),
                        );
                        if (matches.isNotEmpty) {
                          final post = matches.first;
                          c.comments(post);
                          openSheet(context, CommentsSheet(post: post));
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Notification target is not loaded.',
                              ),
                            ),
                          );
                        }
                      default:
                        ScaffoldMessenger.of(context)
                            .showSnackBar(SnackBar(content: Text(n.title)));
                    }
                  },
                ),
            ],
          ),
        ),
      ],
    );
  }
}
