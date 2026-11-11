import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/models.dart';
import '../controllers/nexus_controller.dart';
import '../theme.dart';
import 'common.dart';
import 'post_actions.dart';

class PostCard extends ConsumerWidget {
  const PostCard({super.key, required this.post});
  final Post post;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = ref.read(nexusProvider.notifier);
    final photo = ['video', 'loc', 'promo', 'photo'].contains(post.kind);
    return Stack(
      fit: StackFit.expand,
      children: [
        if (photo)
          const Photo()
        else
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topRight,
                end: Alignment.bottomLeft,
                colors: [
                  Color(0xFF3C3531),
                  Color(0xFF1A1F22),
                  Color(0xFF151A1D),
                ],
              ),
            ),
          ),
        if (photo)
          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
                colors: [
                  Color(0xF50A0D0F),
                  Color(0x440A0D0F),
                  Color(0x220A0D0F),
                ],
              ),
            ),
          ),
        Positioned(
          top: 82,
          left: 16,
          child: Chip(
            label: Text(post.location, style: const TextStyle(fontSize: 11)),
            avatar: const Icon(Icons.place, size: 13),
          ),
        ),
        Align(
          alignment: photo ? Alignment.bottomLeft : Alignment.center,
          child: SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(
              22,
              130,
              post.kind == 'video' ? 72 : 22,
              photo ? 40 : 32,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '✦ ${post.reason}',
                  style: const TextStyle(color: Colors.white54, fontSize: 10.5),
                ),
                const SizedBox(height: 18),
                if (post.title.isNotEmpty)
                  Text(
                    post.title,
                    style: TextStyle(
                      color: post.kind == 'feel' ? Tokens.tan : Colors.white,
                      fontWeight: FontWeight.w800,
                      fontSize: post.kind == 'feel' ? 11 : 19,
                      letterSpacing: post.kind == 'feel' ? 1.6 : 0,
                    ),
                  ),
                const SizedBox(height: 12),
                Text(
                  post.body,
                  style: TextStyle(
                    fontSize: photo ? 13 : 22,
                    height: 1.52,
                    fontWeight: photo ? FontWeight.w400 : FontWeight.w600,
                  ),
                ),
                if (post.originalId != null)
                  Container(
                    margin: const EdgeInsets.only(top: 12),
                    padding: const EdgeInsets.only(left: 11),
                    decoration: const BoxDecoration(
                      border: Border(
                        left: BorderSide(color: Tokens.tan, width: 3),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Originally by ${post.originalAuthor}',
                          style: const TextStyle(color: Tokens.tan),
                        ),
                        Text(post.originalBody ?? ''),
                      ],
                    ),
                  ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    const ClipOval(child: Photo(width: 38, height: 38)),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            post.author,
                            style: const TextStyle(fontWeight: FontWeight.w700),
                          ),
                          Text(
                            post.subtitle,
                            style: const TextStyle(
                              color: Tokens.muted,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                if (post.tags.isNotEmpty) Text(post.tags),
                if (post.music.isNotEmpty)
                  Text('♫ ${post.music}', style: const TextStyle(fontSize: 12)),
                if (post.kind == 'loc')
                  TextButton.icon(
                    onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Opening map preview')),
                    ),
                    icon: const Icon(Icons.map),
                    label: const Text('Open map'),
                  ),
                if (post.kind == 'promo')
                  Wrap(
                    spacing: 8,
                    children: [
                      FilledButton(
                        onPressed: () => c.go('business'),
                        child: const Text('View shop'),
                      ),
                      TextButton(
                        onPressed: () => c.go('business'),
                        child: const Text('Call'),
                      ),
                    ],
                  ),
                if (post.kind == 'grpcard')
                  Wrap(
                    spacing: 8,
                    children: [
                      FilledButton(
                        onPressed: () => c.go('group'),
                        child: const Text('View group'),
                      ),
                      TextButton(
                        onPressed: () => c.join(true),
                        child: const Text('Join group'),
                      ),
                    ],
                  ),
                if (post.kind != 'video') PostActions(post: post),
              ],
            ),
          ),
        ),
        if (post.kind == 'video')
          Positioned(
            right: 8,
            bottom: 140,
            child: PostActions(post: post, vertical: true),
          ),
      ],
    );
  }
}
