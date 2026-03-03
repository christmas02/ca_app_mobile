class ApiConstants {
  ApiConstants._();

  static const String baseUrl = 'https://api.votre-domaine.ci/api';

  static const Duration connectTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);

  // Endpoints
  static const String login = '/login';
  static const String logout = '/logout';
  static const String collect = '/collect';
  static const String myCollects = '/my-collects';
}
