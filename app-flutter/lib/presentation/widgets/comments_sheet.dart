import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/models.dart';
import '../controllers/nexus_controller.dart';
import 'common.dart';

class CommentsSheet extends ConsumerWidget {
  const CommentsSheet({super.key, required this.post});
  final Post post;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(nexusProvider),
        c = ref.read(nexusProvider.notifier),
        entries = s.comments[post.id] ?? [];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'Comments (${entries.length})',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const Text('Reply as @you · comments notify the author'),
        ConstrainedBox(
          constraints: const BoxConstraints(maxHeight: 320),
          child: ListView(
            shrinkWrap: true,
            children: [
              for (final entry in entries)
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: CircleAvatar(
                    child: Text(entry.title.substring(0, 1)),
                  ),
                  title: Text(entry.title),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(entry.body),
                      Row(
                        children: [
                          TextButton(
                            onPressed: () => c.reply(entry),
                            child: const Text('Reply'),
                          ),
                          TextButton(
                            onPressed: () => c.likeComment(post, entry),
                            child: Text(entry.selected ? 'Liked' : 'Like'),
                          ),
                          Text(entry.subtitle),
                        ],
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
        if (s.replyTo.isNotEmpty) Text('Replying to ${s.replyTo}'),
        Row(
          children: [
            Expanded(
              child: NativeInput(
                value: s.commentDraft,
                onChanged: c.commentDraft,
                hint: 'Write a reply…',
                onSubmitted: () => c.sendComment(post),
              ),
            ),
            IconButton(
              tooltip: 'Send reply',
              onPressed: () => c.sendComment(post),
              icon: const Icon(Icons.send),
            ),
          ],
        ),
      ],
    );
  }
}
