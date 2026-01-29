import 'auth_api.dart';
import 'models/auth_models.dart';

import '../../../core/services/session_service.dart';

class AuthRepository {
  AuthRepository({required AuthApi api, required SessionService session})
      : _api = api,
        _session = session;

  final AuthApi _api;
  final SessionService _session;

  Future<void> sendCode({required String phone}) {
    return _api.sendCode(phone: phone);
  }

  Future<void> registerBySms({
    required String phone,
    required String code,
    String? nickname,
  }) {
    return _api.registerBySms(phone: phone, code: code, nickname: nickname);
  }

  Future<TokenResponse> loginBySms({required String phone, required String code}) async {
    final token = await _api.loginBySms(phone: phone, code: code);
    await _session.setToken(token);
    return token;
  }

  Future<TokenResponse> refreshToken() async {
    final current = _session.token;
    if (current == null ||
        (current.accessToken == null || current.accessToken!.isEmpty) ||
        (current.refreshToken == null || current.refreshToken!.isEmpty)) {
      throw StateError('No token to refresh');
    }

    final refreshed = await _api.refreshToken(
      accessToken: current.accessToken!,
      refreshToken: current.refreshToken!,
    );

    await _session.setToken(refreshed);
    return refreshed;
  }
}
