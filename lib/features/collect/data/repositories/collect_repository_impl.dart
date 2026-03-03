import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/network/network_info.dart';
import '../../domain/entities/collect.dart';
import '../../domain/repositories/collect_repository.dart';
import '../datasources/collect_local_datasource.dart';
import '../datasources/collect_remote_datasource.dart';

class CollectRepositoryImpl implements CollectRepository {
  final CollectRemoteDataSource _remote;
  final CollectLocalDataSource _local;
  final NetworkInfo _networkInfo;

  CollectRepositoryImpl(this._remote, this._local, this._networkInfo);

  // ── Submit : online → API, offline → Hive ─────────────────────────────────
  @override
  Future<void> submitCollect(CollectFormData data) async {
    final isConnected = await _networkInfo.isConnected;

    if (isConnected) {
      try {
        await _remote.submitCollect(data);
      } on ServerException catch (e) {
        throw ServerFailure(e.message);
      }
    } else {
      try {
        await _local.savePendingCollect(data);
        // On lève NetworkFailure pour que le provider informe l'UI
        throw const NetworkFailure();
      } on CacheException catch (e) {
        throw CacheFailure(e.message);
      }
    }
  }

  // ── Liste ──────────────────────────────────────────────────────────────────
  @override
  Future<List<Collect>> getMyCollects() async {
    if (!await _networkInfo.isConnected) throw const NetworkFailure();
    try {
      return await _remote.getMyCollects();
    } on ServerException catch (e) {
      throw ServerFailure(e.message);
    }
  }

  // ── Sync des collectes en attente (appelé au démarrage) ────────────────────
  @override
  Future<void> syncPendingCollects() async {
    if (!await _networkInfo.isConnected) return;

    final pending = await _local.getPendingCollects();
    if (pending.isEmpty) return;

    final failed = <CollectFormData>[];

    for (final data in pending) {
      try {
        await _remote.submitCollect(data);
      } catch (_) {
        failed.add(data);
      }
    }

    // Vider le cache puis remettre les échecs
    await _local.clearPendingCollects();
    for (final data in failed) {
      await _local.savePendingCollect(data);
    }
  }
}
