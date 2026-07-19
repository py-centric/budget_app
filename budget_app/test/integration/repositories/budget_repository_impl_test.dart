import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:budget_app/features/budget/domain/entities/budget.dart';
import 'package:budget_app/features/budget/domain/entities/income_entry.dart';
import 'package:budget_app/features/budget/domain/entities/expense_entry.dart';
import 'package:budget_app/features/budget/domain/entities/category.dart';
import 'package:budget_app/features/budget/domain/entities/budget_period.dart';
import 'package:budget_app/features/budget/data/repositories/budget_repository_impl.dart';
import 'package:budget_app/features/budget/data/datasources/local_database.dart';

Future<void> setupTestDatabase() async {
  sqfliteFfiInit();

  final db = await databaseFactoryFfi.openDatabase(
    inMemoryDatabasePath,
    options: OpenDatabaseOptions(
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE budgets (
            id TEXT PRIMARY KEY,
            name TEXT NOT NULL,
            period_month INTEGER NOT NULL,
            period_year INTEGER NOT NULL,
            is_active INTEGER NOT NULL DEFAULT 1,
            currency_code TEXT DEFAULT 'USD',
            target_currency_code TEXT,
            exchange_rate REAL,
            converted_amount REAL,
            type TEXT NOT NULL DEFAULT 'regular',
            target_income REAL,
            source_description TEXT,
            linked_income_id TEXT
          )
        ''');

        await db.execute('''
          CREATE TABLE income_entries (
            id TEXT PRIMARY KEY,
            budget_id TEXT NOT NULL,
            amount REAL NOT NULL,
            description TEXT,
            date TEXT NOT NULL,
            period_month INTEGER,
            period_year INTEGER,
            category_id TEXT,
            is_potential INTEGER NOT NULL DEFAULT 0,
            FOREIGN KEY (budget_id) REFERENCES budgets (id) ON DELETE CASCADE
          )
        ''');

        await db.execute('''
          CREATE TABLE expense_entries (
            id TEXT PRIMARY KEY,
            budget_id TEXT NOT NULL,
            amount REAL NOT NULL,
            description TEXT,
            date TEXT NOT NULL,
            period_month INTEGER,
            period_year INTEGER,
            category_id TEXT,
            is_potential INTEGER NOT NULL DEFAULT 0,
            FOREIGN KEY (budget_id) REFERENCES budgets (id) ON DELETE CASCADE
          )
        ''');

        await db.execute('''
          CREATE TABLE categories (
            id TEXT PRIMARY KEY,
            name TEXT NOT NULL,
            icon TEXT,
            type TEXT NOT NULL,
            UNIQUE(name, type)
          )
        ''');

        await db.execute('''
          CREATE TABLE IF NOT EXISTS transaction_splits (
            id TEXT PRIMARY KEY,
            category_id TEXT
          )
        ''');

        await db.execute('''
          CREATE TABLE IF NOT EXISTS savings_goals (
            id TEXT PRIMARY KEY,
            linked_category_id TEXT
          )
        ''');

        await db.execute('''
          CREATE TABLE IF NOT EXISTS category_limits (
            id TEXT PRIMARY KEY,
            category_id TEXT NOT NULL
          )
        ''');
      },
      onConfigure: (db) async {
        await db.execute('PRAGMA foreign_keys = ON');
      },
    ),
  );

  LocalDatabase.setTestDatabase(db);
}

void main() {
  late BudgetRepositoryImpl repository;

  setUp(() async {
    await setupTestDatabase();
    repository = BudgetRepositoryImpl(LocalDatabase.instance);
  });

  tearDown(() async {
    final db = await LocalDatabase.instance.database;
    await db.close();
    LocalDatabase.resetForTesting();
  });

  group('BudgetRepositoryImpl - Disposable Budgets', () {
    group('addBudget / getBudget', () {
      test('can add and retrieve a regular budget', () async {
        const budget = Budget(
          id: 'b1',
          name: 'January 2024',
          periodMonth: 1,
          periodYear: 2024,
        );
        await repository.addBudget(budget);

        final result = await repository.getBudget('b1');
        expect(result, isNotNull);
        expect(result!.name, 'January 2024');
        expect(result.type, BudgetType.regular);
      });

      test('can add and retrieve a disposable budget', () async {
        const budget = Budget(
          id: 'd1',
          name: 'Equipment Fund',
          periodMonth: 1,
          periodYear: 2024,
          type: BudgetType.disposable,
          targetIncome: 5000.0,
          sourceDescription: 'Freelance payment',
        );
        await repository.addBudget(budget);

        final result = await repository.getBudget('d1');
        expect(result, isNotNull);
        expect(result!.type, BudgetType.disposable);
        expect(result.targetIncome, 5000.0);
        expect(result.sourceDescription, 'Freelance payment');
      });

      test('can add disposable budget with linkedIncomeId', () async {
        const budget = Budget(
          id: 'd2',
          name: 'Linked Fund',
          periodMonth: 1,
          periodYear: 2024,
          type: BudgetType.disposable,
          targetIncome: 3000.0,
          sourceDescription: 'Linked income',
          linkedIncomeId: 'inc-1',
        );
        await repository.addBudget(budget);

        final result = await repository.getBudget('d2');
        expect(result, isNotNull);
        expect(result!.linkedIncomeId, 'inc-1');
      });
    });

    group('updateBudget', () {
      test('can update budget type from disposable to disposed', () async {
        const budget = Budget(
          id: 'd1',
          name: 'Fund',
          periodMonth: 1,
          periodYear: 2024,
          type: BudgetType.disposable,
          targetIncome: 5000.0,
          sourceDescription: 'Freelance',
        );
        await repository.addBudget(budget);

        final updated = budget.copyWith(type: BudgetType.disposed);
        await repository.updateBudget(updated);

        final result = await repository.getBudget('d1');
        expect(result, isNotNull);
        expect(result!.type, BudgetType.disposed);
      });

      test('can update budget type from disposable to persisted', () async {
        const budget = Budget(
          id: 'd1',
          name: 'Fund',
          periodMonth: 1,
          periodYear: 2024,
          type: BudgetType.disposable,
          targetIncome: 5000.0,
          sourceDescription: 'Freelance',
        );
        await repository.addBudget(budget);

        final updated = budget.copyWith(type: BudgetType.persisted);
        await repository.updateBudget(updated);

        final result = await repository.getBudget('d1');
        expect(result, isNotNull);
        expect(result!.type, BudgetType.persisted);
      });

      test('can update targetIncome and sourceDescription', () async {
        const budget = Budget(
          id: 'd1',
          name: 'Fund',
          periodMonth: 1,
          periodYear: 2024,
          type: BudgetType.disposable,
          targetIncome: 5000.0,
          sourceDescription: 'Original',
        );
        await repository.addBudget(budget);

        final updated = budget.copyWith(
          targetIncome: 7000.0,
          sourceDescription: 'Updated',
        );
        await repository.updateBudget(updated);

        final result = await repository.getBudget('d1');
        expect(result, isNotNull);
        expect(result!.targetIncome, 7000.0);
        expect(result.sourceDescription, 'Updated');
      });

      test('can link income to budget', () async {
        const budget = Budget(
          id: 'd1',
          name: 'Fund',
          periodMonth: 1,
          periodYear: 2024,
          type: BudgetType.disposable,
          targetIncome: 5000.0,
          sourceDescription: 'Freelance',
        );
        await repository.addBudget(budget);

        final updated = budget.copyWith(linkedIncomeId: 'inc-1');
        await repository.updateBudget(updated);

        final result = await repository.getBudget('d1');
        expect(result, isNotNull);
        expect(result!.linkedIncomeId, 'inc-1');
      });

      test('can set linkedIncomeId on budget', () async {
        const budget = Budget(
          id: 'd1',
          name: 'Fund',
          periodMonth: 1,
          periodYear: 2024,
          type: BudgetType.disposable,
          targetIncome: 5000.0,
          sourceDescription: 'Freelance',
        );
        await repository.addBudget(budget);

        final result1 = await repository.getBudget('d1');
        expect(result1!.linkedIncomeId, isNull);

        final updated = budget.copyWith(linkedIncomeId: 'inc-1');
        await repository.updateBudget(updated);

        final result2 = await repository.getBudget('d1');
        expect(result2!.linkedIncomeId, 'inc-1');
      });
    });

    group('getActiveDisposableBudgets', () {
      test('returns only disposable budgets', () async {
        await repository.addBudget(const Budget(
          id: 'b1',
          name: 'Regular',
          periodMonth: 1,
          periodYear: 2024,
          type: BudgetType.regular,
        ));
        await repository.addBudget(const Budget(
          id: 'd1',
          name: 'Disposable 1',
          periodMonth: 1,
          periodYear: 2024,
          type: BudgetType.disposable,
          targetIncome: 5000.0,
          sourceDescription: 'Fund 1',
        ));
        await repository.addBudget(const Budget(
          id: 'd2',
          name: 'Disposed',
          periodMonth: 2,
          periodYear: 2024,
          type: BudgetType.disposed,
          targetIncome: 3000.0,
          sourceDescription: 'Old fund',
        ));
        await repository.addBudget(const Budget(
          id: 'd3',
          name: 'Persisted',
          periodMonth: 3,
          periodYear: 2024,
          type: BudgetType.persisted,
          targetIncome: 2000.0,
          sourceDescription: 'Converted fund',
        ));

        final result = await repository.getActiveDisposableBudgets();
        expect(result.length, 1);
        expect(result.first.id, 'd1');
        expect(result.first.type, BudgetType.disposable);
      });

      test('returns empty list when no disposable budgets', () async {
        await repository.addBudget(const Budget(
          id: 'b1',
          name: 'Regular',
          periodMonth: 1,
          periodYear: 2024,
        ));

        final result = await repository.getActiveDisposableBudgets();
        expect(result, isEmpty);
      });

      test('returns multiple disposable budgets ordered by period desc', () async {
        await repository.addBudget(const Budget(
          id: 'd1',
          name: 'January Fund',
          periodMonth: 1,
          periodYear: 2024,
          type: BudgetType.disposable,
          targetIncome: 5000.0,
          sourceDescription: 'Jan',
        ));
        await repository.addBudget(const Budget(
          id: 'd2',
          name: 'March Fund',
          periodMonth: 3,
          periodYear: 2024,
          type: BudgetType.disposable,
          targetIncome: 3000.0,
          sourceDescription: 'Mar',
        ));
        await repository.addBudget(const Budget(
          id: 'd3',
          name: 'December Fund',
          periodMonth: 12,
          periodYear: 2023,
          type: BudgetType.disposable,
          targetIncome: 1000.0,
          sourceDescription: 'Dec',
        ));

        final result = await repository.getActiveDisposableBudgets();
        expect(result.length, 3);
        expect(result[0].id, 'd2');
        expect(result[1].id, 'd1');
        expect(result[2].id, 'd3');
      });
    });

    group('getDisposableHistory', () {
      test('returns disposed and persisted budgets', () async {
        await repository.addBudget(const Budget(
          id: 'b1',
          name: 'Regular',
          periodMonth: 1,
          periodYear: 2024,
          type: BudgetType.regular,
        ));
        await repository.addBudget(const Budget(
          id: 'd1',
          name: 'Active Disposable',
          periodMonth: 1,
          periodYear: 2024,
          type: BudgetType.disposable,
          targetIncome: 5000.0,
          sourceDescription: 'Active',
        ));
        await repository.addBudget(const Budget(
          id: 'd2',
          name: 'Disposed Fund',
          periodMonth: 2,
          periodYear: 2024,
          type: BudgetType.disposed,
          targetIncome: 3000.0,
          sourceDescription: 'Disposed',
        ));
        await repository.addBudget(const Budget(
          id: 'd3',
          name: 'Persisted Fund',
          periodMonth: 3,
          periodYear: 2024,
          type: BudgetType.persisted,
          targetIncome: 2000.0,
          sourceDescription: 'Persisted',
        ));

        final result = await repository.getDisposableHistory();
        expect(result.length, 2);
        expect(result.any((b) => b.id == 'd2'), isTrue);
        expect(result.any((b) => b.id == 'd3'), isTrue);
        expect(result.any((b) => b.id == 'd1'), isFalse);
        expect(result.any((b) => b.id == 'b1'), isFalse);
      });

      test('returns empty list when no history', () async {
        await repository.addBudget(const Budget(
          id: 'b1',
          name: 'Regular',
          periodMonth: 1,
          periodYear: 2024,
        ));

        final result = await repository.getDisposableHistory();
        expect(result, isEmpty);
      });

      test('returns history ordered by period desc', () async {
        await repository.addBudget(const Budget(
          id: 'd1',
          name: 'January',
          periodMonth: 1,
          periodYear: 2024,
          type: BudgetType.disposed,
          targetIncome: 5000.0,
          sourceDescription: 'Jan',
        ));
        await repository.addBudget(const Budget(
          id: 'd2',
          name: 'March',
          periodMonth: 3,
          periodYear: 2024,
          type: BudgetType.persisted,
          targetIncome: 3000.0,
          sourceDescription: 'Mar',
        ));
        await repository.addBudget(const Budget(
          id: 'd3',
          name: 'December 2023',
          periodMonth: 12,
          periodYear: 2023,
          type: BudgetType.disposed,
          targetIncome: 1000.0,
          sourceDescription: 'Dec',
        ));

        final result = await repository.getDisposableHistory();
        expect(result.length, 3);
        expect(result[0].id, 'd2');
        expect(result[1].id, 'd1');
        expect(result[2].id, 'd3');
      });
    });

    group('deleteBudget', () {
      test('deletes budget and associated entries', () async {
        await repository.addBudget(const Budget(
          id: 'd1',
          name: 'Fund',
          periodMonth: 1,
          periodYear: 2024,
          type: BudgetType.disposable,
          targetIncome: 5000.0,
          sourceDescription: 'Fund',
        ));

        await repository.addIncome(IncomeEntry(
          id: 'inc-1',
          budgetId: 'd1',
          amount: 5000,
          categoryId: 'cat-1',
          date: DateTime(2024, 1, 1),
        ));

        await repository.addExpense(ExpenseEntry(
          id: 'exp-1',
          budgetId: 'd1',
          amount: 1200,
          categoryId: 'cat-2',
          date: DateTime(2024, 1, 10),
        ));

        await repository.deleteBudget('d1');

        final budget = await repository.getBudget('d1');
        expect(budget, isNull);

        final incomes = await repository.getIncomeForBudget('d1');
        expect(incomes, isEmpty);

        final expenses = await repository.getExpensesForBudget('d1');
        expect(expenses, isEmpty);
      });
    });

    group('getExpensesForBudget', () {
      test('returns expenses for specific budget', () async {
        await repository.addBudget(const Budget(
          id: 'd1',
          name: 'Fund',
          periodMonth: 1,
          periodYear: 2024,
          type: BudgetType.disposable,
          targetIncome: 5000.0,
          sourceDescription: 'Fund',
        ));
        await repository.addBudget(const Budget(
          id: 'b1',
          name: 'Regular',
          periodMonth: 1,
          periodYear: 2024,
        ));

        await repository.addExpense(ExpenseEntry(
          id: 'exp-1',
          budgetId: 'd1',
          amount: 1200,
          categoryId: 'cat-1',
          date: DateTime(2024, 1, 10),
        ));
        await repository.addExpense(ExpenseEntry(
          id: 'exp-2',
          budgetId: 'd1',
          amount: 800,
          categoryId: 'cat-2',
          date: DateTime(2024, 1, 15),
        ));
        await repository.addExpense(ExpenseEntry(
          id: 'exp-3',
          budgetId: 'b1',
          amount: 500,
          categoryId: 'cat-1',
          date: DateTime(2024, 1, 5),
        ));

        final expenses = await repository.getExpensesForBudget('d1');
        expect(expenses.length, 2);
        expect(expenses.every((e) => e.budgetId == 'd1'), isTrue);
      });

      test('returns empty list when no expenses', () async {
        await repository.addBudget(const Budget(
          id: 'd1',
          name: 'Fund',
          periodMonth: 1,
          periodYear: 2024,
          type: BudgetType.disposable,
          targetIncome: 5000.0,
          sourceDescription: 'Fund',
        ));

        final expenses = await repository.getExpensesForBudget('d1');
        expect(expenses, isEmpty);
      });
    });

    group('getIncomeForBudget', () {
      test('returns incomes for specific budget', () async {
        await repository.addBudget(const Budget(
          id: 'd1',
          name: 'Fund',
          periodMonth: 1,
          periodYear: 2024,
          type: BudgetType.disposable,
          targetIncome: 5000.0,
          sourceDescription: 'Fund',
        ));

        await repository.addIncome(IncomeEntry(
          id: 'inc-1',
          budgetId: 'd1',
          amount: 5000,
          categoryId: 'cat-1',
          date: DateTime(2024, 1, 1),
        ));
        await repository.addIncome(IncomeEntry(
          id: 'inc-2',
          budgetId: 'd1',
          amount: 2000,
          categoryId: 'cat-1',
          date: DateTime(2024, 1, 15),
        ));

        final incomes = await repository.getIncomeForBudget('d1');
        expect(incomes.length, 2);
      });
    });

    group('clearAllBudgets', () {
      test('clears all budgets and entries', () async {
        await repository.addBudget(const Budget(
          id: 'd1',
          name: 'Disposable',
          periodMonth: 1,
          periodYear: 2024,
          type: BudgetType.disposable,
          targetIncome: 5000.0,
          sourceDescription: 'Fund',
        ));
        await repository.addBudget(const Budget(
          id: 'b1',
          name: 'Regular',
          periodMonth: 1,
          periodYear: 2024,
        ));

        await repository.addIncome(IncomeEntry(
          id: 'inc-1',
          budgetId: 'd1',
          amount: 5000,
          categoryId: 'cat-1',
          date: DateTime(2024, 1, 1),
        ));

        await repository.clearAllBudgets();

        final disposable = await repository.getActiveDisposableBudgets();
        expect(disposable, isEmpty);

        final allIncome = await repository.getAllIncome();
        expect(allIncome, isEmpty);
      });
    });

    group('BudgetModel serialization', () {
      test('BudgetModel.fromMap handles all BudgetType values', () async {
        for (final type in BudgetType.values) {
          await repository.addBudget(Budget(
            id: 'test-${type.name}',
            name: 'Test ${type.name}',
            periodMonth: 1,
            periodYear: 2024,
            type: type,
            targetIncome: type == BudgetType.regular ? null : 5000.0,
            sourceDescription: type == BudgetType.regular ? null : 'Test',
          ));

          final result = await repository.getBudget('test-${type.name}');
          expect(result, isNotNull);
          expect(result!.type, type);
        }
      });

      test('BudgetModel preserves linkedIncomeId through round-trip', () async {
        const budget = Budget(
          id: 'linked',
          name: 'Linked Fund',
          periodMonth: 1,
          periodYear: 2024,
          type: BudgetType.disposable,
          targetIncome: 5000.0,
          sourceDescription: 'Linked',
          linkedIncomeId: 'income-abc-123',
        );
        await repository.addBudget(budget);

        final result = await repository.getBudget('linked');
        expect(result, isNotNull);
        expect(result!.linkedIncomeId, 'income-abc-123');
      });
    });

    group('updateIncome', () {
      test('updates an existing income entry', () async {
        await repository.addBudget(const Budget(
          id: 'b1',
          name: 'Budget',
          periodMonth: 1,
          periodYear: 2024,
        ));

        final income = IncomeEntry(
          id: 'inc-1',
          budgetId: 'b1',
          amount: 5000,
          categoryId: 'cat-1',
          description: 'Original',
          date: DateTime(2024, 1, 1),
        );
        await repository.addIncome(income);

        final updated = IncomeEntry(
          id: 'inc-1',
          budgetId: 'b1',
          amount: 6000,
          categoryId: 'cat-1',
          description: 'Updated',
          date: DateTime(2024, 1, 1),
        );
        await repository.updateIncome(updated);

        final incomes = await repository.getAllIncome();
        expect(incomes.length, 1);
        expect(incomes.first.amount, 6000);
        expect(incomes.first.description, 'Updated');
      });
    });

    group('deleteIncome', () {
      test('deletes an income entry', () async {
        await repository.addBudget(const Budget(
          id: 'b1',
          name: 'Budget',
          periodMonth: 1,
          periodYear: 2024,
        ));

        await repository.addIncome(IncomeEntry(
          id: 'inc-1',
          budgetId: 'b1',
          amount: 5000,
          categoryId: 'cat-1',
          date: DateTime(2024, 1, 1),
        ));
        await repository.addIncome(IncomeEntry(
          id: 'inc-2',
          budgetId: 'b1',
          amount: 3000,
          categoryId: 'cat-1',
          date: DateTime(2024, 1, 15),
        ));

        await repository.deleteIncome('inc-1');

        final incomes = await repository.getAllIncome();
        expect(incomes.length, 1);
        expect(incomes.first.id, 'inc-2');
      });
    });

    group('updateExpense', () {
      test('updates an existing expense entry', () async {
        await repository.addBudget(const Budget(
          id: 'b1',
          name: 'Budget',
          periodMonth: 1,
          periodYear: 2024,
        ));

        final expense = ExpenseEntry(
          id: 'exp-1',
          budgetId: 'b1',
          amount: 100,
          categoryId: 'cat-1',
          description: 'Original',
          date: DateTime(2024, 1, 1),
        );
        await repository.addExpense(expense);

        final updated = ExpenseEntry(
          id: 'exp-1',
          budgetId: 'b1',
          amount: 200,
          categoryId: 'cat-1',
          description: 'Updated',
          date: DateTime(2024, 1, 1),
        );
        await repository.updateExpense(updated);

        final expenses = await repository.getAllExpenses();
        expect(expenses.length, 1);
        expect(expenses.first.amount, 200);
        expect(expenses.first.description, 'Updated');
      });
    });

    group('deleteExpense', () {
      test('deletes an expense entry', () async {
        await repository.addBudget(const Budget(
          id: 'b1',
          name: 'Budget',
          periodMonth: 1,
          periodYear: 2024,
        ));

        await repository.addExpense(ExpenseEntry(
          id: 'exp-1',
          budgetId: 'b1',
          amount: 100,
          categoryId: 'cat-1',
          date: DateTime(2024, 1, 1),
        ));
        await repository.addExpense(ExpenseEntry(
          id: 'exp-2',
          budgetId: 'b1',
          amount: 200,
          categoryId: 'cat-1',
          date: DateTime(2024, 1, 15),
        ));

        await repository.deleteExpense('exp-1');

        final expenses = await repository.getAllExpenses();
        expect(expenses.length, 1);
        expect(expenses.first.id, 'exp-2');
      });
    });

    group('getAllExpenses', () {
      test('returns all expenses across budgets', () async {
        await repository.addBudget(const Budget(
          id: 'b1',
          name: 'Budget 1',
          periodMonth: 1,
          periodYear: 2024,
        ));
        await repository.addBudget(const Budget(
          id: 'b2',
          name: 'Budget 2',
          periodMonth: 2,
          periodYear: 2024,
        ));

        await repository.addExpense(ExpenseEntry(
          id: 'exp-1',
          budgetId: 'b1',
          amount: 100,
          categoryId: 'cat-1',
          date: DateTime(2024, 1, 1),
        ));
        await repository.addExpense(ExpenseEntry(
          id: 'exp-2',
          budgetId: 'b2',
          amount: 200,
          categoryId: 'cat-1',
          date: DateTime(2024, 2, 1),
        ));

        final expenses = await repository.getAllExpenses();
        expect(expenses.length, 2);
      });
    });

    group('getIncomeForPeriod', () {
      test('returns income for specific period', () async {
        await repository.addBudget(const Budget(
          id: 'b1',
          name: 'Budget',
          periodMonth: 1,
          periodYear: 2024,
        ));

        await repository.addIncome(IncomeEntry(
          id: 'inc-1',
          budgetId: 'b1',
          amount: 5000,
          categoryId: 'cat-1',
          date: DateTime(2024, 1, 15),
          periodMonth: 1,
          periodYear: 2024,
        ));
        await repository.addIncome(IncomeEntry(
          id: 'inc-2',
          budgetId: 'b1',
          amount: 3000,
          categoryId: 'cat-1',
          date: DateTime(2024, 2, 15),
          periodMonth: 2,
          periodYear: 2024,
        ));

        final incomes = await repository.getIncomeForPeriod(
          const BudgetPeriod(year: 2024, month: 1),
        );
        expect(incomes.length, 1);
        expect(incomes.first.id, 'inc-1');
      });
    });

    group('getExpensesForPeriod', () {
      test('returns expenses for specific period', () async {
        await repository.addBudget(const Budget(
          id: 'b1',
          name: 'Budget',
          periodMonth: 1,
          periodYear: 2024,
        ));

        await repository.addExpense(ExpenseEntry(
          id: 'exp-1',
          budgetId: 'b1',
          amount: 100,
          categoryId: 'cat-1',
          date: DateTime(2024, 1, 10),
          periodMonth: 1,
          periodYear: 2024,
        ));
        await repository.addExpense(ExpenseEntry(
          id: 'exp-2',
          budgetId: 'b1',
          amount: 200,
          categoryId: 'cat-1',
          date: DateTime(2024, 2, 10),
          periodMonth: 2,
          periodYear: 2024,
        ));

        final expenses = await repository.getExpensesForPeriod(
          const BudgetPeriod(year: 2024, month: 1),
        );
        expect(expenses.length, 1);
        expect(expenses.first.id, 'exp-1');
      });
    });

    group('getIncomeForDateRange', () {
      test('returns income within date range', () async {
        await repository.addBudget(const Budget(
          id: 'b1',
          name: 'Budget',
          periodMonth: 1,
          periodYear: 2024,
        ));

        await repository.addIncome(IncomeEntry(
          id: 'inc-1',
          budgetId: 'b1',
          amount: 5000,
          categoryId: 'cat-1',
          date: DateTime(2024, 1, 10),
        ));
        await repository.addIncome(IncomeEntry(
          id: 'inc-2',
          budgetId: 'b1',
          amount: 3000,
          categoryId: 'cat-1',
          date: DateTime(2024, 3, 10),
        ));

        final incomes = await repository.getIncomeForDateRange(
          DateTime(2024, 1, 1),
          DateTime(2024, 2, 28),
        );
        expect(incomes.length, 1);
        expect(incomes.first.id, 'inc-1');
      });
    });

    group('getExpensesForDateRange', () {
      test('returns expenses within date range', () async {
        await repository.addBudget(const Budget(
          id: 'b1',
          name: 'Budget',
          periodMonth: 1,
          periodYear: 2024,
        ));

        await repository.addExpense(ExpenseEntry(
          id: 'exp-1',
          budgetId: 'b1',
          amount: 100,
          categoryId: 'cat-1',
          date: DateTime(2024, 1, 10),
        ));
        await repository.addExpense(ExpenseEntry(
          id: 'exp-2',
          budgetId: 'b1',
          amount: 200,
          categoryId: 'cat-1',
          date: DateTime(2024, 3, 10),
        ));

        final expenses = await repository.getExpensesForDateRange(
          DateTime(2024, 1, 1),
          DateTime(2024, 2, 28),
        );
        expect(expenses.length, 1);
        expect(expenses.first.id, 'exp-1');
      });
    });

    group('getIncomeBefore', () {
      test('returns income before a date', () async {
        await repository.addBudget(const Budget(
          id: 'b1',
          name: 'Budget',
          periodMonth: 1,
          periodYear: 2024,
        ));

        await repository.addIncome(IncomeEntry(
          id: 'inc-1',
          budgetId: 'b1',
          amount: 5000,
          categoryId: 'cat-1',
          date: DateTime(2024, 1, 10),
        ));
        await repository.addIncome(IncomeEntry(
          id: 'inc-2',
          budgetId: 'b1',
          amount: 3000,
          categoryId: 'cat-1',
          date: DateTime(2024, 6, 10),
        ));

        final incomes = await repository.getIncomeBefore(DateTime(2024, 3, 1));
        expect(incomes.length, 1);
        expect(incomes.first.id, 'inc-1');
      });
    });

    group('getExpensesBefore', () {
      test('returns expenses before a date', () async {
        await repository.addBudget(const Budget(
          id: 'b1',
          name: 'Budget',
          periodMonth: 1,
          periodYear: 2024,
        ));

        await repository.addExpense(ExpenseEntry(
          id: 'exp-1',
          budgetId: 'b1',
          amount: 100,
          categoryId: 'cat-1',
          date: DateTime(2024, 1, 10),
        ));
        await repository.addExpense(ExpenseEntry(
          id: 'exp-2',
          budgetId: 'b1',
          amount: 200,
          categoryId: 'cat-1',
          date: DateTime(2024, 6, 10),
        ));

        final expenses = await repository.getExpensesBefore(DateTime(2024, 3, 1));
        expect(expenses.length, 1);
        expect(expenses.first.id, 'exp-1');
      });
    });

    group('getBudgetsForPeriod', () {
      test('returns budgets for specific period', () async {
        await repository.addBudget(const Budget(
          id: 'b1',
          name: 'January Budget',
          periodMonth: 1,
          periodYear: 2024,
        ));
        await repository.addBudget(const Budget(
          id: 'b2',
          name: 'February Budget',
          periodMonth: 2,
          periodYear: 2024,
        ));

        final budgets = await repository.getBudgetsForPeriod(
          const BudgetPeriod(year: 2024, month: 1),
        );
        expect(budgets.length, 1);
        expect(budgets.first.id, 'b1');
      });
    });

    group('getCategories', () {
      test('returns categories from database', () async {
        final db = await LocalDatabase.instance.database;
        await db.insert('categories', {
          'id': 'food',
          'name': 'Food',
          'type': 'expense',
          'icon': 'restaurant',
        });
        await db.insert('categories', {
          'id': 'salary',
          'name': 'Salary',
          'type': 'income',
          'icon': 'attach_money',
        });

        final categories = await repository.getCategories();
        expect(categories.length, greaterThanOrEqualTo(2));
        expect(categories.any((c) => c.id == 'food'), isTrue);
        expect(categories.any((c) => c.id == 'salary'), isTrue);
      });
    });

    group('getCategoriesByType', () {
      test('returns expense categories', () async {
        final db = await LocalDatabase.instance.database;
        await db.insert('categories', {
          'id': 'food',
          'name': 'Food',
          'type': 'expense',
          'icon': 'restaurant',
        });
        await db.insert('categories', {
          'id': 'salary',
          'name': 'Salary',
          'type': 'income',
          'icon': 'attach_money',
        });

        final categories = await repository.getCategoriesByType(
          CategoryType.expense,
        );
        expect(categories.any((c) => c.id == 'food'), isTrue);
        expect(categories.any((c) => c.id == 'salary'), isFalse);
      });

      test('returns income categories', () async {
        final db = await LocalDatabase.instance.database;
        await db.insert('categories', {
          'id': 'food',
          'name': 'Food',
          'type': 'expense',
          'icon': 'restaurant',
        });
        await db.insert('categories', {
          'id': 'salary',
          'name': 'Salary',
          'type': 'income',
          'icon': 'attach_money',
        });

        final categories = await repository.getCategoriesByType(
          CategoryType.income,
        );
        expect(categories.any((c) => c.id == 'salary'), isTrue);
        expect(categories.any((c) => c.id == 'food'), isFalse);
      });
    });

    group('addCategory / updateCategory / deleteCategory', () {
      test('can add, update, and delete a category', () async {
        const category = Category(
          id: 'test-cat',
          name: 'Test Category',
          type: CategoryType.expense,
          icon: 'star',
        );

        await repository.addCategory(category);
        var categories = await repository.getCategories();
        expect(categories.any((c) => c.id == 'test-cat'), isTrue);

        const updated = Category(
          id: 'test-cat',
          name: 'Updated Category',
          type: CategoryType.expense,
          icon: 'star',
        );
        await repository.updateCategory(updated);
        categories = await repository.getCategories();
        final found = categories.firstWhere((c) => c.id == 'test-cat');
        expect(found.name, 'Updated Category');

        await repository.deleteCategory('test-cat');
        categories = await repository.getCategories();
        expect(categories.any((c) => c.id == 'test-cat'), isFalse);
      });
    });

    group('getAvailablePeriods', () {
      test('returns unique periods from budgets', () async {
        await repository.addBudget(const Budget(
          id: 'b1',
          name: 'Jan 2024',
          periodMonth: 1,
          periodYear: 2024,
        ));
        await repository.addBudget(const Budget(
          id: 'b2',
          name: 'Feb 2024',
          periodMonth: 2,
          periodYear: 2024,
        ));
        await repository.addBudget(const Budget(
          id: 'b3',
          name: 'Jan 2024 Again',
          periodMonth: 1,
          periodYear: 2024,
        ));

        final periods = await repository.getAvailablePeriods();
        expect(periods.length, greaterThanOrEqualTo(2));
        expect(
          periods.any((p) => p.year == 2024 && p.month == 1),
          isTrue,
        );
        expect(
          periods.any((p) => p.year == 2024 && p.month == 2),
          isTrue,
        );
      });
    });
  });
}
