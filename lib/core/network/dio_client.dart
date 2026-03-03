import 'package:dio/dio.dart';
import '../constants/api_constants.dart';
import '../errors/exceptions.dart';
import '../storage/secure_storage.dart';

class DioClient {
  late final Dio _dio;
  final SecureStorageService _secureStorage;

  DioClient(this._secureStorage) {
    _dio = Dio(
      BaseOptions(
        baseUrl: ApiConstants.baseUrl,
        connectTimeout: ApiConstants.connectTimeout,
        receiveTimeout: ApiConstants.receiveTimeout,
        headers: {'Accept': 'application/json'},
      ),
    );

    _dio.interceptors.addAll([
      _AuthInterceptor(_secureStorage),
      LogInterceptor(
        requestBody: true,
        responseBody: true,
        error: true,
        logPrint: (obj) => debugPrint('[DIO] $obj'),
      ),
    ]);
  }

  Dio get instance => _dio;
}

class _AuthInterceptor extends Interceptor {
  final SecureStorageService _secureStorage;

  _AuthInterceptor(this._secureStorage);

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final token = await _secureStorage.getToken();
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (err.response?.statusCode == 401) {
      handler.reject(
        DioException(
          requestOptions: err.requestOptions,
          error: const UnauthorizedException(),
          type: DioExceptionType.badResponse,
          response: err.response,
        ),
      );
      return;
    }
    handler.next(err);
  }
}

/// Extension utilitaire pour mapper les DioException → Exception domaine
extension DioClientExt on Dio {
  Future<Response<T>> safeGet<T>(
    String path, {
    Map<String, dynamic>? params,
  }) async {
    try {
      return await get<T>(path, queryParameters: params);
    } on DioException catch (e) {
      throw _mapDioException(e);
    }
  }

  Future<Response<T>> safePost<T>(String path, {dynamic data}) async {
    try {
      return await post<T>(path, data: data);
    } on DioException catch (e) {
      throw _mapDioException(e);
    }
  }

  Exception _mapDioException(DioException e) {
    if (e.error is UnauthorizedException) return const UnauthorizedException();
    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.connectionError ||
        e.type == DioExceptionType.receiveTimeout) {
      return const NetworkException();
    }
    if (e.response?.statusCode == 422) {
      final raw = e.response?.data['errors'] as Map<String, dynamic>? ?? {};
      final errors = raw.map((k, v) => MapEntry(k, List<String>.from(v)));
      return ValidationException(errors);
    }
    return ServerException(
      message:
          e.response?.data?['message'] ?? e.message ?? 'Erreur serveur',
      statusCode: e.response?.statusCode,
    );
  }
}

void debugPrint(String message) {
  // ignore: avoid_print
  print(message);
}
