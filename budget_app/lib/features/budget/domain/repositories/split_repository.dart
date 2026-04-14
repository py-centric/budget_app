import '../entities/transaction_split.dart';

abstract class SplitRepository {
  Future<List<TransactionSplit>> getSplitsForTransaction(String parentId);
  Future<void> saveSplit(TransactionSplit split);
  Future<void> deleteSplit(String id);
  Future<void> deleteSplitsForTransaction(String parentId);
  Future<double> getTotalSplitAmount(String parentId);
  Future<bool> hasSplits(String parentId);
}
