import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:uuid/uuid.dart';

import '../domain/repository.dart';
import 'api_client.dart';

class MockRepository implements NexusRepository {
  MockRepository(this.fixture, {this.knownDevice = true});
  final Map<String, dynamic> fixture;
  final bool knownDevice;
  @override
  bool get isDemo => true;
  @override
  void cancelPending() {}
  static final demoOtp = '${'a' * 22}.${'b' * 43}';
  bool _issued = false;
  static Future<MockRepository> load() async => MockRepository(
    jsonDecode(await rootBundle.loadString('assets/fixtures.json'))
        as Map<String, dynamic>,
  );
  @override
  Future<Map<String, dynamic>> deviceLogin(String phone) async => knownDevice
      ? {'_status': 200, 'jwt': 'demo-only', 'refresh': 'demo-only'}
      : {'_status': 202, 'action': 'REQUIRE_EMAIL_VERIFICATION'};
  @override
  Future<void> emailVerify(String phone, String email) async {
    _issued = true;
  }

  @override
  Future<void> confirm(String otp) async {
    if (!_issued || otp != demoOtp) {
      throw ApiException(401, 'unauthorized');
    }
    _issued = false;
  }

  @override
  Future<void> register(String phone, String email) async {}
  @override
  Future<void> logout() async {}
  @override
  Future<Map<String, dynamic>> get(
    String path, {
    Map<String, String> query = const {},
  }) async {
    dynamic data;
    if (path == '/feed') {
      data = fixture['feed'];
    } else if (path == '/discover') {
      data = (fixture['discover'] as List)
          .where(
            (v) =>
                v['category'] == (query['type'] ?? 'groups') &&
                '${v['title']} ${v['subtitle']}'.toLowerCase().contains(
                  (query['q'] ?? '').toLowerCase(),
                ),
          )
          .toList();
    } else if (path == '/chat/threads') {
      data = [
        {'id': '1', 'title': 'Sophie Jap'},
      ];
    } else if (path.endsWith('/messages')) {
      data = fixture['messages'];
    } else if (path.endsWith('/comments')) {
      data = fixture['comments'];
    } else if (path == '/users/me') {
      return Map<String, dynamic>.from(fixture['profile'] as Map);
    } else if (path == '/shops') {
      data = [
        {...Map<String, dynamic>.from(fixture['shop'] as Map), 'id': '2'},
      ];
    } else if (path == '/groups') {
      data = [
        {...Map<String, dynamic>.from(fixture['group'] as Map), 'id': '3'},
      ];
    } else if (path.endsWith('/products')) {
      data = fixture['products'];
    } else if (path.startsWith('/shops/')) {
      return {...Map<String, dynamic>.from(fixture['shop'] as Map), 'id': '2'};
    } else if (path.startsWith('/groups/')) {
      return {...Map<String, dynamic>.from(fixture['group'] as Map), 'id': '3'};
    } else if (path == '/notifications') {
      data = fixture['notifications'];
    } else {
      throw ApiException(404, 'MOCK_ROUTE_NOT_FOUND');
    }
    return {'items': data, 'next_cursor': null};
  }

  @override
  Future<Map<String, dynamic>> send(
    String path,
    Map<String, dynamic> body, {
    String method = 'POST',
  }) async => {...body, 'id': const Uuid().v4()};
}
