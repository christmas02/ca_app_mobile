import 'package:dio/dio.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/errors/exceptions.dart';
import '../../domain/entities/collect.dart';
import '../models/collect_model.dart';

abstract class CollectRemoteDataSource {
  Future<void> submitCollect(CollectFormData data);
  Future<List<CollectModel>> getMyCollects();
}

class CollectRemoteDataSourceImpl implements CollectRemoteDataSource {
  final Dio _dio;

  CollectRemoteDataSourceImpl(this._dio);

  // ── Submit multipart/form-data ─────────────────────────────────────────────
  @override
  Future<void> submitCollect(CollectFormData data) async {
    try {
      final formData = FormData.fromMap({
        'nom_client': data.nomClient,
        'prenom_client': data.prenomClient,
        'telephone': data.telephone,
        if (data.telephoneSecondaire != null)
          'telephone_secondaire': data.telephoneSecondaire,
        'observation': data.observation,
        'categorie': data.categorie,
        'canal': data.canal,
        'client_asap': data.clientAsap,
        'immatriculation': data.immatriculation,
        'lieu_prospection': data.lieuProspection,
        'assurance_actuel': data.assuranceActuel,
        'date_echeance': data.dateEcheance,
        'latitude': data.latitude.toString(),
        'longitude': data.longitude.toString(),
        if (data.carteGrisePath != null)
          'carte_grise': await _compressAndWrap(data.carteGrisePath!),
        if (data.attestationAssurancePath != null)
          'attestation_assurance':
              await _compressAndWrap(data.attestationAssurancePath!),
      });

      await _dio.post(
        ApiConstants.collect,
        data: formData,
        options: Options(contentType: 'multipart/form-data'),
      );
    } on DioException catch (e) {
      throw ServerException(
        message: e.response?.data?['message'] ?? 'Erreur lors de la soumission',
        statusCode: e.response?.statusCode,
      );
    }
  }

  // ── GET /my-collects ───────────────────────────────────────────────────────
  @override
  Future<List<CollectModel>> getMyCollects() async {
    try {
      final response = await _dio.get(ApiConstants.myCollects);
      final raw = response.data;
      final list = (raw is Map ? raw['data'] : raw) as List;
      return list.cast<Map<String, dynamic>>().map(CollectModel.fromJson).toList();
    } on DioException catch (e) {
      throw ServerException(
        message: e.response?.data?['message'] ?? 'Erreur de chargement',
        statusCode: e.response?.statusCode,
      );
    }
  }

  // ── Compression image avant upload ────────────────────────────────────────
  Future<MultipartFile> _compressAndWrap(String path) async {
    final bytes = await FlutterImageCompress.compressWithFile(
      path,
      quality: 70,
      minWidth: 1024,
      minHeight: 1024,
    );
    final fileName = path.split('/').last;
    if (bytes == null) return await MultipartFile.fromFile(path, filename: fileName);
    return MultipartFile.fromBytes(bytes, filename: fileName);
  }
}
