import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nexus/main.dart';
import 'package:nexus/data/mock_repository.dart';
import 'package:nexus/presentation/controllers/providers.dart';
import 'package:nexus/presentation/controllers/nexus_controller.dart';

MockRepository mock({bool known = true}) => MockRepository(
  jsonDecode(File('assets/fixtures.json').readAsStringSync())
      as Map<String, dynamic>,
  knownDevice: known,
);
void main() {
  testWidgets(
    'login 200 enters native home; all six screens render without exceptions',
    (t) async {
      final container = ProviderContainer(
        overrides: [repositoryProvider.overrideWithValue(mock())],
      );
      addTearDown(container.dispose);
      await t.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const NexusApp(),
        ),
      );
      await t.enterText(find.byType(TextFormField).first, '+959123456789');
      await t.tap(find.text('Device login'));
      await t.pumpAndSettle();
      expect(find.text('For You'), findsOneWidget);
      for (final screen in [
        'chat',
        'profile',
        'discover',
        'business',
        'group',
        'feed',
      ]) {
        container.read(nexusProvider.notifier).go(screen);
        await t.pumpAndSettle();
        expect(t.takeException(), isNull, reason: screen);
      }
    },
  );
  testWidgets('login 202 displays email screen; signup validates email', (
    t,
  ) async {
    await t.pumpWidget(
      ProviderScope(
        overrides: [repositoryProvider.overrideWithValue(mock(known: false))],
        child: const NexusApp(),
      ),
    );
    await t.enterText(find.byType(TextFormField).first, '+959123456789');
    await t.tap(find.text('Device login'));
    await t.pumpAndSettle();
    expect(find.text('Verify your recovery email'), findsOneWidget);
    await t.enterText(find.byType(TextFormField).first, 'bad');
    await t.tap(find.text('Send email code'));
    await t.pumpAndSettle();
    expect(find.text('Enter a valid recovery email.'), findsOneWidget);
  });
}
