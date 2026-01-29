import 'package:get/get.dart';

import 'session_service.dart';
import '../../features/auth/data/auth_repository.dart';

class AuthService extends GetxService {
  AuthService(this._repo, this._session);

  final AuthRepository _repo;
  final SessionService _session;

  Future<void> requestOtp({required String phone}) async {
    await _repo.sendCode(phone: phone);
  }

  Future<void> registerBySms({
    required String phone,
    required String code,
    String? nickname,
  }) async {
    await _repo.registerBySms(phone: phone, code: code, nickname: nickname);
  }

  Future<bool> loginWithOtp({required String phone, required String otp}) async {
    final token = await _repo.loginBySms(phone: phone, code: otp);
    // loginBySms 内部会写入 session/tokenStore，这里再兜底一次。
    await _session.setToken(token);
    return _session.isSessionValid;
  }

  Future<void> refreshToken() async {
    await _repo.refreshToken();
  }

  Future<void> logout() async {
    await _session.clearSession();
  }
}
