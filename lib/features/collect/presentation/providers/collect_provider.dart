import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/collect.dart';
import '../../domain/usecases/get_my_collects_usecase.dart';
import '../../domain/usecases/submit_collect_usecase.dart';

// ─── Submit state ─────────────────────────────────────────────────────────────

sealed class CollectSubmitState {
  const CollectSubmitState();
}

class CollectSubmitIdle extends CollectSubmitState {
  const CollectSubmitIdle();
}

class CollectSubmitLoading extends CollectSubmitState {
  const CollectSubmitLoading();
}

class CollectSubmitSuccess extends CollectSubmitState {
  /// true = sauvegardé offline, false = envoyé en ligne
  final bool offline;
  const CollectSubmitSuccess({this.offline = false});
}

class CollectSubmitError extends CollectSubmitState {
  final String message;
  const CollectSubmitError(this.message);
}

// ─── Submit notifier ──────────────────────────────────────────────────────────

class CollectNotifier extends StateNotifier<CollectSubmitState> {
  final SubmitCollectUsecase _submitUsecase;
  final GetMyCollectsUsecase _getUsecase;

  CollectNotifier(this._submitUsecase, this._getUsecase)
      : super(const CollectSubmitIdle());

  Future<void> submit(CollectFormData data) async {
    state = const CollectSubmitLoading();
    try {
      await _submitUsecase(data);
      state = const CollectSubmitSuccess();
    } catch (e) {
      final msg = e.toString();
      if (msg.contains('NetworkFailure') ||
          msg.contains('Pas de connexion')) {
        state = const CollectSubmitSuccess(offline: true);
      } else {
        state = CollectSubmitError(msg);
      }
    }
  }

  void reset() => state = const CollectSubmitIdle();
}

// ─── Providers (overrides dans di.dart) ──────────────────────────────────────

final collectProvider =
    StateNotifierProvider<CollectNotifier, CollectSubmitState>((ref) {
  throw UnimplementedError('Override collectProvider in ProviderScope');
});

final collectsListProvider =
    FutureProvider.autoDispose<List<Collect>>((ref) {
  throw UnimplementedError('Override collectsListProvider in ProviderScope');
});
