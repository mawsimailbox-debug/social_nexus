import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../controllers/nexus_controller.dart';
import '../theme.dart';
import 'common.dart';

class ShopContent extends ConsumerWidget {
  const ShopContent({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(nexusProvider), c = ref.read(nexusProvider.notifier);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SectionTitle('CONTACT & HOURS'),
        for (final row in s.shop['contact'] as List? ?? [])
          Card(
            child: ListTile(
              leading: const Icon(Icons.info_outline, color: Tokens.tan),
              title: Text(row['title'] as String),
              subtitle: Text(row['subtitle'] as String),
              onTap: () => ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text(row['title'] as String))),
            ),
          ),
        const SectionTitle('PRICE LIST · TODAY'),
        for (final product in s.products)
          Card(
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: Row(
                children: [
                  const IconTile(Icons.restaurant),
                  const SizedBox(width: 11),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(product.title),
                        Text(
                          product.subtitle,
                          style: const TextStyle(
                            fontSize: 10.5,
                            color: Tokens.muted,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    product.price,
                    style: const TextStyle(
                      color: Tokens.tan,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  IconButton(
                    tooltip: 'Add ${product.title}',
                    onPressed: () => c.addProduct(product),
                    icon: Badge(
                      isLabelVisible: s.cart.containsKey(product.id),
                      label: Text('${s.cart[product.id] ?? 0}'),
                      child: const Icon(Icons.add_circle, color: Tokens.tan),
                    ),
                  ),
                ],
              ),
            ),
          ),
        const SectionTitle('PHOTOS'),
        const Row(
          spacing: 6,
          children: [
            Expanded(child: Photo(height: 76, radius: 12)),
            Expanded(
              child: Photo(
                height: 76,
                radius: 12,
                alignment: Alignment(-.24, .24),
              ),
            ),
            Expanded(
              child: Photo(
                height: 76,
                radius: 12,
                alignment: Alignment(.4, -.4),
              ),
            ),
            Expanded(
              child: Photo(
                height: 76,
                radius: 12,
                alignment: Alignment(-.5, .1),
              ),
            ),
          ],
        ),
        const SectionTitle('NEIGHBOURS SAY'),
        for (final review in s.shop['reviews'] as List? ?? [])
          Card(
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(child: Text(review['title'] as String)),
                      Text(
                        review['subtitle'] as String,
                        style: const TextStyle(color: Tokens.tan),
                      ),
                    ],
                  ),
                  const SizedBox(height: 7),
                  Text(review['body'] as String),
                ],
              ),
            ),
          ),
      ],
    );
  }
}
