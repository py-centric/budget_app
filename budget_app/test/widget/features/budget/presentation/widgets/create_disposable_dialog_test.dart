import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mocktail/mocktail.dart';
import 'package:budget_app/features/budget/domain/entities/income_entry.dart';
import 'package:budget_app/features/budget/presentation/bloc/budget_bloc.dart';
import 'package:budget_app/features/budget/presentation/bloc/budget_event.dart';
import 'package:budget_app/features/budget/presentation/bloc/budget_state.dart';
import 'package:budget_app/features/budget/presentation/widgets/create_disposable_dialog.dart';

class MockBudgetBloc extends Mock implements BudgetBloc {}

class FakeCreateDisposableBudgetEvent extends Fake implements CreateDisposableBudgetEvent {}

void main() {
  late MockBudgetBloc mockBudgetBloc;

  final testIncomes = [
    IncomeEntry(
      id: 'inc-1',
      budgetId: 'budget-1',
      amount: 5000.0,
      categoryId: 'cat-1',
      description: 'Freelance',
      date: DateTime(2024, 1, 1),
    ),
    IncomeEntry(
      id: 'inc-2',
      budgetId: 'budget-1',
      amount: 2000.0,
      categoryId: 'cat-1',
      description: 'Side gig',
      date: DateTime(2024, 1, 15),
    ),
  ];

  setUpAll(() {
    registerFallbackValue(FakeCreateDisposableBudgetEvent());
  });

  setUp(() {
    mockBudgetBloc = MockBudgetBloc();
    when(() => mockBudgetBloc.state).thenReturn(const BudgetInitial());
    when(() => mockBudgetBloc.stream).thenAnswer((_) => const Stream.empty());
  });

  Widget buildDialog() {
    return BlocProvider<BudgetBloc>.value(
      value: mockBudgetBloc,
      child: MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (_) => const CreateDisposableDialog(),
                );
              },
              child: const Text('Open'),
            ),
          ),
        ),
      ),
    );
  }

  group('CreateDisposableDialog', () {
    testWidgets('shows dialog with form fields', (tester) async {
      await tester.pumpWidget(buildDialog());
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      expect(find.text('Create Disposable Budget'), findsOneWidget);
      expect(find.text('Budget Name'), findsOneWidget);
      expect(find.text('Target Income Amount'), findsOneWidget);
      expect(find.text('Source Description'), findsOneWidget);
      expect(find.text('Month'), findsOneWidget);
      expect(find.text('Year'), findsOneWidget);
      expect(find.text('Create'), findsOneWidget);
      expect(find.text('Cancel'), findsOneWidget);
    });

    testWidgets('shows checkbox for linking income', (tester) async {
      await tester.pumpWidget(buildDialog());
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      expect(find.text('Link to existing income'), findsOneWidget);
      expect(find.byType(CheckboxListTile), findsOneWidget);
    });

    testWidgets('default name is Disposable Budget', (tester) async {
      await tester.pumpWidget(buildDialog());
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      final nameField = tester.widget<TextFormField>(
        find.widgetWithText(TextFormField, 'Budget Name'),
      );
      expect(nameField.controller?.text, 'Disposable Budget');
    });

    testWidgets('shows validation when name is empty', (tester) async {
      await tester.pumpWidget(buildDialog());
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      await tester.enterText(
        find.widgetWithText(TextFormField, 'Budget Name'),
        '',
      );
      await tester.tap(find.text('Create'));
      await tester.pumpAndSettle();

      expect(find.text('Enter a budget name'), findsOneWidget);
    });

    testWidgets('shows validation when target income is empty', (tester) async {
      await tester.pumpWidget(buildDialog());
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      await tester.enterText(
        find.widgetWithText(TextFormField, 'Target Income Amount'),
        '',
      );
      await tester.tap(find.text('Create'));
      await tester.pumpAndSettle();

      expect(find.text('Enter target income'), findsOneWidget);
    });

    testWidgets('shows validation when target income is not positive', (tester) async {
      await tester.pumpWidget(buildDialog());
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      await tester.enterText(
        find.widgetWithText(TextFormField, 'Target Income Amount'),
        '-500',
      );
      await tester.tap(find.text('Create'));
      await tester.pumpAndSettle();

      expect(find.text('Must be a positive number'), findsOneWidget);
    });

    testWidgets('shows validation when source description is empty', (tester) async {
      await tester.pumpWidget(buildDialog());
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      await tester.enterText(
        find.widgetWithText(TextFormField, 'Source Description'),
        '',
      );
      await tester.tap(find.text('Create'));
      await tester.pumpAndSettle();

      expect(find.text('Enter a source description'), findsOneWidget);
    });

    testWidgets('dispatches CreateDisposableBudgetEvent on valid submit', (tester) async {
      await tester.pumpWidget(buildDialog());
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      clearInteractions(mockBudgetBloc);

      await tester.enterText(
        find.widgetWithText(TextFormField, 'Budget Name'),
        'Equipment Fund',
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Target Income Amount'),
        '5000',
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Source Description'),
        'Freelance payment',
      );

      await tester.tap(find.text('Create'));
      await tester.pumpAndSettle();

      verify(() => mockBudgetBloc.add(any<CreateDisposableBudgetEvent>())).called(1);
    });

    testWidgets('Cancel closes dialog without dispatching Create event', (tester) async {
      await tester.pumpWidget(buildDialog());
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      clearInteractions(mockBudgetBloc);

      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();

      verifyNever(() => mockBudgetBloc.add(any<CreateDisposableBudgetEvent>()));
    });

    testWidgets('month dropdown is present with correct items', (tester) async {
      await tester.pumpWidget(buildDialog());
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      expect(find.byType(DropdownButtonFormField<int>), findsOneWidget);

      await tester.tap(find.byType(DropdownButtonFormField<int>));
      await tester.pumpAndSettle();

      expect(find.text('January'), findsWidgets);
    });

    testWidgets('enabling income link shows dropdown when incomes loaded', (tester) async {
      final stateController = StreamController<BudgetState>.broadcast();
      stateController.add(const BudgetInitial());
      when(() => mockBudgetBloc.state).thenReturn(IncomeListLoaded(testIncomes));
      when(() => mockBudgetBloc.stream).thenAnswer((_) => stateController.stream);

      await tester.pumpWidget(buildDialog());
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      stateController.add(IncomeListLoaded(testIncomes));
      await tester.pumpAndSettle();

      await tester.tap(find.byType(CheckboxListTile));
      await tester.pumpAndSettle();

      expect(find.text('Select Income'), findsOneWidget);

      stateController.close();
    });

    testWidgets('enabling income link shows empty message when no incomes', (tester) async {
      final stateController = StreamController<BudgetState>.broadcast();
      stateController.add(const BudgetInitial());
      when(() => mockBudgetBloc.state).thenReturn(const IncomeListLoaded([]));
      when(() => mockBudgetBloc.stream).thenAnswer((_) => stateController.stream);

      await tester.pumpWidget(buildDialog());
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      stateController.add(const IncomeListLoaded([]));
      await tester.pumpAndSettle();

      await tester.tap(find.byType(CheckboxListTile));
      await tester.pumpAndSettle();

      expect(find.text('No income entries available to link.'), findsOneWidget);

      stateController.close();
    });

    testWidgets('enabling income link shows loading state', (tester) async {
      await tester.pumpWidget(buildDialog());
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      await tester.tap(find.byType(CheckboxListTile));
      await tester.pumpAndSettle();

      expect(find.text('Loading income entries...'), findsOneWidget);
    });
  });
}
