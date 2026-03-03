import 'package:dio/dio.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/errors/exceptions.dart';
import '../models/user_model.dart';

abstract class AuthRemoteDataSource {
  Future<({String token, UserModel user})> login({
    required String identifiant,
    required String password,
  });
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final Dio _dio;

  AuthRemoteDataSourceImpl(this._dio);

  @override
  Future<({String token, UserModel user})> login({
    required String identifiant,
    required String password,
  }) async {
    try {
      final response = await _dio.post(
        ApiConstants.login,
        data: {'identifiant': identifiant, 'password': password},
      );

      final data = response.data as Map<String, dynamic>;
      return (
        token: data['token'] as String,
        user: UserModel.fromJson(data['user'] as Map<String, dynamic>),
      );
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw const UnauthorizedException();
      }
      if (e.response?.statusCode == 422) {
        final raw =
            e.response?.data['errors'] as Map<String, dynamic>? ?? {};
        throw ValidationException(
          raw.map((k, v) => MapEntry(k, List<String>.from(v))),
        );
      }
      throw ServerException(
        message: e.response?.data?['message'] ?? 'Erreur de connexion',
        statusCode: e.response?.statusCode,
      );
    }
  }
}
