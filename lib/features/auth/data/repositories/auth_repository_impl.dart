import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/storage/secure_storage.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_datasource.dart';
import '../models/user_model.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource _remote;
  final SecureStorageService _secureStorage;

  AuthRepositoryImpl(this._remote, this._secureStorage);

  @override
  Future<({String token, User user})> login({
    required String identifiant,
    required String password,
  }) async {
    try {
      final result = await _remote.login(identifiant: identifiant, password: password);
      await _secureStorage.saveToken(result.token);
      await _secureStorage.saveUser(result.user.toJsonString());
      return result;
    } on UnauthorizedException {
      throw const UnauthorizedFailure();
    } on ValidationException catch (e) {
      throw ValidationFailure(e.errors);
    } on ServerException catch (e) {
      throw ServerFailure(e.message);
    }
  }

  @override
  Future<void> logout() => _secureStorage.clearAll();

  @override
  Future<String?> getStoredToken() => _secureStorage.getToken();

  @override
  Future<User?> getStoredUser() async {
    final json = await _secureStorage.getUser();
    if (json == null) return null;
    return UserModel.fromJsonString(json);
  }
}
