import '../entities/collect.dart';

abstract class CollectRepository {
  Future<void> submitCollect(CollectFormData data);
  Future<List<Collect>> getMyCollects();
  Future<void> syncPendingCollects();
}
