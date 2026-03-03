import '../entities/user.dart';
import '../repositories/auth_repository.dart';

class LoginUsecase {
  final AuthRepository _repository;

  const LoginUsecase(this._repository);

  Future<({String token, User user})> call({
    required String identifiant,
    required String password,
  }) =>
      _repository.login(identifiant: identifiant, password: password);
}
