import 'package:get/get.dart';

import '../../features/auth/data/models/auth_models.dart';

import 'token_store.dart';

class SessionService extends GetxService {
  SessionService(this._tokenStore);

  final TokenStore _tokenStore;

  TokenResponse? _token;
  Future<void>? _loadFuture;

  TokenResponse? get token => _token;

  DateTime? get expiresAt => _token?.expireTime;

  bool get isSessionValid {
    final expiresAt = _token?.expireTime;
    if (expiresAt == null) return false;
    return DateTime.now().isBefore(expiresAt);
  }

  Future<void> ensureLoaded() {
    return _loadFuture ??= _restore();
  }

  Future<void> _restore() async {
    _token = await _tokenStore.read();
  }

  Future<void> setToken(TokenResponse token) async {
    _token = token;
    await _tokenStore.write(token);
  }

  Future<void> clearSession() async {
    _token = null;
    await _tokenStore.clear();
  }
}
