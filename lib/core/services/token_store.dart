import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../features/auth/data/models/auth_models.dart';

class TokenStore {
  TokenStore({FlutterSecureStorage? storage})
      : _storage = storage ?? const FlutterSecureStorage();

  static const _kAccessToken = 'accessToken';
  static const _kRefreshToken = 'refreshToken';
  static const _kExpireTime = 'expireTime';
  static const _kUser = 'user';

  final FlutterSecureStorage _storage;

  Future<void> write(TokenResponse token) async {
    await _storage.write(key: _kAccessToken, value: token.accessToken ?? '');
    await _storage.write(key: _kRefreshToken, value: token.refreshToken ?? '');
    await _storage.write(
      key: _kExpireTime,
      value: token.expireTime.toIso8601String(),
    );
    await _storage.write(
      key: _kUser,
      value: jsonEncode(token.user.toJson()),
    );
  }

  Future<TokenResponse?> read() async {
    final accessToken = await _storage.read(key: _kAccessToken);
    final refreshToken = await _storage.read(key: _kRefreshToken);
    final expireTimeRaw = await _storage.read(key: _kExpireTime);
    final userRaw = await _storage.read(key: _kUser);

    if (expireTimeRaw == null || expireTimeRaw.trim().isEmpty) return null;
    if (userRaw == null || userRaw.trim().isEmpty) return null;

    final expireTime = DateTime.tryParse(expireTimeRaw);
    if (expireTime == null) return null;

    final userJson = jsonDecode(userRaw);
    final user = UserInfo.fromJson(userJson);

    return TokenResponse(
      accessToken: accessToken,
      refreshToken: refreshToken,
      expireTime: expireTime,
      user: user,
    );
  }

  Future<void> clear() async {
    await _storage.delete(key: _kAccessToken);
    await _storage.delete(key: _kRefreshToken);
    await _storage.delete(key: _kExpireTime);
    await _storage.delete(key: _kUser);
  }
}
