import '../models/user_model.dart';
import 'auth_remote_datasource.dart';

/// Datasource mocké — utilisé en mode développement (sans API réelle)
class AuthMockDataSource implements AuthRemoteDataSource {
  static const _validCredentials = {
    'agent01': 'password',
    'agent02': 'password',
    'superviseur': 'admin123',
  };

  static final _users = {
    'agent01': UserModel(
      id: 1,
      nom: 'Kouassi Jean',
      identifiant: 'agent01',
      zone: 'Abidjan Nord',
    ),
    'agent02': UserModel(
      id: 2,
      nom: 'Traoré Aminata',
      identifiant: 'agent02',
      zone: 'Abidjan Sud',
    ),
    'superviseur': UserModel(
      id: 3,
      nom: 'Bamba Sékou',
      identifiant: 'superviseur',
      zone: 'Toutes zones',
    ),
  };

  @override
  Future<({String token, UserModel user})> login({
    required String identifiant,
    required String password,
  }) async {
    // Simuler un délai réseau
    await Future.delayed(const Duration(milliseconds: 800));

    final validPassword = _validCredentials[identifiant];
    if (validPassword == null || validPassword != password) {
      throw Exception('Identifiant ou mot de passe incorrect');
    }

    return (
      token: 'mock_jwt_token_${identifiant}_${DateTime.now().millisecondsSinceEpoch}',
      user: _users[identifiant]!,
    );
  }
}
