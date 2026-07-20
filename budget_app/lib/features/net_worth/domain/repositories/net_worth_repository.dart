import '../entities/net_worth_snapshot.dart';

abstract class NetWorthRepository {
  Future<List<NetWorthSnapshot>> getSnapshots({int limit = 12});
  Future<NetWorthSnapshot> addSnapshot(NetWorthSnapshot snapshot);
  Future<void> deleteSnapshot(String id);
}
