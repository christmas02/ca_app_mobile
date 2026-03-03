import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/network/dio_client.dart';
import 'core/network/network_info.dart';
import 'core/storage/secure_storage.dart';
import 'features/auth/data/datasources/auth_mock_datasource.dart';
import 'features/auth/data/datasources/auth_remote_datasource.dart';
import 'features/auth/data/repositories/auth_repository_impl.dart';
import 'features/auth/domain/usecases/login_usecase.dart';
import 'features/auth/presentation/providers/auth_provider.dart';
import 'features/collect/data/datasources/collect_local_datasource.dart';
import 'features/collect/data/datasources/collect_mock_datasource.dart';
import 'features/collect/data/datasources/collect_remote_datasource.dart';
import 'features/collect/data/repositories/collect_repository_impl.dart';
import 'features/collect/domain/usecases/get_my_collects_usecase.dart';
import 'features/collect/domain/usecases/submit_collect_usecase.dart';
import 'features/collect/presentation/providers/collect_provider.dart';

/// ─── Basculer ici entre mock et prod ─────────────────────────────────────────
const bool kMockMode = true; // false → appels API réels
/// ─────────────────────────────────────────────────────────────────────────────

final _secureStorage = SecureStorageService();
final _networkInfo = NetworkInfoImpl(Connectivity());

// ── Auth datasource ───────────────────────────────────────────────────────────
AuthRemoteDataSource _buildAuthDS() {
  if (kMockMode) return AuthMockDataSource();
  final dioClient = DioClient(_secureStorage);
  return AuthRemoteDataSourceImpl(dioClient.instance);
}

// ── Collect datasource ────────────────────────────────────────────────────────
CollectRemoteDataSource _buildCollectDS() {
  if (kMockMode) return CollectMockDataSource();
  final dioClient = DioClient(_secureStorage);
  return CollectRemoteDataSourceImpl(dioClient.instance);
}

// ── Wiring ────────────────────────────────────────────────────────────────────
final _authRepo = AuthRepositoryImpl(_buildAuthDS(), _secureStorage);
final _loginUsecase = LoginUsecase(_authRepo);

final _collectLocalDS = CollectLocalDataSourceImpl();
final _collectRepo = CollectRepositoryImpl(
  _buildCollectDS(),
  _collectLocalDS,
  _networkInfo,
);
final _submitCollect = SubmitCollectUsecase(_collectRepo);
final _getMyCollects = GetMyCollectsUsecase(_collectRepo);

/// Overrides injectés dans le ProviderScope racine
class AppDI {
  static List<Override> get overrides => [
        authProvider.overrideWith(
          (ref) => AuthNotifier(_loginUsecase),
        ),
        collectProvider.overrideWith(
          (ref) => CollectNotifier(_submitCollect, _getMyCollects),
        ),
        collectsListProvider.overrideWith(
          (ref) async {
            final collects = await _getMyCollects();
            if (!kMockMode) unawaited(_collectRepo.syncPendingCollects());
            return collects;
          },
        ),
      ];
}

void unawaited(Future<void> future) => future.ignore();
