import 'dart:convert';

Object? _maybeDecodeJson(Object? input) {
  if (input is String) {
    final trimmed = input.trim();
    if (trimmed.isEmpty) return null;
    try {
      return jsonDecode(trimmed);
    } catch (_) {
      return input;
    }
  }
  return input;
}

class SendSmsCodeDto {
  SendSmsCodeDto({required this.phone});

  final String phone;

  Map<String, Object?> toJson() => <String, Object?>{
        'phone': phone,
      };
}

class RegisterBySmsDto {
  RegisterBySmsDto({
    required this.phone,
    required this.code,
    this.nickname,
  });

  final String phone;
  final String code;
  final String? nickname;

  Map<String, Object?> toJson() => <String, Object?>{
        'phone': phone,
        'code': code,
        'nickname': nickname,
      };
}

class LoginBySmsDto {
  LoginBySmsDto({required this.phone, required this.code});

  final String phone;
  final String code;

  Map<String, Object?> toJson() => <String, Object?>{
        'phone': phone,
        'code': code,
      };
}

class RefreshTokenDto {
  RefreshTokenDto({required this.accessToken, required this.refreshToken});

  final String accessToken;
  final String refreshToken;

  Map<String, Object?> toJson() => <String, Object?>{
        'accessToken': accessToken,
        'refreshToken': refreshToken,
      };
}

class UserInfo {
  UserInfo({
    required this.id,
    this.phone,
    this.nickname,
    this.avatar,
    this.email,
  });

  final int id;
  final String? phone;
  final String? nickname;
  final String? avatar;
  final String? email;

  factory UserInfo.fromJson(Object? json) {
    final normalized = _maybeDecodeJson(json);
    if (normalized is! Map) {
      throw const FormatException('UserInfo json is not a map');
    }

    return UserInfo(
      id: (normalized['id'] as num).toInt(),
      phone: normalized['phone'] as String?,
      nickname: normalized['nickname'] as String?,
      avatar: normalized['avatar'] as String?,
      email: normalized['email'] as String?,
    );
  }

  Map<String, Object?> toJson() => <String, Object?>{
        'id': id,
        'phone': phone,
        'nickname': nickname,
        'avatar': avatar,
        'email': email,
      };
}

class TokenResponse {
  TokenResponse({
    required this.accessToken,
    required this.refreshToken,
    required this.expireTime,
    required this.user,
  });

  final String? accessToken;
  final String? refreshToken;
  final DateTime expireTime;
  final UserInfo user;

  factory TokenResponse.fromJson(Object? json) {
    final normalized = _maybeDecodeJson(json);
    if (normalized is! Map) {
      throw const FormatException('TokenResponse json is not a map');
    }

    final expireTimeRaw = normalized['expireTime'];
    if (expireTimeRaw is! String || expireTimeRaw.trim().isEmpty) {
      throw const FormatException('TokenResponse.expireTime is missing');
    }

    return TokenResponse(
      accessToken: normalized['accessToken'] as String?,
      refreshToken: normalized['refreshToken'] as String?,
      expireTime: DateTime.parse(expireTimeRaw),
      user: UserInfo.fromJson(normalized['user']),
    );
  }

  Map<String, Object?> toJson() => <String, Object?>{
        'accessToken': accessToken,
        'refreshToken': refreshToken,
        'expireTime': expireTime.toIso8601String(),
        'user': user.toJson(),
      };
}
