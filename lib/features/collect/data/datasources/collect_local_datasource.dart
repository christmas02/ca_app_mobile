import 'dart:convert';
import 'package:hive_flutter/hive_flutter.dart';
import '../../domain/entities/collect.dart';

abstract class CollectLocalDataSource {
  Future<void> savePendingCollect(CollectFormData data);
  Future<List<CollectFormData>> getPendingCollects();
  Future<void> clearPendingCollects();
}

class CollectLocalDataSourceImpl implements CollectLocalDataSource {
  static const _boxName = 'pending_collects';

  Box get _box => Hive.box(_boxName);

  @override
  Future<void> savePendingCollect(CollectFormData data) async {
    final json = {
      'nom_client': data.nomClient,
      'prenom_client': data.prenomClient,
      'telephone': data.telephone,
      'telephone_secondaire': data.telephoneSecondaire,
      'observation': data.observation,
      'categorie': data.categorie,
      'canal': data.canal,
      'client_asap': data.clientAsap,
      'immatriculation': data.immatriculation,
      'lieu_prospection': data.lieuProspection,
      'assurance_actuel': data.assuranceActuel,
      'date_echeance': data.dateEcheance,
      'latitude': data.latitude,
      'longitude': data.longitude,
      'carte_grise_path': data.carteGrisePath,
      'attestation_assurance_path': data.attestationAssurancePath,
      'saved_at': DateTime.now().toIso8601String(),
    };
    await _box.add(jsonEncode(json));
  }

  @override
  Future<List<CollectFormData>> getPendingCollects() async {
    return _box.values
        .cast<String>()
        .map((s) => _fromJson(jsonDecode(s) as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<void> clearPendingCollects() => _box.clear();

  CollectFormData _fromJson(Map<String, dynamic> json) => CollectFormData(
        nomClient: json['nom_client'] as String,
        prenomClient: json['prenom_client'] as String,
        telephone: json['telephone'] as String,
        telephoneSecondaire: json['telephone_secondaire'] as String?,
        observation: json['observation'] as String,
        categorie: json['categorie'] as String,
        canal: json['canal'] as String,
        clientAsap: json['client_asap'] as String,
        immatriculation: json['immatriculation'] as String,
        lieuProspection: json['lieu_prospection'] as String,
        assuranceActuel: json['assurance_actuel'] as String,
        dateEcheance: json['date_echeance'] as String,
        latitude: (json['latitude'] as num).toDouble(),
        longitude: (json['longitude'] as num).toDouble(),
        carteGrisePath: json['carte_grise_path'] as String?,
        attestationAssurancePath:
            json['attestation_assurance_path'] as String?,
      );
}
