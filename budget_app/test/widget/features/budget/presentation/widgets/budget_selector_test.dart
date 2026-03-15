import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mocktail/mocktail.dart';
import 'package:budget_app/features/budget/presentation/widgets/budget_selector.dart';
import 'package:budget_app/features/budget/domain/entities/budget.dart';
import 'package:budget_app/features/budget/presentation/bloc/navigation_bloc.dart';

class MockNavigationBloc extends Mock implements NavigationBloc {}

void main() {
  late MockNavigationBloc mockNavigationBloc;
  final budget1 = const Budget(id: '1', name: 'Main Budget', periodMonth: 1, periodYear: 2026);
  final budget2 = const Budget(id: '2', name: 'Alt Plan', periodMonth: 1, periodYear: 2026);

  setUp(() {
    mockNavigationBloc = MockNavigationBloc();
    when(() => mockNavigationBloc.stream).thenAnswer((_) => const Stream.empty());
  });

  testWidgets('BudgetSelector renders correctly and switches budgets', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: BlocProvider<NavigationBloc>.value(
            value: mockNavigationBloc,
            child: BudgetSelector(
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

    verify(() => mockNavigationBloc.add(ChangeBudget(budget2))).called(1);
  });

  testWidgets('BudgetSelector hides when only one budget exists', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: BlocProvider<NavigationBloc>.value(
            value: mockNavigationBloc,
            child: BudgetSelector(
              budgets: [budget1],
              activeBudget: budget1,
            ),
          ),
        ),
      ),
    );

    expect(find.text('Main Budget'), findsNothing);
  });
}
