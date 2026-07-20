import '../entities/investment.dart';

abstract class InvestmentRepository {
  Future<List<Investment>> getAllInvestments();
  Future<Investment?> getInvestmentById(String id);
  Future<Investment> addInvestment(Investment investment);
  Future<void> updateInvestment(Investment investment);
  Future<void> deleteInvestment(String id);
}
