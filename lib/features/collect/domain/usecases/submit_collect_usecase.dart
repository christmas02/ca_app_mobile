import '../entities/collect.dart';
import '../repositories/collect_repository.dart';

class SubmitCollectUsecase {
  final CollectRepository _repository;

  const SubmitCollectUsecase(this._repository);

  Future<void> call(CollectFormData data) =>
      _repository.submitCollect(data);
}
