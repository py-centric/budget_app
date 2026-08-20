import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:budget_app/features/accounts/domain/entities/account.dart';
import 'package:budget_app/features/accounts/presentation/bloc/account_bloc.dart';
import 'package:budget_app/features/accounts/presentation/bloc/account_state.dart';
import 'package:budget_app/features/budget/domain/entities/income_entry.dart';
import 'package:budget_app/features/budget/domain/entities/expense_entry.dart';
import 'package:budget_app/features/budget/presentation/widgets/filter_bar.dart';
import 'package:budget_app/features/settings/presentation/bloc/settings_bloc.dart';

class MockSettingsBloc extends Cubit<SettingsState> implements SettingsBloc {
  MockSettingsBloc() : super(const SettingsState());

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class MockAccountBloc extends Cubit<AccountState> implements AccountBloc {
  MockAccountBloc(List<Account> accounts)
      : super(AccountLoaded(accounts: accounts, totalBalance: 6000.0));

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  final testAccounts = [
    Account(
      id: 'acc_1',
      name: 'Checking Account',
      type: AccountType.checking,
      balance: 1000.0,
      currency: 'USD',
      createdAt: DateTime(2026, 1, 1),
      updatedAt: DateTime(2026, 1, 1),
    ),
    Account(
      id: 'acc_2',
      name: 'Savings Account',
      type: AccountType.savings,
      balance: 5000.0,
      currency: 'USD',
      createdAt: DateTime(2026, 1, 1),
      updatedAt: DateTime(2026, 1, 1),
    ),
  ];

  final testIncomes = [
    IncomeEntry(
      id: 'inc_1',
      budgetId: 'b_1',
      amount: 1000.0,
      description: 'Main Salary',
      date: DateTime(2026, 4, 1),
      accountId: 'acc_1',
    ),
    IncomeEntry(
      id: 'inc_2',
      budgetId: 'b_1',
      amount: 200.0,
      description: 'Side Gig',
      date: DateTime(2026, 4, 2),
      accountId: 'acc_2',
    ),
    IncomeEntry(
      id: 'inc_3',
      budgetId: 'b_1',
      amount: 50.0,
      description: 'Cash gift',
      date: DateTime(2026, 4, 3),
      accountId: null,
    ),
  ];

  final testExpenses = [
    ExpenseEntry(
      id: 'exp_1',
      budgetId: 'b_1',
      amount: 100.0,
      categoryId: 'cat_groceries',
      description: 'Supermarket',
      date: DateTime(2026, 4, 1),
      accountId: 'acc_1',
    ),
    ExpenseEntry(
      id: 'exp_2',
      budgetId: 'b_1',
      amount: 50.0,
      categoryId: 'cat_dining',
      description: 'Dinner',
      date: DateTime(2026, 4, 2),
      accountId: 'acc_2',
    ),
  ];

  Widget createWidgetUnderTest() {
    return MultiBlocProvider(
      providers: [
        BlocProvider<SettingsBloc>(create: (_) => MockSettingsBloc()),
        BlocProvider<AccountBloc>(create: (_) => MockAccountBloc(testAccounts)),
      ],
      child: MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: FilterBar(
              incomeEntries: testIncomes,
              expenseEntries: testExpenses,
              onEditIncome: (_) {},
              onDeleteIncome: (_) {},
              onEditExpense: (_) {},
              onDeleteExpense: (_) {},
              incomeListBuilder: (entries, onEdit, onDelete, onConfirm, sortField, sortOrder, groupMode) {
                return Column(
                  children: entries.map((e) => Text('Income: ${e.description}')).toList(),
                );
              },
              expenseListBuilder: (entries, onEdit, onDelete, onConfirm, sortField, sortOrder, groupMode) {
                return Column(
                  children: entries.map((e) => Text('Expense: ${e.description}')).toList(),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  group('FilterBar Account Filtering Tests', () {
    testWidgets('renders Account filter button in FilterBar', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      expect(find.text('Account'), findsOneWidget);
    });

    testWidgets('opens AccountFilterSheet and filters transactions by selected account', (
      tester,
    ) async {
      await tester.pumpWidget(createWidgetUnderTest());

      expect(find.text('Income: Main Salary'), findsOneWidget);
      expect(find.text('Income: Side Gig'), findsOneWidget);
      expect(find.text('Income: Cash gift'), findsOneWidget);
      expect(find.text('Expense: Supermarket'), findsOneWidget);
      expect(find.text('Expense: Dinner'), findsOneWidget);

      // Tap Account filter button
      await tester.tap(find.text('Account'));
      await tester.pumpAndSettle();

      // In the sheet, select 'Checking Account'
      expect(find.text('Filter by Account'), findsOneWidget);
      await tester.tap(find.text('Checking Account'));
      await tester.pumpAndSettle();

      // Tap Apply
      await tester.tap(find.text('Apply'));
      await tester.pumpAndSettle();

      // Only checking account items should be visible
      expect(find.text('Income: Main Salary'), findsOneWidget);
      expect(find.text('Expense: Supermarket'), findsOneWidget);
      expect(find.text('Income: Side Gig'), findsNothing);
      expect(find.text('Income: Cash gift'), findsNothing);
      expect(find.text('Expense: Dinner'), findsNothing);

      // Verify Clear button is visible and clears filters
      expect(find.text('Clear'), findsOneWidget);
      await tester.tap(find.text('Clear'));
      await tester.pumpAndSettle();

      // All items restored
      expect(find.text('Income: Main Salary'), findsOneWidget);
      expect(find.text('Income: Side Gig'), findsOneWidget);
      expect(find.text('Income: Cash gift'), findsOneWidget);
      expect(find.text('Expense: Supermarket'), findsOneWidget);
      expect(find.text('Expense: Dinner'), findsOneWidget);
      expect(find.text('Clear'), findsNothing);
    });
  });
}
