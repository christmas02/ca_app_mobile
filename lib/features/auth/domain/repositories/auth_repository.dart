import '../entities/user.dart';

abstract class AuthRepository {
  Future<({String token, User user})> login({
    required String identifiant,
    required String password,
  });

  Future<void> logout();

  Future<String?> getStoredToken();

  Future<User?> getStoredUser();
}
