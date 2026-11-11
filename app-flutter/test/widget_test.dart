import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nexus/data/mock_repository.dart';
import 'package:nexus/main.dart';
import 'package:nexus/presentation/controllers/providers.dart';
import 'package:nexus/presentation/screens/auth_screen.dart';

/// App-level smoke test.
///
/// Renders the REAL app widget (`NexusApp` - there is no `MyApp` in this
/// codebase) with a fake repository injected through `repositoryProvider`,
/// so the widget tree builds without a backend, network, or secure storage.
MockRepository fakeRepository() => MockRepository(
  jsonDecode(File('assets/fixtures.json').readAsStringSync())
      as Map<String, dynamic>,
);

void main() {
  testWidgets('NexusApp builds with an injected repository and shows login', (
    t,
  ) async {
    await t.pumpWidget(
      ProviderScope(
        overrides: [repositoryProvider.overrideWithValue(fakeRepository())],
        child: const NexusApp(),
      ),
    );
    // Two frames: no pumpAndSettle, the login screen animates continuously.
    await t.pump();
    await t.pump(const Duration(milliseconds: 300));

    expect(find.byType(AuthScreen), findsOneWidget);
    expect(find.text('Device login'), findsOneWidget);
  });
}
