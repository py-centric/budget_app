import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:budget_app/features/budget/domain/entities/expense_entry.dart';
import 'package:budget_app/features/budget/domain/entities/income_entry.dart';
import 'package:budget_app/features/budget/presentation/widgets/category_grouped_list.dart';
import 'package:budget_app/features/budget/presentation/widgets/filter_models.dart';

void main() {
  final testExpenses = [
    ExpenseEntry(
      id: 'exp-1',
      budgetId: 'b1',
      amount: 50.0,
      categoryId: 'food',
      categoryName: 'Food',
      description: 'Lunch',
      date: DateTime(2024, 1, 15),
    ),
    ExpenseEntry(
      id: 'exp-2',
      budgetId: 'b1',
      amount: 100.0,
      categoryId: 'transport',
      categoryName: 'Transport',
      description: 'Gas',
      date: DateTime(2024, 1, 20),
    ),
    ExpenseEntry(
      id: 'exp-3',
      budgetId: 'b1',
      amount: 30.0,
      categoryId: 'food',
      categoryName: 'Food',
      description: 'Coffee',
      date: DateTime(2024, 1, 25),
      isPotential: true,
    ),
  ];

  final testIncomes = [
    IncomeEntry(
      id: 'inc-1',
      budgetId: 'b1',
      amount: 5000.0,
      categoryId: 'salary',
      categoryName: 'Salary',
      description: 'Monthly salary',
      date: DateTime(2024, 1, 15),
    ),
    IncomeEntry(
      id: 'inc-2',
      budgetId: 'b1',
      amount: 500.0,
      categoryId: 'freelance',
      categoryName: 'Freelance',
      description: 'Side gig',
      date: DateTime(2024, 1, 20),
    ),
  ];

  Widget buildList({
    required List<dynamic> entries,
    required bool isExpense,
    Function(dynamic)? onEdit,
    Function(dynamic)? onDelete,
    Function(dynamic)? onConfirm,
    SortField sortField = SortField.date,
    SortOrder sortOrder = SortOrder.descending,
    GroupMode groupMode = GroupMode.category,
    Set<String>? disposableBudgetIds,
  }) {
    return MaterialApp(
      home: Scaffold(
        body: SingleChildScrollView(
          child: CategoryGroupedList(
            entries: entries,
            isExpense: isExpense,
            currencyCode: 'USD',
            onEdit: onEdit ?? (_) {},
            onDelete: onDelete ?? (_) {},
            onConfirm: onConfirm,
            sortField: sortField,
            sortOrder: sortOrder,
            groupMode: groupMode,
            disposableBudgetIds: disposableBudgetIds,
          ),
        ),
      ),
    );
  }

  group('CategoryGroupedList', () {
    group('Empty state', () {
      testWidgets('shows empty state for expenses', (tester) async {
        await tester.pumpWidget(buildList(entries: [], isExpense: true));

        expect(find.textContaining('No expense entries'), findsOneWidget);
      });

      testWidgets('shows empty state for income', (tester) async {
        await tester.pumpWidget(buildList(entries: [], isExpense: false));

        expect(find.textContaining('No income entries'), findsOneWidget);
      });
    });

    group('Category grouping', () {
      testWidgets('renders expense entries grouped by category', (tester) async {
        await tester.pumpWidget(buildList(
          entries: testExpenses,
          isExpense: true,
          groupMode: GroupMode.category,
        ));

        expect(find.textContaining('Food'), findsWidgets);
        expect(find.textContaining('Transport'), findsWidgets);
        expect(find.textContaining('Lunch'), findsOneWidget);
        expect(find.textContaining('Gas'), findsOneWidget);
      });

      testWidgets('renders income entries grouped by category', (tester) async {
        await tester.pumpWidget(buildList(
          entries: testIncomes,
          isExpense: false,
          groupMode: GroupMode.category,
        ));

        expect(find.textContaining('Salary'), findsWidgets);
        expect(find.textContaining('Freelance'), findsWidgets);
      });

      testWidgets('shows total row', (tester) async {
        await tester.pumpWidget(buildList(
          entries: testExpenses,
          isExpense: true,
          groupMode: GroupMode.category,
        ));

        expect(find.textContaining('Total'), findsOneWidget);
      });
    });

    group('Flat list grouping', () {
      testWidgets('renders entries in flat list', (tester) async {
        await tester.pumpWidget(buildList(
          entries: testExpenses,
          isExpense: true,
          groupMode: GroupMode.none,
        ));

        expect(find.textContaining('Lunch'), findsOneWidget);
        expect(find.textContaining('Gas'), findsOneWidget);
      });
    });

    group('Date grouping', () {
      testWidgets('renders entries grouped by month', (tester) async {
        await tester.pumpWidget(buildList(
          entries: testExpenses,
          isExpense: true,
          groupMode: GroupMode.dateMonth,
        ));

        expect(find.textContaining('January 2024'), findsOneWidget);
      });

      testWidgets('renders entries grouped by week', (tester) async {
        await tester.pumpWidget(buildList(
          entries: testExpenses,
          isExpense: true,
          groupMode: GroupMode.dateWeek,
        ));

        expect(find.byIcon(Icons.view_week), findsWidgets);
      });
    });

    group('Sorting', () {
      testWidgets('sorts by amount ascending', (tester) async {
        await tester.pumpWidget(buildList(
          entries: testExpenses,
          isExpense: true,
          groupMode: GroupMode.none,
          sortField: SortField.amount,
          sortOrder: SortOrder.ascending,
        ));

        expect(find.textContaining('Lunch'), findsOneWidget);
      });

      testWidgets('sorts by name', (tester) async {
        await tester.pumpWidget(buildList(
          entries: testExpenses,
          isExpense: true,
          groupMode: GroupMode.none,
          sortField: SortField.name,
          sortOrder: SortOrder.ascending,
        ));

        expect(find.textContaining('Gas'), findsOneWidget);
      });
    });

    group('Potential entries', () {
      testWidgets('shows potential badge for potential expenses', (tester) async {
        await tester.pumpWidget(buildList(
          entries: testExpenses,
          isExpense: true,
          groupMode: GroupMode.none,
        ));

        expect(find.text('(Potential)'), findsOneWidget);
      });

      testWidgets('shows potential badge for potential incomes', (tester) async {
        final potentialIncomes = [
          IncomeEntry(
            id: 'inc-pot',
            budgetId: 'b1',
            amount: 1000,
            categoryId: 'cat-1',
            description: 'Maybe income',
            date: DateTime(2024, 1, 15),
            isPotential: true,
          ),
        ];

        await tester.pumpWidget(buildList(
          entries: potentialIncomes,
          isExpense: false,
          groupMode: GroupMode.none,
        ));

        expect(find.text('(Potential)'), findsOneWidget);
      });
    });

    group('Disposable budget badge', () {
      testWidgets('shows disposable icon for disposable budget entries', (tester) async {
        await tester.pumpWidget(buildList(
          entries: testExpenses,
          isExpense: true,
          groupMode: GroupMode.none,
          disposableBudgetIds: {'b1'},
        ));

        expect(find.byIcon(Icons.all_inbox), findsWidgets);
      });

      testWidgets('does not show disposable icon when no disposable ids', (tester) async {
        await tester.pumpWidget(buildList(
          entries: testExpenses,
          isExpense: true,
          groupMode: GroupMode.none,
        ));

        expect(find.byIcon(Icons.all_inbox), findsNothing);
      });
    });

    group('Group collapsing', () {
      testWidgets('category groups have InkWell for collapsing', (tester) async {
        await tester.pumpWidget(buildList(
          entries: testExpenses,
          isExpense: true,
          groupMode: GroupMode.category,
        ));

        expect(find.byType(InkWell), findsWidgets);
        expect(find.textContaining('Lunch'), findsOneWidget);
      });
    });

    group('Entry icons', () {
      testWidgets('shows correct icon for expense entries', (tester) async {
        await tester.pumpWidget(buildList(
          entries: testExpenses,
          isExpense: true,
          groupMode: GroupMode.none,
        ));

        expect(find.byIcon(Icons.arrow_upward), findsWidgets);
      });

      testWidgets('shows correct icon for income entries', (tester) async {
        await tester.pumpWidget(buildList(
          entries: testIncomes,
          isExpense: false,
          groupMode: GroupMode.none,
        ));

        expect(find.byIcon(Icons.arrow_downward), findsWidgets);
      });
    });
  });
}
