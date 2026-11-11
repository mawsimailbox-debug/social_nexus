import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';

import '../controllers/nexus_controller.dart';
import '../controllers/auth_controller.dart';
import '../theme.dart';
import '../widgets/common.dart';
import '../widgets/profile_grid.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(nexusProvider), c = ref.read(nexusProvider.notifier);
    return Theme(
      data: ThemeData.light(useMaterial3: true),
      child: DefaultTextStyle(
        style: const TextStyle(color: Tokens.ink, fontSize: 12.5, height: 1.55),
        child: ListView(
          children: [
            const SizedBox(
              height: 240,
              child: Stack(
                children: [
                  Photo(height: 210, width: double.infinity),
                  Positioned(
                    top: 164,
                    left: 18,
                    child: CircleAvatar(
                      radius: 38,
                      backgroundColor: Tokens.paper,
                      child: ClipOval(child: Photo(width: 70, height: 70)),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    s.profile['title'] as String? ?? '',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  Text(
                    s.profile['handle'] as String? ?? '',
                    style: const TextStyle(color: Tokens.muted),
                  ),
                  const SizedBox(height: 11),
                  Text(s.profile['bio'] as String? ?? ''),
                  const SizedBox(height: 14),
                  Material(
                    color: const Color(0xFFEDEAE4),
                    borderRadius: BorderRadius.circular(14),
                    child: ListTile(
                      leading: const Icon(Icons.storefront),
                      title: Text(
                        s.shop['title'] as String? ?? 'No shop available',
                        style: const TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      subtitle: Text(
                        s.shop['subtitle'] as String? ?? '',
                        style: const TextStyle(fontSize: 10.5),
                      ),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () => c.go('business'),
                    ),
                  ),
                  const SizedBox(height: 13),
                  Wrap(
                    spacing: 20,
                    children: [
                      for (final stat in s.profile['stats'] as List? ?? [])
                        Text(stat as String),
                    ],
                  ),
                  const SizedBox(height: 15),
                  Row(
                    children: [
                      Expanded(
                        child: FilledButton(
                          onPressed: () => showDialog<void>(
                            context: context,
                            builder: (_) => const _EditProfile(),
                          ),
                          child: const Text('Edit profile'),
                        ),
                      ),
                      IconButton(
                        tooltip: 'Share profile',
                        onPressed: () => SharePlus.instance.share(
                          ShareParams(
                            text:
                                '${s.profile['title']} · ${s.profile['handle']}',
                          ),
                        ),
                        icon: const Icon(Icons.ios_share),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  ChoiceRow(
                    items: const ['Videos', 'Liked', 'Saved'],
                    value: s.profileTab,
                    onSelect: c.profileTab,
                  ),
                  const ProfileGrid(),
                  TextButton(
                    onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Feedback: contact your Nexus support team',
                        ),
                      ),
                    ),
                    child: const Text('Feedback'),
                  ),
                  TextButton(
                    onPressed: () => ref.read(authProvider.notifier).logout(),
                    child: const Text('Log out'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EditProfile extends ConsumerStatefulWidget {
  const _EditProfile();
  @override
  ConsumerState<_EditProfile> createState() => _EditProfileState();
}

class _EditProfileState extends ConsumerState<_EditProfile> {
  late final TextEditingController controller;
  @override
  void initState() {
    super.initState();
    controller = TextEditingController(
      text: ref.read(nexusProvider).profile['bio'] as String? ?? '',
    );
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: const Text('Edit profile'),
    content: TextField(controller: controller, maxLength: 200, maxLines: 3),
    actions: [
      TextButton(
        onPressed: () => Navigator.pop(context),
        child: const Text('Cancel'),
      ),
      TextButton(
        onPressed: () async {
          await ref.read(nexusProvider.notifier).editProfile(controller.text);
          if (context.mounted) Navigator.pop(context);
        },
        child: const Text('Save'),
      ),
    ],
  );
}
