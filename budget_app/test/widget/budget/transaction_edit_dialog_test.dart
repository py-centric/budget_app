import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mocktail/mocktail.dart';
import 'package:budget_app/features/budget/presentation/widgets/transaction_edit_dialog.dart';
import 'package:budget_app/features/budget/domain/entities/income_entry.dart';
import 'package:budget_app/features/budget/domain/entities/category.dart';
import 'package:budget_app/features/budget/presentation/budget_bloc.dart';
import 'package:budget_app/features/budget/presentation/budget_event.dart';
import 'package:budget_app/features/budget/presentation/budget_state.dart';

class MockBudgetBloc extends Mock implements BudgetBloc {}

class UpdateIncomeEventFake extends Fake implements UpdateIncomeEvent {}

void main() {
  setUpAll(() {
    registerFallbackValue(UpdateIncomeEventFake());
  });

  late MockBudgetBloc mockBudgetBloc;
  final categories = [
    const Category(
      id: '1',
      name: 'Salary',
      type: CategoryType.income,
      icon: 'attach_money',
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

  setUp(() {
    mockBudgetBloc = MockBudgetBloc();
    when(() => mockBudgetBloc.state).thenReturn(const BudgetInitial());
    when(() => mockBudgetBloc.stream).thenAnswer((_) => const Stream.empty());
  });

  testWidgets('TransactionEditDialog shows potential/guaranteed toggle', (
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

    expect(find.text('Guaranteed'), findsOneWidget);

    // Toggle to potential
    await tester.tap(find.byType(SwitchListTile));
    await tester.pumpAndSettle();

    expect(find.text('Potential (Not Guaranteed)'), findsOneWidget);
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
