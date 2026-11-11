import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/models.dart';
import '../controllers/nexus_controller.dart';
import '../theme.dart';
import 'sheets.dart';
import 'comments_sheet.dart';
import 'share_sheet.dart';

class PostActions extends ConsumerWidget {
  const PostActions({super.key, required this.post, this.vertical = false});
  final Post post;
  final bool vertical;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = ref.read(nexusProvider.notifier);
    final children = <Widget>[
      _Action(
        icon: post.liked ? Icons.favorite : Icons.favorite_border,
        label: '${post.likes}',
        color: post.liked ? Tokens.tan : null,
        vertical: vertical,
        onTap: () => c.like(post),
      ),
      _Action(
        icon: Icons.chat_bubble_outline,
        label: '${post.comments}',
        vertical: vertical,
        onTap: () {
          c.comments(post);
          openSheet(context, CommentsSheet(post: post));
        },
      ),
      _Action(
        icon: Icons.ios_share,
        label: vertical ? 'Share' : '${post.shares}',
        vertical: vertical,
        onTap: () => openSheet(context, ShareSheet(post: post)),
      ),
      _Action(
        icon: post.saved ? Icons.bookmark : Icons.bookmark_border,
        label: vertical ? '8,342' : '',
        color: post.saved ? Tokens.tan : null,
        vertical: vertical,
        onTap: () => c.save(post),
      ),
    ];
    return vertical
        ? Column(children: children)
        : Padding(
            padding: const EdgeInsets.only(top: 14),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: children,
            ),
          );
  }
}

class _Action extends StatelessWidget {
  const _Action({
    required this.icon,
    required this.label,
    required this.onTap,
    required this.vertical,
    this.color,
  });
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool vertical;
  final Color? color;
  @override
  Widget build(BuildContext context) {
    final content = [
      Icon(icon, color: color, size: vertical ? 27 : 19),
      if (label.isNotEmpty) Text(label, style: const TextStyle(fontSize: 11.5)),
    ];
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 3),
        child: vertical
            ? Column(children: content)
            : Row(spacing: 6, children: content),
      ),
    );
  }
}
