import '../domain/repository.dart';
import 'api_client.dart';

/// Logical cancellation: a disposed account cannot consume an old response.
class ScopedRepository implements NexusRepository {
  ScopedRepository(this.delegate, this.active);
  final NexusRepository delegate;
  final bool Function() active;
  Future<T> _run<T>(Future<T> Function() work) async {
    if (!active()) throw const RequestCancelled();
    final result = await work();
    if (!active()) throw const RequestCancelled();
    return result;
  }

  @override
  bool get isDemo => delegate.isDemo;
  @override
  void cancelPending() => delegate.cancelPending();
  @override
  Future<Map<String, dynamic>> deviceLogin(String phone) =>
      _run(() => delegate.deviceLogin(phone));
  @override
  Future<void> emailVerify(String phone, String email) =>
      _run(() => delegate.emailVerify(phone, email));
  @override
  Future<void> confirm(String otp) => _run(() => delegate.confirm(otp));
  @override
  Future<void> register(String phone, String email) =>
      _run(() => delegate.register(phone, email));
  @override
  Future<void> logout() => delegate.logout();
  @override
  Future<Map<String, dynamic>> get(
    String path, {
    Map<String, String> query = const {},
  }) => _run(() => delegate.get(path, query: query));
  @override
  Future<Map<String, dynamic>> send(
    String path,
    Map<String, dynamic> body, {
    String method = 'POST',
  }) => _run(() => delegate.send(path, body, method: method));
}
