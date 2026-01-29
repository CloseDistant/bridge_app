import 'package:flutter/foundation.dart';

class ApiConfig {
  ApiConfig({
    required this.baseUrl,
    this.connectTimeout = const Duration(seconds: 10),
    this.receiveTimeout = const Duration(seconds: 10),
    this.sendTimeout = const Duration(seconds: 10),
  });

  final String baseUrl;
  final Duration connectTimeout;
  final Duration receiveTimeout;
  final Duration sendTimeout;

  /// Android 模拟器访问宿主机 localhost 需要用 10.0.2.2。
  String get resolvedBaseUrl {
    var trimmed = baseUrl.trim();
    if (trimmed.endsWith('/')) {
      trimmed = trimmed.substring(0, trimmed.length - 1);
    }

    if (kIsWeb) return trimmed;

    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
      return trimmed
          .replaceFirst('http://localhost', 'http://10.0.2.2')
          .replaceFirst('https://localhost', 'https://10.0.2.2');
    }

    return trimmed;
  }
}
