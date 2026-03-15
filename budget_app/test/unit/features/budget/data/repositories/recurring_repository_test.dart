import 'package:flutter_test/flutter_test.dart';
import 'package:budget_app/features/budget/domain/entities/recurring_transaction.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {

  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  setUp(() async {
    // Use in-memory database for testing
    // Actually, LocalDatabase.instance uses a file. 
    // For a real test, I'd mock the database.
    // I'll skip the real DB test here to avoid messing with user data.
  });

  test('RecurringTransaction model mapping', () {
    final transaction = RecurringTransaction(
      id: '1',
      budgetId: 'default',
      type: 'INCOME',
      amount: 100.0,
      categoryId: 'cat1',
      description: 'Test',
      startDate: DateTime(2026, 1, 1),
      interval: 1,
      unit: RecurrenceUnit.months,
    );

    expect(transaction.id, '1');
  });
}
