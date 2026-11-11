// Cross-layer auth journey tests (data + domain + presentation controllers).
// They run headless with `flutter test integration_test`; real-device/emulator
// execution of the widget tree is a separate CI device job (see README here).
import 'dart:convert';
import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nexus/data/mock_repository.dart';
import 'package:nexus/presentation/controllers/auth_controller.dart';
import 'package:nexus/presentation/controllers/providers.dart';

Map<String, dynamic> loadFixture() =>
    jsonDecode(File('assets/fixtures.json').readAsStringSync())
        as Map<String, dynamic>;

void main() {
  test('G3 known device: device-login 200 reaches home', () async {
    final c = ProviderContainer(
      overrides: [
        repositoryProvider.overrideWithValue(
          MockRepository(loadFixture(), knownDevice: true),
        ),
      ],
    );
    addTearDown(c.dispose);
    final auth = c.read(authProvider.notifier)..phone('+959123456789');
    await auth.submit();
    expect(c.read(authProvider).stage, 'home');
    expect(c.read(authProvider).error, isNull);
  });

  test('G3 new device: 202 -> email -> OTP -> home recovery chain', () async {
    final c = ProviderContainer(
      overrides: [
        repositoryProvider.overrideWithValue(
          MockRepository(loadFixture(), knownDevice: false),
        ),
      ],
    );
    addTearDown(c.dispose);
    final auth = c.read(authProvider.notifier)..phone('+959123456789');
    await auth.submit();
    expect(c.read(authProvider).stage, 'email');

    auth.email('me@example.com');
    await auth.submit();
    expect(c.read(authProvider).stage, 'otp');
    expect(c.read(authProvider).verificationStatus, 'sent');
    expect(c.read(authProvider).resendSeconds, 60);

    auth.otp(MockRepository.demoOtp);
    await auth.submit();
    expect(c.read(authProvider).stage, 'home');
    // Drain the resend countdown so no periodic timer outlives the test.
    await Future<void>.delayed(const Duration(seconds: 1));
  });
}
