import '../entities/recurring_transaction.dart';
import '../entities/recurring_override.dart';

abstract class RecurringRepository {
  Future<void> saveRecurringTransaction(RecurringTransaction recurring);
  Future<void> deleteRecurringTransaction(String id);
  Future<List<RecurringTransaction>> getAllRecurringTransactions();
  Future<RecurringTransaction?> getRecurringTransactionById(String id);
  
  Future<void> saveRecurringOverride(RecurringOverride override);
  Future<void> deleteRecurringOverride(String id);
  Future<List<RecurringOverride>> getOverridesForTemplate(String templateId);
  Future<List<RecurringOverride>> getAllOverrides();
}
