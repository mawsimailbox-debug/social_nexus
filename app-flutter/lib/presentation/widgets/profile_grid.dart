import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../controllers/nexus_controller.dart';
import '../controllers/providers.dart';
import 'common.dart';

const profileSets = {
  'videos': [
    ('12.4K', .52, .12, 1.8),
    ('8.1K', .30, .40, 2.2),
    ('22.7K', .70, .30, 1.6),
    ('3.2K', .45, .65, 2.4),
    ('14.9K', .60, .20, 1.5),
    ('9.6K', .38, .55, 2.6),
  ],
  'liked': [
    ('6.4K', .62, .45, 1.7),
    ('31.2K', .20, .25, 2.1),
    ('4.8K', .55, .70, 1.9),
    ('11.5K', .75, .35, 2.3),
    ('2.9K', .42, .18, 2.5),
    ('17.3K', .68, .60, 1.65),
  ],
  'saved': [
    ('5.1K', .48, .30, 2.0),
    ('9.9K', .35, .62, 1.75),
    ('13.6K', .58, .15, 2.45),
    ('7.2K', .72, .48, 1.55),
    ('19.4K', .25, .45, 2.15),
    ('4.3K', .63, .72, 1.85),
  ],
};

class ProfileGrid extends ConsumerWidget {
  const ProfileGrid({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (!ref.watch(repositoryProvider).isDemo) {
      return const Padding(
        padding: EdgeInsets.all(16),
        child: Text('Profile media is not available from the backend yet.'),
      );
    }
    final tab = ref.watch(nexusProvider.select((s) => s.profileTab));
    return GridView.count(
      crossAxisCount: 3,
      crossAxisSpacing: 2,
      mainAxisSpacing: 2,
      childAspectRatio: 3 / 4,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: [
        for (final item in profileSets[tab]!)
          InkWell(
            onTap: () => ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Open video · ${item.$1} views')),
            ),
            child: ClipRect(
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Photo(
                    alignment: Alignment(item.$2 * 2 - 1, item.$3 * 2 - 1),
                    backgroundScale: item.$4,
                  ),
                  Positioned(
                    left: 6,
                    bottom: 5,
                    child: Text(
                      '▶ ${item.$1}',
                      style: const TextStyle(
                        fontSize: 10,
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
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
