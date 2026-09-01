import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mocktail/mocktail.dart';
import 'package:budget_app/features/budget/presentation/widgets/transaction_edit_dialog.dart';
import 'package:budget_app/features/budget/domain/entities/income_entry.dart';
import 'package:budget_app/features/budget/domain/entities/expense_entry.dart';
import 'package:budget_app/features/budget/domain/entities/category.dart';
import 'package:budget_app/features/budget/presentation/bloc/budget_bloc.dart';
import 'package:budget_app/features/budget/presentation/bloc/budget_event.dart';
import 'package:budget_app/features/budget/presentation/bloc/budget_state.dart';

class MockBudgetBloc extends Mock implements BudgetBloc {}

class UpdateIncomeEventFake extends Fake implements UpdateIncomeEvent {}
class UpdateExpenseEventFake extends Fake implements UpdateExpenseEvent {}

void main() {
  setUpAll(() {
    registerFallbackValue(UpdateIncomeEventFake());
    registerFallbackValue(UpdateExpenseEventFake());
  });

  late MockBudgetBloc mockBudgetBloc;
  final categories = [
    const Category(
      id: '1',
      name: 'Salary',
      type: CategoryType.income,
      icon: 'attach_money',
    ),
    const Category(
      id: '2',
      name: 'Groceries',
      type: CategoryType.expense,
      icon: 'shopping_cart',
    ),
  ];
  final income = IncomeEntry(
    id: '1',
    budgetId: 'default',
    amount: 1000.0,
    categoryId: '1',
    date: DateTime(2024, 1, 1),
    description: 'Initial salary',
    isPotential: false,
  );
  final potentialExpense = ExpenseEntry(
    id: '2',
    budgetId: 'default',
    amount: 150.0,
    categoryId: '2',
    date: DateTime(2024, 1, 5),
    description: 'Weekly groceries',
    isPotential: true,
  );

  setUp(() {
    mockBudgetBloc = MockBudgetBloc();
    when(() => mockBudgetBloc.state).thenReturn(const BudgetInitial());
    when(() => mockBudgetBloc.stream).thenAnswer((_) => const Stream.empty());
  });

  testWidgets('TransactionEditDialog shows clear income status toggle', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: BlocProvider<BudgetBloc>.value(
          value: mockBudgetBloc,
          child: Scaffold(
            body: TransactionEditDialog(income: income, categories: categories),
          ),
        ),
      ),
    );

    expect(find.text('Received / Guaranteed Income'), findsOneWidget);

    // Toggle to potential
    await tester.tap(find.byType(SwitchListTile));
    await tester.pumpAndSettle();

    expect(find.text('Pending / Expected Income'), findsOneWidget);
    expect(find.text('Mark as Received'), findsOneWidget);
  });

  testWidgets('TransactionEditDialog allows marking expense as paid via button', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: BlocProvider<BudgetBloc>.value(
          value: mockBudgetBloc,
          child: Scaffold(
            body: TransactionEditDialog(
              expense: potentialExpense,
              categories: categories,
            ),
          ),
        ),
      ),
    );

    expect(find.text('Unpaid / Pending Expense'), findsOneWidget);
    expect(find.text('Mark as Paid'), findsOneWidget);

    // Tap Mark as Paid button
    await tester.tap(find.text('Mark as Paid'));
    await tester.pumpAndSettle();

    expect(find.text('Paid / Settled Expense'), findsOneWidget);
    expect(find.text('Mark as Paid'), findsNothing);
  });

  testWidgets('TransactionEditDialog pre-fills and submits UpdateIncomeEvent', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: BlocProvider<BudgetBloc>.value(
          value: mockBudgetBloc,
          child: Scaffold(
            body: TransactionEditDialog(income: income, categories: categories),
          ),
        ),
      ),
    );

    expect(find.text('1000.0'), findsOneWidget);
    expect(find.text('Salary'), findsOneWidget);
    expect(find.text('Initial salary'), findsOneWidget);

    await tester.enterText(
      find.widgetWithText(TextFormField, 'Amount'),
      '1200.0',
    );
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    verify(() => mockBudgetBloc.add(any<UpdateIncomeEvent>())).called(1);
    expect(find.byType(TransactionEditDialog), findsNothing);
  });
}
