import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:budget_app/features/budget/domain/entities/income_entry.dart';
import 'package:budget_app/features/budget/domain/entities/expense_entry.dart';
import 'package:budget_app/features/budget/domain/usecases/calculate_summary.dart';
import 'package:budget_app/features/budget/presentation/widgets/summary_card.dart';
import 'package:budget_app/features/settings/presentation/bloc/settings_bloc.dart';

class MockSettingsBloc extends MockBloc<SettingsEvent, SettingsState> implements SettingsBloc {}

void main() {
  late MockSettingsBloc mockSettingsBloc;

  setUp(() {
    mockSettingsBloc = MockSettingsBloc();
    when(() => mockSettingsBloc.state).thenReturn(const SettingsState());
  });

  Widget createWidgetUnderTest(BudgetSummary summary) {
    return MaterialApp(
      home: Scaffold(
        body: BlocProvider<SettingsBloc>.value(
          value: mockSettingsBloc,
          child: SummaryCard(summary: summary),
        ),
      ),
    );
  }

  group('SummaryCard Widget Tests', () {
    testWidgets('should display positive balance correctly', (
      WidgetTester tester,
    ) async {
      final summary = BudgetSummary(
        totalIncome: 1000.0,
        totalExpenses: 300.0,
        balance: 700.0,
        totalPotentialIncome: 1000.0,
        totalPotentialExpenses: 300.0,
        incomeEntries: [
          IncomeEntry(id: '1', budgetId: 'default', amount: 1000.0, date: DateTime(2026, 1, 15)),
        ],
        expenseEntries: [
          ExpenseEntry(
            id: '1',
            budgetId: 'default',
            amount: 300.0,
            categoryId: 'Food',
            date: DateTime(2026, 1, 15),
          ),
        ],
      );

      await tester.pumpWidget(createWidgetUnderTest(summary));

      expect(find.text('Budget Summary'), findsOneWidget);
      expect(find.text('Income'), findsOneWidget);
      expect(find.text('Expenses'), findsOneWidget);
      expect(find.text('Balance'), findsOneWidget);
      expect(find.text('\$1,000.00'), findsOneWidget);
      expect(find.text('\$300.00'), findsOneWidget);
      expect(find.text('\$700.00'), findsOneWidget);
    });

    testWidgets('should display negative balance correctly', (
      WidgetTester tester,
    ) async {
      final summary = BudgetSummary(
        totalIncome: 500.0,
        totalExpenses: 800.0,
        balance: -300.0,
        totalPotentialIncome: 500.0,
        totalPotentialExpenses: 800.0,
        incomeEntries: [
          IncomeEntry(id: '1', budgetId: 'default', amount: 500.0, date: DateTime(2026, 1, 15)),
        ],
        expenseEntries: [
          ExpenseEntry(
            id: '1',
            budgetId: 'default',
            amount: 800.0,
            categoryId: 'Food',
            date: DateTime(2026, 1, 15),
          ),
        ],
      );

      await tester.pumpWidget(createWidgetUnderTest(summary));

      expect(find.text('\$500.00'), findsOneWidget);
      expect(find.text('\$800.00'), findsOneWidget);
      expect(find.textContaining('300.00'), findsOneWidget);
    });

    testWidgets('should display zero balance correctly', (
      WidgetTester tester,
    ) async {
      final summary = BudgetSummary(
        totalIncome: 500.0,
        totalExpenses: 500.0,
        balance: 0.0,
        totalPotentialIncome: 500.0,
        totalPotentialExpenses: 500.0,
        incomeEntries: [
          IncomeEntry(id: '1', budgetId: 'default', amount: 500.0, date: DateTime(2026, 1, 15)),
        ],
        expenseEntries: [
          ExpenseEntry(
            id: '1',
            budgetId: 'default',
            amount: 500.0,
            categoryId: 'Food',
            date: DateTime(2026, 1, 15),
          ),
        ],
      );

      await tester.pumpWidget(createWidgetUnderTest(summary));

      expect(find.textContaining(RegExp(r'\$ ?0\.00')), findsOneWidget);
    });

    testWidgets('should handle empty entries', (WidgetTester tester) async {
      final summary = BudgetSummary(
        totalIncome: 0.0,
        totalExpenses: 0.0,
        balance: 0.0,
        totalPotentialIncome: 0.0,
        totalPotentialExpenses: 0.0,
        incomeEntries: [],
        expenseEntries: [],
      );

      await tester.pumpWidget(createWidgetUnderTest(summary));

      expect(find.textContaining(RegExp(r'\$ ?0\.00')), findsNWidgets(3));
    });
  });
}

