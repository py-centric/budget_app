import '../entities/saved_calculation.dart';

abstract class FinancialRepository {
  Future<void> saveCalculation(SavedCalculation calculation);
  Future<List<SavedCalculation>> getSavedCalculations();
  Future<void> deleteCalculation(String id);
}
