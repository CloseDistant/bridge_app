import 'package:dio/dio.dart';

import 'api_config.dart';
import 'api_exception.dart';

typedef AccessTokenProvider = String? Function();

typedef TokenRefreshHandler = Future<void> Function();

class ApiClient {
  ApiClient({
    required ApiConfig config,
    AccessTokenProvider? accessTokenProvider,
    TokenRefreshHandler? tokenRefreshHandler,
  })  : _config = config,
        _accessTokenProvider = accessTokenProvider,
        _tokenRefreshHandler = tokenRefreshHandler {
    _dio = Dio(
      BaseOptions(
        baseUrl: _config.resolvedBaseUrl,
        connectTimeout: _config.connectTimeout,
        receiveTimeout: _config.receiveTimeout,
        sendTimeout: _config.sendTimeout,
        headers: <String, Object>{
          'Accept': 'application/json',
        },
      ),
    );

    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          // refresh-token 接口不需要 Authorization（它在 body 里带 access/refresh）。
          if (options.path == '/api/Users/refresh-token') {
            options.headers.remove('Authorization');
            handler.next(options);
            return;
          }

          final token = _accessTokenProvider?.call();
          if (token != null && token.trim().isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          handler.next(options);
        },
        onError: (error, handler) async {
          // 如果配置了 refresh 处理器，遇到 401 时尝试刷新一次。
          final statusCode = error.response?.statusCode;
          final req = error.requestOptions;
          final isRefreshCall = req.path == '/api/Users/refresh-token';
          final alreadyRetried = req.extra['__retried'] == true;

          if (statusCode == 401 &&
              !isRefreshCall &&
              !alreadyRetried &&
              _tokenRefreshHandler != null) {
            try {
              await _tokenRefreshHandler.call();

              req.extra['__retried'] = true;

              final token = _accessTokenProvider?.call();
              if (token != null && token.trim().isNotEmpty) {
                req.headers['Authorization'] = 'Bearer $token';
              } else {
                req.headers.remove('Authorization');
              }

              final clonedResponse = await _dio.fetch<dynamic>(req);
              handler.resolve(clonedResponse);
              return;
            } catch (_) {
              // refresh 失败则继续走错误。
            }
          }

          handler.next(error);
        },
      ),
    );
  }

  final ApiConfig _config;
  final AccessTokenProvider? _accessTokenProvider;
  final TokenRefreshHandler? _tokenRefreshHandler;

  late final Dio _dio;

  Future<T> postJson<T>({
    required String path,
    Object? data,
    Map<String, dynamic>? queryParameters,
    T Function(Object? json)? decoder,
  }) async {
    try {
      final response = await _dio.post<dynamic>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: Options(contentType: Headers.jsonContentType),
      );

      final body = response.data;
      if (decoder != null) return decoder(body);

      return body as T;
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }

  Future<void> postVoid({
    required String path,
    Object? data,
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      await _dio.post<void>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: Options(contentType: Headers.jsonContentType),
      );
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }
}
