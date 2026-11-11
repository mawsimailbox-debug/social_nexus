import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nexus/domain/models.dart';
import 'package:nexus/domain/repository.dart';
import 'package:nexus/data/mock_repository.dart';
import 'package:nexus/presentation/controllers/providers.dart';
import 'package:nexus/presentation/controllers/auth_controller.dart';
import 'package:nexus/presentation/controllers/nexus_controller.dart';

Map<String, dynamic> fixture() =>
    jsonDecode(File('assets/fixtures.json').readAsStringSync())
        as Map<String, dynamic>;
void main() {
  test('baseline extraction retains six posts and thirteen discover cards', () {
    expect(fixture()['feed'], hasLength(6));
    expect(fixture()['discover'], hasLength(13));
    expect(File('assets/baseline.jpg').lengthSync(), greaterThan(1000));
  });
  test('Freezed collections are immutable and JSON roundtrips', () {
    const p = Post(id: '1', kind: 'feel', body: 'hello');
    expect(Post.fromJson(p.toJson()), p);
    expect(() => const NexusState().posts.add(p), throwsUnsupportedError);
    expect(p.copyWith(likes: 1).likes, 1);
  });
  test('ranking includes friends outside nearby and is deterministic', () {
    final posts = (fixture()['feed'] as List)
        .map((p) => Post.fromJson(p as Map<String, dynamic>))
        .toList();
    expect(rankPosts(posts, 'foryou').first.id, 'p2');
    expect(rankPosts(posts, 'nearby').map((p) => p.id), [
      'p2',
      'p3',
      'p1',
      'p4',
      'p5',
      'p6',
    ]);
  });
  test('email phone and OTP validation rejects malformed input', () {
    expect(validateEmail('bad'), isNotNull);
    expect(validateEmail('a@example.com'), isNull);
    expect(validatePhone('abc'), isNotNull);
    expect(validateOtp('12345x'), isNotNull);
  });
  test('200 device login transitions home', () async {
    final c = ProviderContainer(
      overrides: [
        repositoryProvider.overrideWithValue(MockRepository(fixture())),
      ],
    );
    addTearDown(c.dispose);
    final auth = c.read(authProvider.notifier);
    auth.phone('+959123456789');
    await auth.submit();
    expect(c.read(authProvider).stage, 'home');
  });
  test('202 requires email then one-time OTP confirmation', () async {
    final c = ProviderContainer(
      overrides: [
        repositoryProvider.overrideWithValue(
          MockRepository(fixture(), knownDevice: false),
        ),
      ],
    );
    addTearDown(c.dispose);
    final auth = c.read(authProvider.notifier);
    auth.phone('+959123456789');
    await auth.submit();
    expect(c.read(authProvider).stage, 'email');
    auth.email('me@example.com');
    await auth.submit();
    expect(c.read(authProvider).stage, 'otp');
    auth.otp('${'x' * 22}.${'y' * 43}');
    await auth.submit();
    expect(c.read(authProvider).verificationStatus, 'invalid_expired_or_used');
    auth.otp(MockRepository.demoOtp);
    await auth.submit();
    expect(c.read(authProvider).stage, 'home');
  });
  test(
    'controller load reaction comment composer chat membership and cart',
    () async {
      final c = ProviderContainer(
        overrides: [
          repositoryProvider.overrideWithValue(MockRepository(fixture())),
        ],
      );
      addTearDown(c.dispose);
      final app = c.read(nexusProvider.notifier);
      await app.load();
      expect(c.read(nexusProvider).error, isNull);
      final post = c.read(nexusProvider).posts.first;
      await app.like(post);
      expect(c.read(nexusProvider).posts.first.liked, true);
      await app.comments(post);
      app.commentDraft('Hello');
      await app.sendComment(post);
      expect(c.read(nexusProvider).comments[post.id]!.last.body, 'Hello');
      app.draft('A new feeling');
      await app.publish();
      expect(c.read(nexusProvider).posts.first.body, 'A new feeling');
      app.messageDraft('Hello Sophie');
      await app.sendMessage();
      expect(c.read(nexusProvider).messages.last.body, 'Hello Sophie');
      await app.join(true);
      expect(c.read(nexusProvider).joined, true);
      await app.join(false);
      expect(c.read(nexusProvider).joined, false);
      await app.addProduct(c.read(nexusProvider).products.first);
      expect(c.read(nexusProvider).cart.values.first, 1);
      await app.markRead();
      expect(c.read(nexusProvider).notifications.any((n) => n.unread), false);
    },
  );
}
