import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../controllers/nexus_controller.dart';
import '../theme.dart';
import '../widgets/common.dart';

class GroupScreen extends ConsumerWidget {
  const GroupScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(nexusProvider), c = ref.read(nexusProvider.notifier);
    return ListView(
      children: [
        SizedBox(
          height: 158,
          child: Stack(
            fit: StackFit.expand,
            children: [
              const Photo(alignment: Alignment(-.24, .24)),
              const DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Color(0x770A0D0F), Color(0xF514181A)],
                  ),
                ),
              ),
              Positioned(
                top: 12,
                left: 14,
                child: IconButton.filled(
                  tooltip: 'Back',
                  onPressed: () => c.go('discover'),
                  icon: const Icon(Icons.arrow_back_ios_new),
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(18, 14, 18, 30),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                s.group['title'] as String? ?? '',
                style: const TextStyle(
                  fontSize: 19,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                s.group['subtitle'] as String? ?? '',
                style: const TextStyle(fontSize: 11.5, color: Tokens.muted),
              ),
              const SizedBox(height: 11),
              Row(
                children: [
                  for (final initials in ['TA', 'KZ', 'NS', 'AM'])
                    Padding(
                      padding: const EdgeInsets.only(right: 3),
                      child: CircleAvatar(
                        radius: 13,
                        child: Text(
                          initials,
                          style: const TextStyle(fontSize: 9.5),
                        ),
                      ),
                    ),
                  const Text(
                    ' + 1.4k members',
                    style: TextStyle(color: Tokens.muted, fontSize: 11),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              FilledButton(
                onPressed: s.joined ? null : () => c.join(true),
                child: Text(s.joined ? 'Joined' : 'Join group'),
              ),
              if (s.joined)
                TextButton(
                  onPressed: () => c.join(false),
                  child: const Text('Leave this group'),
                ),
              const SizedBox(height: 12),
              Text(
                s.group['body'] as String? ?? '',
                style: const TextStyle(fontSize: 12.5, height: 1.58),
              ),
              const SectionTitle('GROUP RULES'),
              for (final rule in s.group['rules'] as List? ?? [])
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 9),
                  child: Text(
                    rule as String,
                    style: const TextStyle(fontSize: 12),
                  ),
                ),
              const SectionTitle('RECENT IN THE GROUP'),
              for (final row in s.group['recent'] as List? ?? [])
                Card(
                  child: ListTile(
                    leading: const IconTile(Icons.person),
                    title: Text(
                      row['title'] as String,
                      style: const TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    subtitle: Text(
                      row['subtitle'] as String,
                      style: const TextStyle(fontSize: 11, color: Tokens.muted),
                    ),
                    onTap: () {
                      if (row['title'] == 'Find members') {
                        c.category('people');
                        c.go('discover');
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(row['subtitle'] as String)),
                        );
                      }
                    },
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}
