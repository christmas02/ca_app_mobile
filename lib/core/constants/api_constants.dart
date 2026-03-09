class ApiConstants {
  ApiConstants._();

  // Android emulator → 10.0.2.2 = hôte machine | iOS simulator → 127.0.0.1
  // static const String baseUrl = 'http://10.0.2.2:8002/api';
  static const String baseUrl = 'http://www.crmconseilsassurci.com/api';

  static const Duration connectTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);

  // Endpoints
  static const String login = '/login';
  static const String logout = '/logout';
  static const String collect = '/collect';
  static const String myCollects = '/my-collects';
}
