import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:uuid/uuid.dart';

import '../domain/models.dart';

abstract interface class Vault {
  Future<String> deviceId();
  Future<Session?> session();
  Future<void> save(Session session);
  Future<void> clear();
}

class SecureVault implements Vault {
  SecureVault([
    this.storage = const FlutterSecureStorage(
      aOptions: AndroidOptions(encryptedSharedPreferences: true),
      iOptions: IOSOptions(
        accessibility: KeychainAccessibility.first_unlock_this_device,
      ),
    ),
  ]);
  final FlutterSecureStorage storage;
  Future<void> _writes = Future<void>.value();
  Future<void> _write(Future<void> Function() action) {
    final result = _writes.then((_) => action());
    _writes = result.catchError((Object _) {});
    return result;
  }

  Future<String>? _device;
  @override
  Future<String> deviceId() => _device ??= _loadDevice();
  Future<String> _loadDevice() async {
    final existing = await storage.read(key: 'nexus.device');
    if (existing != null) return existing;
    final value = const Uuid().v4();
    await storage.write(key: 'nexus.device', value: value);
    return value;
  }

  @override
  Future<Session?> session() async {
    final value = await storage.read(key: 'nexus.session');
    return value == null
        ? null
        : Session.fromJson(jsonDecode(value) as Map<String, dynamic>);
  }

  @override
  Future<void> save(Session session) => _write(
    () => storage.write(
      key: 'nexus.session',
      value: jsonEncode(session.toJson()),
    ),
  );
  @override
  Future<void> clear() => _write(() => storage.delete(key: 'nexus.session'));
}

/// Tests and explicit demo mode only; never selected for a real repository.
class MemoryVault implements Vault {
  Session? value;
  final String id = const Uuid().v4();
  @override
  Future<String> deviceId() async => id;
  @override
  Future<Session?> session() async => value;
  @override
  Future<void> save(Session session) async {
    value = session;
  }

  @override
  Future<void> clear() async {
    value = null;
  }
}
