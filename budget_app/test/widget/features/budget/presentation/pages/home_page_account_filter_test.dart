import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:budget_app/features/accounts/domain/entities/account.dart';
import 'package:budget_app/features/accounts/presentation/bloc/account_bloc.dart';
import 'package:budget_app/features/accounts/presentation/bloc/account_state.dart';
import 'package:budget_app/features/budget/domain/entities/budget.dart';
import 'package:budget_app/features/budget/domain/entities/budget_period.dart';
import 'package:budget_app/features/budget/domain/entities/income_entry.dart';
import 'package:budget_app/features/budget/domain/entities/expense_entry.dart';
import 'package:budget_app/features/budget/domain/usecases/calculate_summary.dart';
import 'package:budget_app/features/budget/presentation/bloc/budget_bloc.dart';
import 'package:budget_app/features/budget/presentation/bloc/budget_state.dart';
import 'package:budget_app/features/budget/presentation/bloc/navigation_bloc.dart';
import 'package:budget_app/features/budget/presentation/bloc/category_bloc.dart';
import 'package:budget_app/features/budget/presentation/widgets/filter_bar.dart';
import 'package:budget_app/features/settings/presentation/bloc/settings_bloc.dart';

class MockSettingsBloc extends Cubit<SettingsState> implements SettingsBloc {
  MockSettingsBloc() : super(const SettingsState());

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class MockAccountBloc extends Cubit<AccountState> implements AccountBloc {
  MockAccountBloc(List<Account> accounts)
      : super(AccountLoaded(accounts: accounts, totalBalance: 5000.0));

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class MockNavigationBloc extends Cubit<NavigationState> implements NavigationBloc {
  MockNavigationBloc()
      : super(
          const NavigationState(
            currentPeriod: BudgetPeriod(year: 2026, month: 4),
            activeBudget: Budget(
              id: 'b_1',
              name: 'Main Budget',
              periodMonth: 4,
              periodYear: 2026,
              isActive: true,
            ),
          ),
        );

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class MockCategoryBloc extends Cubit<CategoryState> implements CategoryBloc {
  MockCategoryBloc() : super(CategoryInitial());

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class MockBudgetBloc extends Cubit<BudgetState> implements BudgetBloc {
  MockBudgetBloc(BudgetSummary summary) : super(SummaryLoaded(summary));

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
      description: 'Primary Salary',
      date: DateTime(2026, 4, 1),
      accountId: 'acc_1',
      accountName: 'Checking Account',
    ),
    IncomeEntry(
      id: 'inc_2',
      budgetId: 'b_1',
      amount: 500.0,
      description: 'Interest',
      date: DateTime(2026, 4, 2),
      accountId: 'acc_2',
      accountName: 'Savings Account',
    ),
  ];

  final testExpenses = [
    ExpenseEntry(
      id: 'exp_1',
      budgetId: 'b_1',
      amount: 200.0,
      categoryId: 'cat_rent',
      description: 'Rent',
      date: DateTime(2026, 4, 1),
      accountId: 'acc_1',
      accountName: 'Checking Account',
    ),
    ExpenseEntry(
      id: 'exp_2',
      budgetId: 'b_1',
      amount: 100.0,
      categoryId: 'cat_invest',
      description: 'Investment',
      date: DateTime(2026, 4, 2),
      accountId: 'acc_2',
      accountName: 'Savings Account',
    ),
  ];

  final summary = BudgetSummary(
    totalIncome: 1500.0,
    totalExpenses: 300.0,
    balance: 1200.0,
    totalPotentialIncome: 1500.0,
    totalPotentialExpenses: 300.0,
    incomeEntries: testIncomes,
    expenseEntries: testExpenses,
  );

  Widget createWidgetUnderTest() {
    return MultiBlocProvider(
      providers: [
        BlocProvider<SettingsBloc>(create: (_) => MockSettingsBloc()),
        BlocProvider<AccountBloc>(create: (_) => MockAccountBloc(testAccounts)),
        BlocProvider<NavigationBloc>(create: (_) => MockNavigationBloc()),
        BlocProvider<CategoryBloc>(create: (_) => MockCategoryBloc()),
        BlocProvider<BudgetBloc>(create: (_) => MockBudgetBloc(summary)),
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

  group('HomePage and FilterBar Dynamic Summary Tests', () {
    testWidgets('FilterBar header updates total dynamically when account filter applied', (
      tester,
    ) async {
      await tester.pumpWidget(createWidgetUnderTest());

      // Initial total headers
      expect(find.text('Income'), findsWidgets);
      expect(find.text('Expenses'), findsWidgets);
      expect(find.text('Primary Salary'), findsNothing); // Listed via builder
      expect(find.text('Income: Primary Salary'), findsOneWidget);
      expect(find.text('Income: Interest'), findsOneWidget);

      // Filter by Checking Account
      await tester.tap(find.text('Account'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Checking Account'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Apply'));
      await tester.pumpAndSettle();

      // Only checking entries remain
      expect(find.text('Income: Primary Salary'), findsOneWidget);
      expect(find.text('Expense: Rent'), findsOneWidget);
      expect(find.text('Income: Interest'), findsNothing);
      expect(find.text('Expense: Investment'), findsNothing);
    });
  });
}
