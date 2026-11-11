import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nexus/data/api_client.dart';
import 'package:nexus/data/mock_repository.dart';
import 'package:nexus/presentation/controllers/auth_controller.dart';
import 'package:nexus/presentation/controllers/providers.dart';
import 'package:nexus/presentation/controllers/nexus_controller.dart';
import 'package:nexus/presentation/widgets/profile_grid.dart';
import 'package:nexus/presentation/widgets/common.dart';

class ConsumedRepository extends MockRepository {
  ConsumedRepository(super.fixture) : super(knownDevice: false);
  int sends = 0;
  @override
  Future<void> emailVerify(String phone, String email) async {
    sends++;
  }

  @override
  Future<void> confirm(String otp) async {
    throw ApiException(401, 'unauthorized');
  }
}

void main() {
  testWidgets(
    'countdown expires allows resend and used-expired reason stays unified',
    (t) async {
      final fixture = jsonDecode(
        File('assets/fixtures.json').readAsStringSync(),
      ) as Map<String, dynamic>;
      final repo = ConsumedRepository(fixture);
      final c = ProviderContainer(
        overrides: [repositoryProvider.overrideWithValue(repo)],
      );
      addTearDown(c.dispose);
      await t.pumpWidget(
        UncontrolledProviderScope(container: c, child: const SizedBox()),
      );
      final auth = c.read(authProvider.notifier);
      auth.phone('+959123456789');
      await auth.submit();
      auth.email('me@example.com');
      await auth.submit();
      expect(repo.sends, 1);
      await auth.resend();
      expect(repo.sends, 1);
      await t.pump(const Duration(seconds: 60));
      expect(c.read(authProvider).resendSeconds, 0);
      await auth.resend();
      expect(repo.sends, 2);
      expect(c.read(authProvider).resendSeconds, 60);
      auth.otp(MockRepository.demoOtp);
      await auth.submit();
      expect(
        c.read(authProvider).verificationStatus,
        'invalid_expired_or_used',
      );
      expect(c.read(authProvider).error, contains('expired or already used'));
      // Drain the resend countdown so fake_async leaves no pending periodic timer.
      await t.pump(const Duration(seconds: 60));
      expect(c.read(authProvider).resendSeconds, 0);
    },
  );
  testWidgets('profile photo widgets use every baseline background scale', (
    t,
  ) async {
    final fixture = jsonDecode(
      File('assets/fixtures.json').readAsStringSync(),
    ) as Map<String, dynamic>;
    final c = ProviderContainer(
      overrides: [
        repositoryProvider.overrideWithValue(MockRepository(fixture)),
      ],
    );
    addTearDown(c.dispose);
    for (final tab in profileSets.keys) {
      c.read(nexusProvider.notifier).profileTab(tab);
      await t.pumpWidget(
        UncontrolledProviderScope(
          container: c,
          child: const MaterialApp(home: Scaffold(body: ProfileGrid())),
        ),
      );
      await t.pumpAndSettle();
      expect(
        t.widgetList<Photo>(find.byType(Photo)).map((p) => p.backgroundScale),
        profileSets[tab]!.map((p) => p.$4),
      );
      expect(t.takeException(), isNull);
    }
  });
}
