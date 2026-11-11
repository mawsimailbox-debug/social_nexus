import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:nexus/data/api_client.dart';
import 'package:nexus/data/real_repository.dart';
import 'package:nexus/data/vault.dart';
import 'package:nexus/data/dto_mapper.dart';
import 'package:nexus/presentation/controllers/nexus_controller.dart';
import 'package:nexus/presentation/controllers/providers.dart';

Map<String, dynamic> shapes() =>
    jsonDecode(File('test/fixtures/go-shapes.json').readAsStringSync())
        as Map<String, dynamic>;
http.Response json(dynamic value, [int status = 200]) =>
    http.Response(jsonEncode(value), status);
void main() {
  test('auth sends exact Go operation-specific keys and opaque OTP', () async {
    final requests = <http.Request>[];
    final vault = MemoryVault();
    final repo = RealRepository(
      ApiClient(
        'https://example.com',
        vault,
        client: MockClient((r) async {
          requests.add(r);
          if (r.url.path.endsWith('email-verify')) {
            return json({'action': 'CHECK_EMAIL'}, 202);
          }
          return json({'jwt': 'access', 'refresh': 'refresh'});
        }),
      ),
    );
    await repo.emailVerify('+959123456789', 'me@example.com');
    expect(jsonDecode(requests.last.body), {
      'phone_number': '+959123456789',
      'email': 'me@example.com',
    });
    final otp = '${'a' * 22}.${'b' * 43}';
    await repo.confirm(otp);
    expect(jsonDecode(requests.last.body), {
      'otp': otp,
      'device_id': await vault.deviceId(),
    });
    expect((await vault.session())!.jwt, 'access');
  });
  test(
    'Go DTO mapper handles integer IDs people user IDs and outgoing identity',
    () {
      final s = shapes(), mapper = DtoMapper();
      final profile = mapper.profile(s['profile'] as Map<String, dynamic>);
      expect(profile['title'], 'Account Owner');
      expect(mapper.post(s['post'] as Map<String, dynamic>)['id'], '101');
      expect(
        mapper.post(s['post'] as Map<String, dynamic>)['author'],
        'owner-account',
      );
      expect(
        mapper.item(s['incoming'] as Map<String, dynamic>)['outgoing'],
        false,
      );
      expect(
        mapper.item(s['outgoing'] as Map<String, dynamic>)['outgoing'],
        true,
      );
      expect(
        mapper.item(s['person'] as Map<String, dynamic>)['id'],
        'public-user-id',
      );
      expect(
        mapper.item(s['product'] as Map<String, dynamic>)['price'],
        '4200 K',
      );
    },
  );
  test('real load resolves root IDs products and refetches discover type', () async {
    final s = shapes();
    final paths = <String>[];
    final repo = RealRepository(
      ApiClient(
        'https://example.com',
        MemoryVault(),
        client: MockClient((r) async {
          paths.add(
            '${r.method} ${r.url.path}${r.url.hasQuery ? '?${r.url.query}' : ''}',
          );
          final path = r.url.path.replaceFirst('/api/v1', '');
          if (path == '/users/me') return json(s['profile']);
          if (path == '/shops/401') return json(s['shop']);
          if (path == '/groups/601') return json(s['group']);
          final items = switch (path) {
            '/feed' => [s['post']],
            '/shops' => [s['shop']],
            '/groups' => [s['group']],
            '/chat/threads' => [s['thread']],
            '/chat/threads/201/messages' => [s['incoming'], s['outgoing']],
            '/shops/401/products' => [s['product']],
            '/notifications' => [s['notification']],
            '/discover' => [
              r.url.queryParameters['type'] == 'people'
                  ? s['person']
                  : s['group'],
            ],
            _ => null,
          };
          if (items == null) {
            return json({
              'error': 'not_found',
              'request_id': 'missing-route',
            }, 404);
          }
          return json({'items': items, 'next_cursor': ''});
        }),
      ),
    );
    final c = ProviderContainer(
      overrides: [repositoryProvider.overrideWithValue(repo)],
    );
    addTearDown(c.dispose);
    final app = c.read(nexusProvider.notifier);
    await app.load();
    final state = c.read(nexusProvider);
    expect(state.error, isNull);
    expect(state.threadId, '201');
    expect(state.shop['id'], '401');
    expect(state.group['id'], '601');
    expect(state.products.single.id, '501');
    expect(state.messages.map((m) => m.outgoing), [false, true]);
    await app.category('people');
    expect(paths.last, contains('type=people'));
    expect(c.read(nexusProvider).discover.single.id, 'public-user-id');
  });
  test('controller emits exact relation join create comment activity and patch routes', () async {
    final s = shapes();
    final requests = <http.Request>[];
    final repo = RealRepository(
      ApiClient(
        'https://example.com',
        MemoryVault(),
        client: MockClient((r) async {
          requests.add(r);
          final path = r.url.path.replaceFirst('/api/v1', '');
          if (r.method == 'PATCH' && path == '/users/me') {
            return json({...s['profile'] as Map, 'bio': 'Updated'});
          }
          if (r.method != 'GET') {
            return r.method == 'POST' && path == '/feed'
                ? json({...s['post'] as Map, 'id': 900}, 201)
                : json({'id': 901});
          }
          if (path == '/users/me') return json(s['profile']);
          if (path == '/shops/401') return json(s['shop']);
          if (path == '/groups/601') return json(s['group']);
          final items = switch (path) {
            '/feed' => [s['post']],
            '/shops' => [s['shop']],
            '/groups' => [s['group']],
            '/chat/threads' => [s['thread']],
            '/shops/401/products' => [s['product']],
            '/notifications' => [s['notification']],
            _ => [],
          };
          return json({'items': items, 'next_cursor': ''});
        }),
      ),
    );
    final c = ProviderContainer(
      overrides: [repositoryProvider.overrideWithValue(repo)],
    );
    addTearDown(c.dispose);
    final app = c.read(nexusProvider.notifier);
    await app.load();
    final post = c.read(nexusProvider).posts.single;
    await app.like(post);
    expect(requests.last.method, 'PUT');
    expect(requests.last.url.path, endsWith('/items/101/like'));
    await app.like(c.read(nexusProvider).posts.single);
    expect(requests.last.method, 'DELETE');
    await app.save(post);
    expect(requests.last.url.path, endsWith('/items/101/save'));
    await app.join(true);
    expect(requests.last.method, 'POST');
    expect(requests.last.url.path, endsWith('/groups/601/join'));
    await app.join(false);
    expect(requests.last.method, 'DELETE');
    app.draft('Valid backend post');
    await app.publish();
    expect(jsonDecode(requests.last.body), {
      'name': '',
      'body': 'Valid backend post',
      'visibility': 'public',
    });
    app.commentDraft('comment');
    await app.sendComment(post);
    expect(jsonDecode(requests.last.body), {'body': 'comment'});
    await app.addProduct(c.read(nexusProvider).products.single);
    expect(requests.last.url.path, endsWith('/cart/501'));
    expect(requests.last.method, 'PUT');
    expect(jsonDecode(requests.last.body), {'quantity': 1});
    await app.markRead();
    expect(requests.last.url.path, endsWith('/notifications/801/read'));
    expect(requests.last.method, 'PATCH');
    await app.share(post, 'Telegram');
    expect(requests.last.url.path, endsWith('/items/101/shares'));
    expect(requests.last.body, isEmpty);
    await app.editProfile('Updated');
    expect(jsonDecode(requests.last.body), {'bio': 'Updated'});
    expect(c.read(nexusProvider).profile['title'], 'Account Owner');
  });
  test(
    'Go error and server request_id retained; absent activity is not success',
    () async {
      final repo = RealRepository(
        ApiClient(
          'https://example.com',
          MemoryVault(),
          client: MockClient(
            (r) async => json({
              'error': 'not_found',
              'request_id': 'server-request-123',
            }, 404),
          ),
        ),
      );
      await expectLater(
        repo.get('/notifications'),
        throwsA(
          isA<ApiException>()
              .having((e) => e.code, 'error', 'not_found')
              .having((e) => e.requestId, 'request_id', 'server-request-123'),
        ),
      );
      await expectLater(
        repo.send('/cart/501', {'quantity': 1}, method: 'PUT'),
        throwsA(isA<ApiException>()),
      );
    },
  );
  test('invalidated HTTP completion cannot restore old tokens', () async {
    final pending = Completer<http.Response>();
    final vault = MemoryVault();
    final repo = RealRepository(
      ApiClient(
        'https://example.com',
        vault,
        client: MockClient((r) => pending.future),
      ),
    );
    final future = repo.deviceLogin('+959123456789');
    final assertion = expectLater(future, throwsA(isA<RequestCancelled>()));
    await Future<void>.delayed(Duration.zero);
    repo.cancelPending();
    pending.complete(json({'jwt': 'old-account', 'refresh': 'old'}));
    await assertion;
    expect(await vault.session(), isNull);
  });
}
