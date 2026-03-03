class ServerException implements Exception {
  final String message;
  final int? statusCode;
  const ServerException({required this.message, this.statusCode});

  @override
  String toString() => 'ServerException: $message (HTTP $statusCode)';
}

class NetworkException implements Exception {
  const NetworkException();

  @override
  String toString() => 'NetworkException: Pas de connexion internet';
}

class UnauthorizedException implements Exception {
  const UnauthorizedException();

  @override
  String toString() => 'UnauthorizedException: Session expirée';
}

class ValidationException implements Exception {
  final Map<String, List<String>> errors;
  const ValidationException(this.errors);

  String get firstMessage =>
      errors.values.firstOrNull?.firstOrNull ?? 'Erreur de validation';

  @override
  String toString() => 'ValidationException: $errors';
}

class CacheException implements Exception {
  final String message;
  const CacheException({required this.message});

  @override
  String toString() => 'CacheException: $message';
}
