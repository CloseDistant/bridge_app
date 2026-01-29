import '../../../core/network/api_client.dart';
import 'models/auth_models.dart';

class AuthApi {
  AuthApi(this._client);

  final ApiClient _client;

  Future<void> sendCode({required String phone}) {
    return _client.postVoid(
      path: '/api/Users/send-code',
      data: SendSmsCodeDto(phone: phone).toJson(),
    );
  }

  Future<void> registerBySms({
    required String phone,
    required String code,
    String? nickname,
  }) {
    return _client.postVoid(
      path: '/api/Users/register-by-sms',
      data: RegisterBySmsDto(phone: phone, code: code, nickname: nickname)
          .toJson(),
    );
  }

  Future<TokenResponse> loginBySms({required String phone, required String code}) {
    return _client.postJson<TokenResponse>(
      path: '/api/Users/login-by-sms',
      data: LoginBySmsDto(phone: phone, code: code).toJson(),
      decoder: TokenResponse.fromJson,
    );
  }

  Future<TokenResponse> refreshToken({
    required String accessToken,
    required String refreshToken,
  }) {
    return _client.postJson<TokenResponse>(
      path: '/api/Users/refresh-token',
      data:
          RefreshTokenDto(accessToken: accessToken, refreshToken: refreshToken)
              .toJson(),
      decoder: TokenResponse.fromJson,
    );
  }
}
