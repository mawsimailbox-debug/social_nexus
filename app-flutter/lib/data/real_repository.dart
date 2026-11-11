import '../domain/models.dart';
import '../domain/repository.dart';
import 'api_client.dart';
import 'dto_mapper.dart';

class RealRepository implements NexusRepository {
  RealRepository(this.api);
  final ApiClient api;
  DtoMapper mapper = DtoMapper();
  @override
  bool get isDemo => false;
  @override
  void cancelPending() {
    api.invalidateRequests();
    mapper = DtoMapper();
  }

  Future<void> _save(Map<String, dynamic> data, int epoch) async {
    api.checkEpoch(epoch);
    await api.vault.save(Session.fromJson(data));
  }

  @override
  Future<Map<String, dynamic>> deviceLogin(String phone) async {
    final epoch = api.epoch;
    final deviceId = await api.vault.deviceId();
    api.checkEpoch(epoch);
    final data = await api.request(
      'POST',
      '/auth/device-login',
      auth: false,
      body: {'phone_number': phone, 'device_id': deviceId},
    );
    if (data['_status'] == 200) await _save(data, epoch);
    return data;
  }

  @override
  Future<void> emailVerify(String phone, String email) async {
    final result = await api.request(
      'POST',
      '/auth/email-verify',
      auth: false,
      body: {'phone_number': phone, 'email': email},
    );
    if (result['_status'] != 202 || result['action'] != 'CHECK_EMAIL') {
      throw const FormatException('Invalid email verification response');
    }
  }

  @override
  Future<void> confirm(String otp) async {
    final epoch = api.epoch;
    final deviceId = await api.vault.deviceId();
    api.checkEpoch(epoch);
    final data = await api.request(
      'POST',
      '/auth/otp/confirm',
      auth: false,
      body: {'otp': otp, 'device_id': deviceId},
    );
    await _save(data, epoch);
  }

  @override
  Future<void> register(String phone, String email) async {
    await api.request(
      'POST',
      '/auth/register',
      auth: false,
      body: {
        'phone_number': phone,
        'email': email,
        'device_id': await api.vault.deviceId(),
      },
    );
  }

  @override
  Future<void> logout() async {
    cancelPending();
    try {
      await api.request('POST', '/auth/logout');
    } finally {
      await api.vault.clear();
    }
  }

  @override
  Future<Map<String, dynamic>> get(
    String path, {
    Map<String, String> query = const {},
  }) async {
    final raw = await api.request('GET', path, query: query);
    if (path == '/users/me') return mapper.profile(raw);
    if (path == '/feed') return mapper.page(raw, mapper.post);
    if (path == '/notifications') return mapper.page(raw, mapper.activity);
    if (RegExp(r'^/shops/\d+$').hasMatch(path)) {
      return mapper.detail(raw, shop: true);
    }
    if (RegExp(r'^/groups/\d+$').hasMatch(path)) {
      return mapper.detail(raw, shop: false);
    }
    if (raw.containsKey('items')) {
      return mapper.page(
        raw,
        (v) => mapper.item(v, category: query['type'] ?? ''),
      );
    }
    throw FormatException('Unmapped backend response: $path');
  }

  @override
  Future<Map<String, dynamic>> send(
    String path,
    Map<String, dynamic> body, {
    String method = 'POST',
  }) async {
    final raw = await api.request(
      method,
      path,
      body: body.isEmpty ? null : body,
    );
    if (path == '/users/me') return mapper.profile(raw);
    if (raw.containsKey('id')) return {...raw, 'id': mapper.id(raw['id'])};
    return raw;
  }
}
