import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mocktail/mocktail.dart';
import 'package:budget_app/features/budget/domain/entities/budget.dart';
import 'package:budget_app/features/budget/presentation/bloc/budget_bloc.dart';
import 'package:budget_app/features/budget/presentation/bloc/budget_event.dart';
import 'package:budget_app/features/budget/presentation/bloc/budget_state.dart';
import 'package:budget_app/features/budget/presentation/widgets/dispose_persist_sheet.dart';

class MockBudgetBloc extends Mock implements BudgetBloc {}

class FakeBudgetEvent extends Fake implements BudgetEvent {}

class FakeDisposeBudgetEvent extends Fake implements DisposeBudgetEvent {}
class FakePersistBudgetEvent extends Fake implements PersistBudgetEvent {}

void main() {
  late MockBudgetBloc mockBudgetBloc;

  const disposableBudget = Budget(
    id: 'disp-1',
    name: 'Equipment Fund',
    periodMonth: 1,
    periodYear: 2024,
    type: BudgetType.disposable,
    targetIncome: 5000.0,
    sourceDescription: 'Freelance payment',
  );

  setUpAll(() {
    registerFallbackValue(FakeDisposeBudgetEvent());
    registerFallbackValue(FakePersistBudgetEvent());
  });

  setUp(() {
    mockBudgetBloc = MockBudgetBloc();
    when(() => mockBudgetBloc.state).thenReturn(const BudgetInitial());
    when(() => mockBudgetBloc.stream).thenAnswer((_) => const Stream.empty());
  });

  Widget buildSheet(Budget budget, {double totalExpenses = 0}) {
    return MaterialApp(
      home: BlocProvider<BudgetBloc>.value(
        value: mockBudgetBloc,
        child: Scaffold(
          body: SingleChildScrollView(
            child: DisposePersistSheet(
              budget: budget,
              totalExpenses: totalExpenses,
            ),
          ),
        ),
      ),
    );
  }

  group('DisposePersistSheet', () {
    testWidgets('shows budget name and manage title', (tester) async {
      await tester.pumpWidget(buildSheet(disposableBudget));

      expect(find.text('Manage Budget'), findsOneWidget);
      expect(find.text('Equipment Fund'), findsOneWidget);
    });

    testWidgets('shows target income amount', (tester) async {
      await tester.pumpWidget(buildSheet(disposableBudget));

      expect(find.text('Target: \$5000.00'), findsOneWidget);
    });

    testWidgets('shows remaining balance when totalExpenses provided', (tester) async {
      await tester.pumpWidget(buildSheet(disposableBudget, totalExpenses: 1200));

      expect(find.text('Remaining: \$3800.00'), findsOneWidget);
    });

    testWidgets('shows remaining equal to target when no expenses', (tester) async {
      await tester.pumpWidget(buildSheet(disposableBudget));

      expect(find.text('Remaining: \$5000.00'), findsOneWidget);
    });

    testWidgets('shows warning banner when remaining > 0', (tester) async {
      await tester.pumpWidget(buildSheet(disposableBudget, totalExpenses: 2000));

      expect(find.textContaining('unspent funds'), findsOneWidget);
      expect(find.byIcon(Icons.warning_amber), findsOneWidget);
    });

    testWidgets('does not show warning banner when remaining is 0', (tester) async {
      await tester.pumpWidget(buildSheet(disposableBudget, totalExpenses: 5000));

      expect(find.textContaining('unspent funds'), findsNothing);
    });

    testWidgets('does not show warning banner when remaining is negative', (tester) async {
      await tester.pumpWidget(buildSheet(disposableBudget, totalExpenses: 6000));

      expect(find.textContaining('unspent funds'), findsNothing);
    });

    testWidgets('shows LinearProgressIndicator', (tester) async {
      await tester.pumpWidget(buildSheet(disposableBudget, totalExpenses: 2500));

      expect(find.byType(LinearProgressIndicator), findsOneWidget);
    });

    testWidgets('shows Dispose and Persist buttons', (tester) async {
      await tester.pumpWidget(buildSheet(disposableBudget));

      expect(find.text('Dispose'), findsOneWidget);
      expect(find.text('Persist'), findsOneWidget);
      expect(find.byIcon(Icons.archive), findsOneWidget);
      expect(find.byIcon(Icons.save), findsOneWidget);
    });

    testWidgets('tapping Dispose dispatches DisposeBudgetEvent', (tester) async {
      await tester.pumpWidget(buildSheet(disposableBudget, totalExpenses: 5000));

      await tester.tap(find.text('Dispose'));
      await tester.pumpAndSettle();

      verify(() => mockBudgetBloc.add(any<DisposeBudgetEvent>())).called(1);
    });

    testWidgets('tapping Persist dispatches PersistBudgetEvent', (tester) async {
      await tester.pumpWidget(buildSheet(disposableBudget, totalExpenses: 5000));

      await tester.tap(find.text('Persist'));
      await tester.pumpAndSettle();

      verify(() => mockBudgetBloc.add(any<PersistBudgetEvent>())).called(1);
    });

    testWidgets('handles budget with null targetIncome', (tester) async {
      const noTargetBudget = Budget(
        id: 'disp-2',
        name: 'No Target',
        periodMonth: 1,
        periodYear: 2024,
        type: BudgetType.disposable,
      );

      await tester.pumpWidget(buildSheet(noTargetBudget));

      expect(find.text('No Target'), findsOneWidget);
      expect(find.text('Target: \$0.00'), findsOneWidget);
      expect(find.text('Remaining: \$0.00'), findsOneWidget);
    });
  });
}
