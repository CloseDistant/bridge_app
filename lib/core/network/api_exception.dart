import 'package:dio/dio.dart';

class ApiException implements Exception {
  ApiException({
    required this.message,
    this.statusCode,
    this.data,
    this.original,
  });

  final String message;
  final int? statusCode;
  final Object? data;
  final Object? original;

  @override
  String toString() {
    final code = statusCode == null ? '' : ' (HTTP $statusCode)';
    return 'ApiException$code: $message';
  }

  static ApiException fromDio(DioException error) {
    final response = error.response;
    final statusCode = response?.statusCode;

    // 连接/超时
    if (error.type == DioExceptionType.connectionTimeout ||
        error.type == DioExceptionType.sendTimeout ||
        error.type == DioExceptionType.receiveTimeout) {
      return ApiException(
        message: '网络请求超时',
        statusCode: statusCode,
        data: response?.data,
        original: error,
      );
    }

    // 无网络/连接失败
    if (error.type == DioExceptionType.connectionError) {
      return ApiException(
        message: '网络连接失败',
        statusCode: statusCode,
        data: response?.data,
        original: error,
      );
    }

    // 业务 HTTP 状态码
    if (statusCode != null) {
      final data = response?.data;
      final msg = _extractMessage(data) ?? '请求失败';
      return ApiException(
        message: msg,
        statusCode: statusCode,
        data: data,
        original: error,
      );
    }

    return ApiException(
      message: error.message ?? '未知网络错误',
      statusCode: statusCode,
      data: response?.data,
      original: error,
    );
  }

  static String? _extractMessage(Object? data) {
    if (data == null) return null;

    if (data is Map) {
      final msg = data['message'] ?? data['error'] ?? data['title'];
      if (msg is String && msg.trim().isNotEmpty) return msg.trim();
    }

    if (data is String && data.trim().isNotEmpty) {
      return data.trim();
    }

    return null;
  }
}
