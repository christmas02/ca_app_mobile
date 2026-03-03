import '../../domain/entities/collect.dart';
import '../models/collect_model.dart';
import 'collect_remote_datasource.dart';

/// Datasource mocké — utilisé en mode développement (sans API réelle)
class CollectMockDataSource implements CollectRemoteDataSource {
  // Simule la liste côté serveur (mutable pour refléter les soumissions)
  final List<CollectModel> _store = [
    CollectModel(
      id: '1001',
      nomClient: 'Diallo',
      prenomClient: 'Ibrahim',
      telephone: '0701234567',
      status: CollectStatus.valide,
      createdAt: DateTime.now().subtract(const Duration(days: 5)),
    ),
    CollectModel(
      id: '1002',
      nomClient: 'Koné',
      prenomClient: 'Mariam',
      telephone: '0509876543',
      status: CollectStatus.enAttente,
      createdAt: DateTime.now().subtract(const Duration(days: 3)),
    ),
    CollectModel(
      id: '1003',
      nomClient: 'Yao',
      prenomClient: 'Armand',
      telephone: '0787654321',
      status: CollectStatus.rejete,
      createdAt: DateTime.now().subtract(const Duration(days: 2)),
    ),
    CollectModel(
      id: '1004',
      nomClient: 'Coulibaly',
      prenomClient: 'Fatoumata',
      telephone: '0712345678',
      status: CollectStatus.enAttente,
      createdAt: DateTime.now().subtract(const Duration(hours: 12)),
    ),
    CollectModel(
      id: '1005',
      nomClient: 'N\'Guessan',
      prenomClient: 'Paul',
      telephone: '0598765432',
      status: CollectStatus.valide,
      createdAt: DateTime.now().subtract(const Duration(hours: 4)),
    ),
  ];

  @override
  Future<void> submitCollect(CollectFormData data) async {
    await Future.delayed(const Duration(milliseconds: 1200));

    // Ajoute la nouvelle collecte en tête de liste
    _store.insert(
      0,
      CollectModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        nomClient: data.nomClient,
        prenomClient: data.prenomClient,
        telephone: data.telephone,
        status: CollectStatus.enAttente,
        createdAt: DateTime.now(),
      ),
    );
  }

  @override
  Future<List<CollectModel>> getMyCollects() async {
    await Future.delayed(const Duration(milliseconds: 600));
    // Retourne une copie triée par date décroissante
    return List.from(_store)
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }
}
