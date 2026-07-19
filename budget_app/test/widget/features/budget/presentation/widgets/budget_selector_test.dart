import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mocktail/mocktail.dart';
import 'package:budget_app/features/budget/presentation/widgets/budget_selector.dart';
import 'package:budget_app/features/budget/domain/entities/budget.dart';
import 'package:budget_app/features/budget/domain/entities/budget_period.dart';
import 'package:budget_app/features/budget/presentation/bloc/navigation_bloc.dart';

class MockNavigationBloc extends Mock implements NavigationBloc {}

void main() {
  late MockNavigationBloc mockNavigationBloc;
  const budget1 = Budget(
    id: '1',
    name: 'Main Budget',
    periodMonth: 1,
    periodYear: 2026,
  );
  const budget2 = Budget(
    id: '2',
    name: 'Alt Plan',
    periodMonth: 1,
    periodYear: 2026,
  );

  setUp(() {
    mockNavigationBloc = MockNavigationBloc();
    when(
      () => mockNavigationBloc.stream,
    ).thenAnswer((_) => const Stream.empty());
  });

  testWidgets('BudgetSelector renders correctly and switches budgets', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: BlocProvider<NavigationBloc>.value(
            value: mockNavigationBloc,
            child: const BudgetSelector(
              budgets: [budget1, budget2],
              activeBudget: budget1,
            ),
          ),
        ),
      ),
    );

    // Initial state
    expect(find.text('Main Budget'), findsOneWidget);

    // Open dropdown
    await tester.tap(find.text('Main Budget'));
    await tester.pumpAndSettle();

    // Verify options
    expect(find.text('Alt Plan'), findsOneWidget);

    // Select second budget
    await tester.tap(find.text('Alt Plan').last);
    await tester.pumpAndSettle();

    verify(() => mockNavigationBloc.add(const ChangeBudget(budget2))).called(1);
  });

  testWidgets('BudgetSelector hides when only one budget exists', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: BlocProvider<NavigationBloc>.value(
            value: mockNavigationBloc,
            child: const BudgetSelector(
              budgets: [budget1],
              activeBudget: budget1,
            ),
          ),
        ),
      ),
    );

    expect(find.text('Main Budget'), findsNothing);
  });

  testWidgets('BudgetSelector shows disposable icon for disposable budgets', (
    WidgetTester tester,
  ) async {
    const disposableBudget = Budget(
      id: '3',
      name: 'Equipment Fund',
      periodMonth: 1,
      periodYear: 2026,
      type: BudgetType.disposable,
      targetIncome: 5000.0,
      sourceDescription: 'Freelance',
    );

    when(() => mockNavigationBloc.state).thenReturn(
      NavigationState(
        currentPeriod: const BudgetPeriod(year: 2026, month: 1),
      ),
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: BlocProvider<NavigationBloc>.value(
            value: mockNavigationBloc,
            child: const BudgetSelector(
              budgets: [budget1, disposableBudget],
              activeBudget: budget1,
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Main Budget'));
    await tester.pumpAndSettle();

    expect(find.byIcon(Icons.all_inbox), findsOneWidget);
  });

  testWidgets('BudgetSelector does not show disposable icon for regular budgets', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: BlocProvider<NavigationBloc>.value(
            value: mockNavigationBloc,
            child: const BudgetSelector(
              budgets: [budget1, budget2],
              activeBudget: budget1,
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Main Budget'));
    await tester.pumpAndSettle();

    expect(find.byIcon(Icons.all_inbox), findsNothing);
  });
}
