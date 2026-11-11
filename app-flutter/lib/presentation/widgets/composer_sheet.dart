import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../controllers/nexus_controller.dart';
import 'common.dart';

class ComposerSheet extends ConsumerWidget {
  const ComposerSheet({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(nexusProvider), c = ref.read(nexusProvider.notifier);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          s.repost == null ? 'Share something' : 'Share to your profile',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        Text(
          s.repost == null
              ? 'Two taps is enough. Pick a type, write one line.'
              : 'Add your own words — the original stays credited',
        ),
        const SizedBox(height: 14),
        Wrap(
          spacing: 8,
          children: [
            for (final item in const [
              ('feel', 'Feeling', Icons.favorite),
              ('photo', 'Photo', Icons.photo_camera),
              ('loc', 'Nearby', Icons.place),
              ('biz', 'Business', Icons.storefront),
            ])
              ChoiceChip(
                selected: s.kind == item.$1,
                onSelected: (_) => c.kind(item.$1),
                avatar: Icon(item.$3, size: 21),
                label: Text(item.$2),
              ),
          ],
        ),
        const SizedBox(height: 10),
        NativeInput(
          value: s.draft,
          onChanged: c.draft,
          lines: 3,
          maxLength: 200,
          hint: s.kind == 'feel'
              ? 'Share why you feel ${s.mood.toLowerCase()}…'
              : s.kind == 'loc'
              ? 'What makes this place worth a visit?'
              : 'Add a caption for your photo…',
        ),
        Wrap(
          spacing: 7,
          children: [
            for (final mood in const [
              'Grateful',
              'Hopeful',
              'Missing home',
              'Tired',
              'Proud',
            ])
              ChoiceChip(
                selected: s.mood == mood,
                onSelected: (_) => c.mood(mood),
                label: Text(mood),
              ),
          ],
        ),
        ListTile(
          contentPadding: EdgeInsets.zero,
          leading: const Icon(Icons.place),
          title: const Text('Inya Lake, Yangon'),
          subtitle: const Text('Shown to people within 2 km'),
          trailing: TextButton(
            onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Location picker — Inya Lake, Yangon'),
              ),
            ),
            child: const Text('Change'),
          ),
        ),
        FilledButton(
          onPressed: ref.watch(canPostProvider)
              ? () async {
                  await c.publish();
                  if (context.mounted &&
                      ref.read(nexusProvider).error == null) {
                    Navigator.pop(context);
                  }
                }
              : null,
          child: Text(
            s.repost != null
                ? 'Share post'
                : s.kind == 'feel'
                ? 'Post to Nearby'
                : s.kind == 'loc'
                ? 'Share this place'
                : 'Post photo',
          ),
        ),
      ],
    );
  }
}
