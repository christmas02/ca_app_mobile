import '../entities/collect.dart';
import '../repositories/collect_repository.dart';

class GetMyCollectsUsecase {
  final CollectRepository _repository;

  const GetMyCollectsUsecase(this._repository);

  Future<List<Collect>> call() => _repository.getMyCollects();
}
