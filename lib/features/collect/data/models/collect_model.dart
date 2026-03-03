import '../../domain/entities/collect.dart';

class CollectModel extends Collect {
  const CollectModel({
    required super.id,
    required super.nomClient,
    required super.prenomClient,
    required super.telephone,
    required super.status,
    required super.createdAt,
  });

  factory CollectModel.fromJson(Map<String, dynamic> json) => CollectModel(
        id: json['id'].toString(),
        nomClient: json['nom_client'] as String? ?? '',
        prenomClient: json['prenom_client'] as String? ?? '',
        telephone: json['telephone'] as String? ?? '',
        status: _parseStatus(json['statut'] as String?),
        createdAt: DateTime.tryParse(
                json['created_at'] as String? ?? '') ??
            DateTime.now(),
      );

  static CollectStatus _parseStatus(String? raw) => switch (raw) {
        'VALIDE' || 'VALIDÉ' => CollectStatus.valide,
        'REJETE' || 'REJETÉ' => CollectStatus.rejete,
        _ => CollectStatus.enAttente,
      };

  Map<String, dynamic> toJson() => {
        'id': id,
        'nom_client': nomClient,
        'prenom_client': prenomClient,
        'telephone': telephone,
        'statut': status.label,
        'created_at': createdAt.toIso8601String(),
      };
}
