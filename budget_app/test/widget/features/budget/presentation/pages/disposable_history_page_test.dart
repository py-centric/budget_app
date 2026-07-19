import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mocktail/mocktail.dart';
import 'package:budget_app/features/budget/domain/entities/budget.dart';
import 'package:budget_app/features/budget/presentation/bloc/budget_bloc.dart';
import 'package:budget_app/features/budget/presentation/bloc/budget_event.dart';
import 'package:budget_app/features/budget/presentation/bloc/budget_state.dart';
import 'package:budget_app/features/budget/presentation/pages/disposable_history_page.dart';

class MockBudgetBloc extends Mock implements BudgetBloc {}

class FakeBudgetEvent extends Fake implements BudgetEvent {}

void main() {
  late MockBudgetBloc mockBudgetBloc;

  const disposedBudget = Budget(
    id: 'disp-1',
    name: 'Old Equipment Fund',
    periodMonth: 1,
    periodYear: 2024,
    type: BudgetType.disposed,
    targetIncome: 5000.0,
    sourceDescription: 'Freelance payment',
  );

  const persistedBudget = Budget(
    id: 'disp-2',
    name: 'Marketing Fund',
    periodMonth: 2,
    periodYear: 2024,
    type: BudgetType.persisted,
    targetIncome: 3000.0,
    sourceDescription: 'Quarterly budget',
  );

  setUpAll(() {
    registerFallbackValue(FakeBudgetEvent());
  });

  setUp(() {
    mockBudgetBloc = MockBudgetBloc();
    when(() => mockBudgetBloc.state).thenReturn(const BudgetInitial());
    when(() => mockBudgetBloc.stream).thenAnswer((_) => const Stream.empty());
  });

  Widget buildPage() {
    return MaterialApp(
      home: BlocProvider<BudgetBloc>.value(
        value: mockBudgetBloc,
        child: const DisposableHistoryPage(),
      ),
    );
  }

  group('DisposableHistoryPage', () {
    testWidgets('shows loading indicator when state is BudgetLoading', (tester) async {
      when(() => mockBudgetBloc.state).thenReturn(const BudgetLoading());

      await tester.pumpWidget(buildPage());

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('shows empty message when no history', (tester) async {
      when(() => mockBudgetBloc.state).thenReturn(const DisposableBudgetsLoaded(
        active: [],
        history: [],
      ));

      await tester.pumpWidget(buildPage());

      expect(find.text('No disposed or persisted budgets yet.'), findsOneWidget);
    });

    testWidgets('shows error message when state is BudgetError', (tester) async {
      when(() => mockBudgetBloc.state).thenReturn(const BudgetError('Test error'));

      await tester.pumpWidget(buildPage());

      expect(find.text('Test error'), findsOneWidget);
    });

    testWidgets('shows disposed budget with archive icon', (tester) async {
      when(() => mockBudgetBloc.state).thenReturn(const DisposableBudgetsLoaded(
        active: [],
        history: [disposedBudget],
      ));

      await tester.pumpWidget(buildPage());

      expect(find.text('Old Equipment Fund'), findsOneWidget);
      expect(find.text('Disposed'), findsOneWidget);
      expect(find.byIcon(Icons.archive), findsOneWidget);
      expect(find.textContaining('5000.00'), findsOneWidget);
      expect(find.text('Freelance payment'), findsOneWidget);
    });

    testWidgets('shows persisted budget with save icon', (tester) async {
      when(() => mockBudgetBloc.state).thenReturn(const DisposableBudgetsLoaded(
        active: [],
        history: [persistedBudget],
      ));

      await tester.pumpWidget(buildPage());

      expect(find.text('Marketing Fund'), findsOneWidget);
      expect(find.text('Persisted'), findsOneWidget);
      expect(find.byIcon(Icons.save), findsOneWidget);
    });

    testWidgets('shows multiple history items', (tester) async {
      when(() => mockBudgetBloc.state).thenReturn(const DisposableBudgetsLoaded(
        active: [],
        history: [disposedBudget, persistedBudget],
      ));

      await tester.pumpWidget(buildPage());

      expect(find.byType(ListTile), findsNWidgets(2));
    });

    testWidgets('shows month and year for budget period', (tester) async {
      when(() => mockBudgetBloc.state).thenReturn(const DisposableBudgetsLoaded(
        active: [],
        history: [disposedBudget],
      ));

      await tester.pumpWidget(buildPage());

      expect(find.text('January 2024'), findsOneWidget);
    });

    testWidgets('dispatches LoadDisposableHistoryEvent on init', (tester) async {
      when(() => mockBudgetBloc.state).thenReturn(const DisposableBudgetsLoaded(
        active: [],
        history: [],
      ));

      await tester.pumpWidget(buildPage());

      verify(() => mockBudgetBloc.add(const LoadDisposableHistoryEvent())).called(1);
    });

    testWidgets('shows pull to refresh support', (tester) async {
      when(() => mockBudgetBloc.state).thenReturn(const DisposableBudgetsLoaded(
        active: [],
        history: [disposedBudget],
      ));

      await tester.pumpWidget(buildPage());

      expect(find.byType(RefreshIndicator), findsOneWidget);
    });

    testWidgets('shows chevron right on each item', (tester) async {
      when(() => mockBudgetBloc.state).thenReturn(const DisposableBudgetsLoaded(
        active: [],
        history: [disposedBudget],
      ));

      await tester.pumpWidget(buildPage());

      expect(find.byIcon(Icons.chevron_right), findsOneWidget);
    });

    testWidgets('handles budget without targetIncome', (tester) async {
      const noTargetBudget = Budget(
        id: 'disp-3',
        name: 'No Target Fund',
        periodMonth: 3,
        periodYear: 2024,
        type: BudgetType.disposed,
      );

      when(() => mockBudgetBloc.state).thenReturn(const DisposableBudgetsLoaded(
        active: [],
        history: [noTargetBudget],
      ));

      await tester.pumpWidget(buildPage());

      expect(find.text('No Target Fund'), findsOneWidget);
    });

    testWidgets('handles budget without sourceDescription', (tester) async {
      const noSourceBudget = Budget(
        id: 'disp-4',
        name: 'No Source Fund',
        periodMonth: 4,
        periodYear: 2024,
        type: BudgetType.disposed,
        targetIncome: 1000.0,
      );

      when(() => mockBudgetBloc.state).thenReturn(const DisposableBudgetsLoaded(
        active: [],
        history: [noSourceBudget],
      ));

      await tester.pumpWidget(buildPage());

      expect(find.text('No Source Fund'), findsOneWidget);
      expect(find.textContaining('1000.00'), findsOneWidget);
    });
  });
}
