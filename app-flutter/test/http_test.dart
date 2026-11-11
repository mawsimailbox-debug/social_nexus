import 'dart:async';
import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:nexus/data/api_client.dart';
import 'package:nexus/data/vault.dart';
import 'package:nexus/domain/models.dart';

void main() {
  test('reject cleartext and credential-bearing API origins', () {
    expect(
      () => ApiClient('http://example.com', MemoryVault()),
      throwsArgumentError,
    );
    expect(
      () => ApiClient('https://user:pass@example.com', MemoryVault()),
      throwsArgumentError,
    );
  });
  test(
    'GET retries twice with exponential backoff and request ID propagation',
    () async {
      var calls = 0;
      final delays = <int>[];
      final ids = <String>{};
      final api = ApiClient(
        'https://example.com',
        MemoryVault(),
        delay: (d) async {
          delays.add(d.inMilliseconds);
        },
        client: MockClient((r) async {
          calls++;
          ids.add(r.headers['X-Request-ID']!);
          expect(r.headers['X-Device-ID'], isNotEmpty);
          return http.Response(
            calls < 3 ? '{}' : '{"items":[]}',
            calls < 3 ? 503 : 200,
          );
        }),
      );
      await api.request('GET', '/feed');
      expect(calls, 3);
      expect(delays, [200, 400]);
      expect(ids, hasLength(1));
    },
  );
  test('POST server failure is never retried', () async {
    var calls = 0;
    final api = ApiClient(
      'https://example.com',
      MemoryVault(),
      client: MockClient((r) async {
        calls++;
        return http.Response('{}', 503);
      }),
    );
    await expectLater(
      api.request('POST', '/feed', body: {'body': 'test'}),
      throwsA(isA<ApiException>()),
    );
    expect(calls, 1);
  });
  test('GET bearer rotates refresh token and replays safely', () async {
    final vault = MemoryVault();
    await vault.save(const Session(jwt: 'old', refresh: 'r1'));
    var gets = 0;
    final api = ApiClient(
      'https://example.com',
      vault,
      client: MockClient((r) async {
        if (r.url.path.endsWith('/refresh')) {
          expect(jsonDecode(r.body), {'refresh': 'r1'});
          return http.Response('{"jwt":"new","refresh":"r2"}', 200);
        }
        gets++;
        return http.Response(
          '{}',
          r.headers['Authorization'] == 'Bearer new' ? 200 : 401,
        );
      }),
    );
    await api.request('GET', '/feed');
    expect(gets, 2);
    expect((await vault.session())!.refresh, 'r2');
  });
  test('POST unauthorized refreshes but does not replay mutation', () async {
    final vault = MemoryVault();
    await vault.save(const Session(jwt: 'old', refresh: 'r1'));
    var mutations = 0;
    final api = ApiClient(
      'https://example.com',
      vault,
      client: MockClient((r) async {
        if (r.url.path.endsWith('/refresh')) {
          return http.Response('{"jwt":"new","refresh":"r2"}', 200);
        }
        mutations++;
        return http.Response('{}', 401);
      }),
    );
    await expectLater(
      api.request('POST', '/feed', body: {}),
      throwsA(isA<ApiException>()),
    );
    expect(mutations, 1);
  });
  test('client timeout is five seconds and POST timeout not retried', () async {
    var calls = 0;
    final api = ApiClient(
      'https://example.com',
      MemoryVault(),
      timeout: const Duration(milliseconds: 5),
      client: MockClient((r) async {
        calls++;
        await Future<void>.delayed(const Duration(milliseconds: 30));
        return http.Response('{}', 200);
      }),
    );
    expect(
      ApiClient('https://example.com', MemoryVault()).timeout,
      const Duration(seconds: 5),
    );
    await expectLater(
      api.request('POST', '/feed', body: {}),
      throwsA(isA<TimeoutException>()),
    );
    expect(calls, 1);
  });
}
