abstract class Failure {
  final String message;
  const Failure(this.message);

  @override
  String toString() => message;
}

class ServerFailure extends Failure {
  const ServerFailure(super.message);
}

class NetworkFailure extends Failure {
  const NetworkFailure() : super('Pas de connexion internet');
}

class UnauthorizedFailure extends Failure {
  const UnauthorizedFailure()
      : super('Session expirée, veuillez vous reconnecter');
}

class ValidationFailure extends Failure {
  final Map<String, List<String>> errors;
  const ValidationFailure(this.errors) : super('Erreur de validation');

  String get firstMessage =>
      errors.values.firstOrNull?.firstOrNull ?? super.message;
}

class CacheFailure extends Failure {
  const CacheFailure(super.message);
}
