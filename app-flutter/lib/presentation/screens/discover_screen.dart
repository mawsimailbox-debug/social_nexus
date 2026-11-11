import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../controllers/nexus_controller.dart';
import '../widgets/common.dart';
import '../theme.dart';

class DiscoverScreen extends ConsumerWidget {
  const DiscoverScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(nexusProvider),
        c = ref.read(nexusProvider.notifier),
        entries = ref.watch(discoverResultsProvider);
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 8, 14, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('Discover', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 12),
          NativeInput(
            value: s.query,
            onChanged: c.query,
            hint: 'Groups, people, places near you',
          ),
          const SizedBox(height: 12),
          ChoiceRow(
            items: const ['Groups', 'People', 'Places', 'Business'],
            value: s.category,
            onSelect: c.category,
          ),
          if (s.category == 'business')
            ChoiceRow(
              items: const ['All', 'Cafe', 'Food', 'Service', 'Fashion'],
              value: s.subtype,
              onSelect: c.subtype,
            ),
          const SizedBox(height: 8),
          Expanded(
            child: entries.isEmpty
                ? const Center(child: Text('No matches nearby'))
                : ListView(
                    children: [
                      for (final e in entries)
                        Card(
                          color: const Color(0xFF1E2326),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Row(
                              children: [
                                IconTile(
                                  switch (e.category) {
                                    'groups' => Icons.diversity_3,
                                    'people' => Icons.person,
                                    'business' => Icons.storefront,
                                    _ => Icons.place,
                                  },
                                  label: e.category == 'people' ? e.icon : null,
                                ),
                                const SizedBox(width: 11),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        e.title,
                                        style: const TextStyle(
                                          fontSize: 13.5,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                      const SizedBox(height: 3),
                                      Text(
                                        e.subtitle,
                                        style: const TextStyle(
                                          fontSize: 11,
                                          color: Tokens.muted,
                                          height: 1.45,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 6),
                                TextButton(
                                  onPressed: () {
                                    if (e.category == 'people' ||
                                        e.category == 'groups') {
                                      c.toggleEntry(e);
                                    } else if (e.target.isNotEmpty) {
                                      c.openEntry(e);
                                    } else {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                            const SnackBar(
                                              content: Text(
                                                'Shop page coming soon',
                                              ),
                                            ),
                                          );
                                    }
                                  },
                                  child: Text(
                                    e.category == 'groups'
                                        ? (e.selected ? 'Joined' : 'Join')
                                        : e.category == 'people'
                                        ? (e.selected ? 'Following' : 'Follow')
                                        : 'View',
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}
