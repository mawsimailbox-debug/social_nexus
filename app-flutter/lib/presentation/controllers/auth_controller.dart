import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/api_client.dart';
import '../../domain/models.dart';
import '../../domain/repository.dart';
import 'providers.dart';
import 'nexus_controller.dart';

final authProvider = NotifierProvider<AuthController, AuthState>(
  AuthController.new,
);

class AuthController extends Notifier<AuthState> {
  Timer? _timer;
  int _epoch = 0;
  bool _loggingOut = false;
  @override
  AuthState build() {
    ref.onDispose(() {
      _epoch++;
      _timer?.cancel();
    });
    return const AuthState();
  }

  void phone(String value) => state = state.copyWith(phone: value, error: null);
  void email(String value) => state = state.copyWith(email: value, error: null);
  void otp(String value) =>
      state = state.copyWith(otp: value, error: null, verificationStatus: '');
  void signup() => state = state.copyWith(stage: 'signup', error: null);
  void back() {
    _epoch++;
    ref.read(repositoryProvider).cancelPending();
    _timer?.cancel();
    state = state.copyWith(stage: 'login', otp: '', busy: false, error: null);
  }

  void _countdown(int seconds) {
    _timer?.cancel();
    state = state.copyWith(resendSeconds: seconds);
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!ref.mounted) {
        timer.cancel();
        return;
      }
      final next = state.resendSeconds - 1;
      state = state.copyWith(resendSeconds: next < 0 ? 0 : next);
      if (next <= 0) timer.cancel();
    });
  }

  Future<void> resend() async {
    if (state.busy || state.resendSeconds > 0) return;
    state = state.copyWith(stage: 'email', otp: '', verificationStatus: '');
    await submit();
  }

  void _home() {
    _timer?.cancel();
    ref.invalidate(nexusProvider);
    state = state.copyWith(
      stage: 'home',
      otp: '',
      verificationStatus: '',
      resendSeconds: 0,
    );
  }

  Future<void> submit() async {
    if (state.busy || _loggingOut) return;
    final error = switch (state.stage) {
      'login' => validatePhone(state.phone),
      'signup' => validatePhone(state.phone) ?? validateEmail(state.email),
      'email' => validateEmail(state.email),
      'otp' => validateOtp(state.otp),
      _ => null,
    };
    if (error != null) {
      state = state.copyWith(error: error);
      return;
    }
    final epoch = ++_epoch;
    state = state.copyWith(busy: true, error: null);
    final repo = ref.read(repositoryProvider);
    try {
      switch (state.stage) {
        case 'login':
          repo.cancelPending();
          ref.invalidate(nexusProvider);
          final response = await repo.deviceLogin(state.phone);
          if (!ref.mounted || epoch != _epoch) return;
          if (response['_status'] == 200) {
            _home();
          } else if (response['_status'] == 202 &&
              response['action'] == 'REQUIRE_EMAIL_VERIFICATION') {
            state = state.copyWith(stage: 'email');
          } else {
            throw const FormatException('Unexpected device login response');
          }
        case 'signup':
          await repo.register(state.phone, state.email);
          if (!ref.mounted || epoch != _epoch) return;
          state = state.copyWith(stage: 'email');
        case 'email':
          await repo.emailVerify(state.phone, state.email);
          if (!ref.mounted || epoch != _epoch) return;
          state = state.copyWith(stage: 'otp', verificationStatus: 'sent');
          _countdown(60);
        case 'otp':
          await repo.confirm(state.otp);
          if (!ref.mounted || epoch != _epoch) return;
          _home();
      }
    } on RequestCancelled {
      return;
    } catch (e) {
      if (!ref.mounted || epoch != _epoch) return;
      if (e is ApiException && e.status == 429) _countdown(e.retryAfter ?? 60);
      final status =
          e is ApiException && e.status == 401 && state.stage == 'otp'
          ? 'invalid_expired_or_used'
          : '';
      state = state.copyWith(
        error: status.isEmpty ? e.toString() : 'Verification capability is invalid, expired or already used. Request a new email.',
        verificationStatus: status,
      );
    } finally {
      if (ref.mounted && epoch == _epoch) state = state.copyWith(busy: false);
    }
  }

  Future<void> logout() async {
    _loggingOut = true;
    _epoch++;
    _timer?.cancel();
    final repo = ref.read(repositoryProvider);
    repo.cancelPending();
    ref.invalidate(nexusProvider);
    state = const AuthState(busy: true);
    try {
      await repo.logout();
    } catch (e) {
      if (ref.mounted) {
        state = state.copyWith(
          error: 'Local session cleared; server revocation failed: $e',
        );
      }
    } finally {
      _loggingOut = false;
      ref.invalidate(nexusProvider);
      if (ref.mounted) state = state.copyWith(busy: false);
    }
  }
}
