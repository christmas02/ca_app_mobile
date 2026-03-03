enum CollectStatus { enAttente, valide, rejete }

extension CollectStatusExt on CollectStatus {
  String get label => switch (this) {
        CollectStatus.enAttente => 'EN ATTENTE',
        CollectStatus.valide => 'VALIDÉ',
        CollectStatus.rejete => 'REJETÉ',
      };
}

/// Données du formulaire envoyées à l'API
class CollectFormData {
  final String nomClient;
  final String prenomClient;
  final String telephone;
  final String? telephoneSecondaire;
  final String observation;
  final String categorie;
  final String canal; // campagne | normal
  final String clientAsap; // OUI | NON
  final String immatriculation;
  final String lieuProspection;
  final String assuranceActuel;
  final String dateEcheance;
  final double latitude;
  final double longitude;
  final String? carteGrisePath;
  final String? attestationAssurancePath;

  const CollectFormData({
    required this.nomClient,
    required this.prenomClient,
    required this.telephone,
    this.telephoneSecondaire,
    required this.observation,
    required this.categorie,
    required this.canal,
    required this.clientAsap,
    required this.immatriculation,
    required this.lieuProspection,
    required this.assuranceActuel,
    required this.dateEcheance,
    required this.latitude,
    required this.longitude,
    this.carteGrisePath,
    this.attestationAssurancePath,
  });
}

/// Entité retournée par l'API (liste des collectes)
class Collect {
  final String id;
  final String nomClient;
  final String prenomClient;
  final String telephone;
  final CollectStatus status;
  final DateTime createdAt;

  const Collect({
    required this.id,
    required this.nomClient,
    required this.prenomClient,
    required this.telephone,
    required this.status,
    required this.createdAt,
  });

  String get fullName => '$prenomClient $nomClient';
}
