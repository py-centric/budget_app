import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:budget_app/features/budget/domain/entities/category.dart';
import 'package:budget_app/features/budget/domain/entities/recurring_transaction.dart';
import 'package:budget_app/features/budget/presentation/widgets/split_transaction_dialog.dart';
import 'package:budget_app/features/budget/presentation/widgets/transaction_form.dart';
import 'package:budget_app/features/accounts/domain/entities/account.dart';
import 'package:budget_app/features/settings/presentation/bloc/settings_bloc.dart';

class MockSettingsBloc extends Cubit<SettingsState> implements SettingsBloc {
  MockSettingsBloc() : super(const SettingsState());

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  final testCategories = [
    const Category(
      id: 'cat_food',
      name: 'Food',
      icon: 'restaurant',
      type: CategoryType.expense,
    ),
    const Category(
      id: 'cat_salary',
      name: 'Salary',
      icon: 'work',
      type: CategoryType.income,
    ),
  ];

  final testAccounts = [
    Account(
      id: 'acc_1',
      name: 'Main Checking',
      type: AccountType.checking,
      balance: 1000.0,
      currency: 'USD',
      createdAt: DateTime(2026, 1, 1),
      updatedAt: DateTime(2026, 1, 1),
    ),
    Account(
      id: 'acc_2',
      name: 'Savings Goal',
      type: AccountType.savings,
      balance: 5000.0,
      currency: 'USD',
      createdAt: DateTime(2026, 1, 1),
      updatedAt: DateTime(2026, 1, 1),
    ),
  ];

  Widget createWidgetUnderTest({
    required bool isIncome,
    required Function(
      String id,
      double amount,
      String categoryId,
      String? description,
      DateTime date, {
      bool isRecurring,
      int? interval,
      RecurrenceUnit? unit,
      DateTime? endDate,
      bool isPotential,
      List<SplitItem>? splits,
      String? targetBudgetId,
      String? accountId,
    })
    onSubmit,
  }) {
    return BlocProvider<SettingsBloc>(
      create: (_) => MockSettingsBloc(),
      child: MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: TransactionForm(
              isIncome: isIncome,
              categories: testCategories,
              accounts: testAccounts,
              periodYear: 2026,
              periodMonth: 4,
              onSubmit:
                  (
                    id,
                    amount,
                    categoryId,
                    description,
                    date, {
                    isRecurring = false,
                    interval,
                    unit,
                    endDate,
                    isPotential = false,
                    splits,
                    targetBudgetId,
                    accountId,
                  }) {
                    onSubmit(
                      id,
                      amount,
                      categoryId,
                      description,
                      date,
                      isRecurring: isRecurring,
                      interval: interval,
                      unit: unit,
                      endDate: endDate,
                      isPotential: isPotential,
                      splits: splits,
                      targetBudgetId: targetBudgetId,
                      accountId: accountId,
                    );
                  },
            ),
          ),
        ),
      ),
    );
  }

  group('TransactionForm Account Picker Widget Tests', () {
    testWidgets('renders account selector with default None / Unassigned option', (
      tester,
    ) async {
      await tester.pumpWidget(
        createWidgetUnderTest(
          isIncome: true,
          onSubmit: (a, b, c, d, e, {accountId, endDate, interval, isPotential = false, isRecurring = false, splits, targetBudgetId, unit}) {},
        ),
      );

      expect(find.byKey(const Key('transaction_account_dropdown')), findsOneWidget);
      expect(find.text('None (Unassigned)'), findsOneWidget);
    });

    testWidgets('allows selecting an account and submitting with accountId', (
      tester,
    ) async {
      String? submittedAccountId;

      await tester.pumpWidget(
        createWidgetUnderTest(
          isIncome: true,
          onSubmit: (
            id,
            amount,
            categoryId,
            description,
            date, {
            accountId,
            endDate,
            interval,
            isPotential = false,
            isRecurring = false,
            splits,
            targetBudgetId,
            unit,
          }) {
            submittedAccountId = accountId;
          },
        ),
      );

      // Enter amount
      await tester.enterText(find.byType(TextFormField).first, '120.00');

      // Select Account dropdown
      await tester.tap(find.byKey(const Key('transaction_account_dropdown')));
      await tester.pumpAndSettle();

      // Tap 'Main Checking'
      await tester.tap(find.text('Main Checking').last);
      await tester.pumpAndSettle();

      // Submit
      final submitButton = find.widgetWithText(ElevatedButton, 'Add Income');
      await tester.ensureVisible(submitButton);
      await tester.tap(submitButton);
      await tester.pumpAndSettle();

      expect(submittedAccountId, equals('acc_1'));
    });
  });
}
