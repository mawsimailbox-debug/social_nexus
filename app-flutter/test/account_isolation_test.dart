import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nexus/data/mock_repository.dart';
import 'package:nexus/domain/models.dart';
import 'package:nexus/presentation/controllers/auth_controller.dart';
import 'package:nexus/presentation/controllers/nexus_controller.dart';
import 'package:nexus/presentation/controllers/providers.dart';

class DelayedRepository extends MockRepository {
  DelayedRepository(super.fixture);
  final pending = Completer<Map<String, dynamic>>();
  @override
  Future<Map<String, dynamic>> get(
    String path, {
    Map<String, String> query = const {},
  }) => path == '/users/me' ? pending.future : super.get(path, query: query);
}

void main() {
  test(
    'logout invalidates account state and ignores delayed old load',
    () async {
      final fixture = jsonDecode(
        File('assets/fixtures.json').readAsStringSync(),
      ) as Map<String, dynamic>;
      final repo = DelayedRepository(fixture);
      final c = ProviderContainer(
        overrides: [repositoryProvider.overrideWithValue(repo)],
      );
      addTearDown(c.dispose);
      final old = c.read(nexusProvider.notifier);
      old.draft('private account draft');
      final load = old.load();
      await c.read(authProvider.notifier).logout();
      expect(c.read(nexusProvider), const NexusState());
      repo.pending.complete({
        'id': 'previous-account',
        'title': 'Private Owner',
      });
      await load;
      expect(c.read(nexusProvider), const NexusState());
      expect(c.read(authProvider).stage, 'login');
    },
  );
  test(
    'invalid capability is unified expired-used state and resend countdown',
    () async {
      final fixture = jsonDecode(
        File('assets/fixtures.json').readAsStringSync(),
      ) as Map<String, dynamic>;
      final c = ProviderContainer(
        overrides: [
          repositoryProvider.overrideWithValue(
            MockRepository(fixture, knownDevice: false),
          ),
        ],
      );
      addTearDown(c.dispose);
      final a = c.read(authProvider.notifier);
      a.phone('+959123456789');
      await a.submit();
      a.email('me@example.com');
      await a.submit();
      expect(c.read(authProvider).resendSeconds, 60);
      await a.resend();
      expect(c.read(authProvider).stage, 'otp');
      a.otp('${'x' * 22}.${'y' * 43}');
      await a.submit();
      expect(
        c.read(authProvider).verificationStatus,
        'invalid_expired_or_used',
      );
      a.otp(MockRepository.demoOtp);
      await a.submit();
      expect(c.read(authProvider).stage, 'home');
    },
  );
}
