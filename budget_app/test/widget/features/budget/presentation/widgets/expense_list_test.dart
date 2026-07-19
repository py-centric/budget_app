import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mocktail/mocktail.dart';
import 'package:budget_app/features/budget/domain/entities/expense_entry.dart';
import 'package:budget_app/features/budget/presentation/widgets/expense_list.dart';
import 'package:budget_app/features/settings/presentation/bloc/settings_bloc.dart';

class MockSettingsBloc extends Mock implements SettingsBloc {}

void main() {
  late MockSettingsBloc mockSettingsBloc;

  final testExpenses = [
    ExpenseEntry(
      id: 'exp-1',
      budgetId: 'b1',
      amount: 50.0,
      categoryId: 'food',
      description: 'Lunch',
      date: DateTime(2024, 1, 15),
    ),
    ExpenseEntry(
      id: 'exp-2',
      budgetId: 'b1',
      amount: 100.0,
      categoryId: 'transport',
      description: 'Gas',
      date: DateTime(2024, 1, 20),
    ),
  ];

  setUp(() {
    mockSettingsBloc = MockSettingsBloc();
    when(() => mockSettingsBloc.state).thenReturn(const SettingsState());
    when(() => mockSettingsBloc.stream).thenAnswer((_) => const Stream.empty());
  });

  Widget buildExpenseList({
    required List<ExpenseEntry> entries,
    Function(ExpenseEntry)? onEdit,
    Function(ExpenseEntry)? onDelete,
    Function(ExpenseEntry)? onConfirm,
    Set<String>? disposableBudgetIds,
  }) {
    return MaterialApp(
      home: Scaffold(
        body: BlocProvider<SettingsBloc>.value(
          value: mockSettingsBloc,
          child: ExpenseList(
            entries: entries,
            onEdit: onEdit ?? (_) {},
            onDelete: onDelete ?? (_) {},
            onConfirm: onConfirm,
            disposableBudgetIds: disposableBudgetIds,
          ),
        ),
      ),
    );
  }

  group('ExpenseList', () {
    testWidgets('shows empty state when no entries', (tester) async {
      await tester.pumpWidget(buildExpenseList(entries: []));

      expect(find.textContaining('No expense entries'), findsOneWidget);
    });

    testWidgets('renders expense entries', (tester) async {
      await tester.pumpWidget(buildExpenseList(entries: testExpenses));

      expect(find.textContaining('Lunch'), findsOneWidget);
      expect(find.textContaining('Gas'), findsOneWidget);
    });

    testWidgets('renders with disposable budget badge', (tester) async {
      await tester.pumpWidget(buildExpenseList(
        entries: testExpenses,
        disposableBudgetIds: {'b1'},
      ));

      expect(find.byIcon(Icons.all_inbox), findsWidgets);
    });
  });
}
