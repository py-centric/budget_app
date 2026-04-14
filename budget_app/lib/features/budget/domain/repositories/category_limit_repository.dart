import '../entities/category_limit.dart';

abstract class CategoryLimitRepository {
  Future<List<CategoryLimit>> getLimitsForBudget(String budgetId);
  Future<CategoryLimit?> getLimitForCategory(
    String categoryId,
    String budgetId,
  );
  Future<void> saveLimit(CategoryLimit limit, String budgetId);
  Future<void> deleteLimit(String limitId);
  Future<double> getSpentAmountForCategory(
    String categoryId,
    int year,
    int month,
  );
}
