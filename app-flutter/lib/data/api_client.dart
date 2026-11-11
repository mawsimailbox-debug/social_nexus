import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:uuid/uuid.dart';

import '../domain/models.dart';
import 'vault.dart';

class ApiException implements Exception {
  ApiException(this.status, this.code, {this.requestId, this.retryAfter});
  final int status;
  final String code;
  final String? requestId;
  final int? retryAfter;
  @override
  String toString() =>
      'Request failed ($status): $code${requestId == null ? '' : ' · request_id=$requestId'}';
}

class RequestCancelled implements Exception {
  const RequestCancelled();
}

class ApiClient {
  ApiClient(
    this.base,
    this.vault, {
    http.Client? client,
    this.delay = Future<void>.delayed,
    this.timeout = const Duration(seconds: 5),
  }) : client = client ?? http.Client() {
    final uri = Uri.parse(base);
    if (uri.scheme != 'https' ||
        uri.host.isEmpty ||
        uri.userInfo.isNotEmpty ||
        uri.hasQuery ||
        uri.hasFragment) {
      throw ArgumentError('NEXUS_API_URL must be an HTTPS origin');
    }
  }
  final String base;
  final Vault vault;
  final http.Client client;
  final Future<void> Function(Duration) delay;
  final Duration timeout;
  Future<void>? _refreshing;
  int _epoch = 0;
  int get epoch => _epoch;
  void invalidateRequests() {
    _epoch++;
    _refreshing = null;
  }

  void checkEpoch(int value) {
    if (value != _epoch) throw const RequestCancelled();
  }

  Future<Map<String, dynamic>> request(
    String method,
    String path, {
    Map<String, dynamic>? body,
    Map<String, String> query = const {},
    bool auth = true,
  }) async {
    if (!path.startsWith('/') || path.contains('..')) {
      throw ArgumentError('Invalid API path');
    }
    final id = const Uuid().v4();
    final epoch = _epoch;
    final attempts = method == 'GET' ? 3 : 1;
    for (var attempt = 0; attempt < attempts; attempt++) {
      checkEpoch(epoch);
      try {
        var response = await _send(method, path, body, query, auth, id);
        checkEpoch(epoch);
        // Only safe GETs are replayed. Mutations are never replayed automatically.
        if (response.statusCode == 401 && auth) {
          await _refresh();
          checkEpoch(epoch);
          if (method == 'GET') {
            response = await _send(method, path, body, query, auth, id);
            checkEpoch(epoch);
          } else {
            throw ApiException(401, 'SESSION_REFRESHED_RETRY_EXPLICITLY');
          }
        }
        if (response.statusCode >= 500 &&
            method == 'GET' &&
            attempt < attempts - 1) {
          await delay(Duration(milliseconds: 200 * (1 << attempt)));
          continue;
        }
        final data = response.body.isEmpty
            ? <String, dynamic>{}
            : jsonDecode(response.body) as Map<String, dynamic>;
        if (response.statusCode < 200 || response.statusCode >= 300) {
          throw ApiException(
            response.statusCode,
            data['error'] as String? ?? 'REQUEST_FAILED',
            requestId:
                data['request_id'] as String? ??
                response.headers['x-request-id'],
            retryAfter: int.tryParse(response.headers['retry-after'] ?? ''),
          );
        }
        return {...data, '_status': response.statusCode};
      } on TimeoutException {
        if (attempt == attempts - 1) rethrow;
      } on http.ClientException {
        if (attempt == attempts - 1) rethrow;
      }
      await delay(Duration(milliseconds: 200 * (1 << attempt)));
    }
    throw ApiException(503, 'UNAVAILABLE');
  }

  Future<http.Response> _send(
    String method,
    String path,
    Map<String, dynamic>? body,
    Map<String, String> query,
    bool auth,
    String id,
  ) async {
    final epoch = _epoch;
    final token = auth ? await vault.session() : null;
    checkEpoch(epoch);
    final deviceId = await vault.deviceId();
    checkEpoch(epoch);
    final request = http.Request(
      method,
      Uri.parse('$base/api/v1$path')
          .replace(queryParameters: query.isEmpty ? null : query),
    );
    request.followRedirects = false;
    request.headers.addAll({
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'X-Request-ID': id,
      'X-Device-ID': deviceId,
      if (token != null) 'Authorization': 'Bearer ${token.jwt}',
    });
    if (body != null) request.body = jsonEncode(body);
    return (() async => http.Response.fromStream(
      await client.send(request),
    ))().timeout(timeout);
  }

  Future<void> _refresh() =>
      _refreshing ??= _rotate().whenComplete(() => _refreshing = null);
  Future<void> _rotate() async {
    final epoch = _epoch;
    final session = await vault.session();
    checkEpoch(epoch);
    if (session == null) throw ApiException(401, 'LOGIN_REQUIRED');
    try {
      final data = await request(
        'POST',
        '/auth/refresh',
        auth: false,
        body: {'refresh': session.refresh},
      );
      checkEpoch(epoch);
      await vault.save(Session.fromJson(data));
    } on ApiException catch (e) {
      if (epoch == _epoch && (e.status == 401 || e.status == 403)) {
        await vault.clear();
      }
      rethrow;
    }
  }
}
