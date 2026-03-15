import '../entities/recurring_override.dart';
import '../repositories/recurring_repository.dart';

class ApplyRecurringOverride {
  final RecurringRepository repository;

  ApplyRecurringOverride(this.repository);

  Future<void> call(RecurringOverride override) async {
    await repository.saveRecurringOverride(override);
  }
}
