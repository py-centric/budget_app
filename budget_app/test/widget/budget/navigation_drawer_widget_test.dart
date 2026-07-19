import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mocktail/mocktail.dart';
import 'package:budget_app/features/budget/domain/entities/budget.dart';
import 'package:budget_app/features/budget/domain/entities/budget_period.dart';
import 'package:budget_app/features/budget/presentation/bloc/navigation_bloc.dart';
import 'package:budget_app/features/budget/presentation/bloc/budget_bloc.dart';
import 'package:budget_app/features/budget/presentation/bloc/budget_event.dart';
import 'package:budget_app/features/budget/presentation/bloc/budget_state.dart';
import 'package:budget_app/features/budget/presentation/widgets/navigation_drawer_widget.dart';
import 'package:budget_app/features/reminders/presentation/bloc/reminder_bloc.dart';
import 'package:budget_app/features/reminders/presentation/bloc/reminder_state.dart';

class MockNavigationBloc extends Mock implements NavigationBloc {}
class MockReminderBloc extends Mock implements ReminderBloc {}
class MockBudgetBloc extends Mock implements BudgetBloc {}
class FakeBudgetEvent extends Fake implements BudgetEvent {}

void main() {
  late MockNavigationBloc mockNavigationBloc;
  late MockReminderBloc mockReminderBloc;
  late MockBudgetBloc mockBudgetBloc;
  late BudgetPeriod currentPeriod;

  const disposableBudget = Budget(
    id: 'disp-1',
    name: 'Equipment Fund',
    periodMonth: 1,
    periodYear: 2024,
    type: BudgetType.disposable,
    targetIncome: 5000.0,
    sourceDescription: 'Freelance',
  );

  setUpAll(() {
    registerFallbackValue(FakeBudgetEvent());
  });

  setUp(() {
    mockNavigationBloc = MockNavigationBloc();
    mockReminderBloc = MockReminderBloc();
    mockBudgetBloc = MockBudgetBloc();
    currentPeriod = const BudgetPeriod(year: 2024, month: 1);

    when(() => mockNavigationBloc.state).thenReturn(
      NavigationState(
        currentPeriod: currentPeriod,
        availablePeriods: [
          currentPeriod,
          const BudgetPeriod(year: 2024, month: 2),
        ],
      ),
    );
    when(
      () => mockNavigationBloc.stream,
    ).thenAnswer((_) => const Stream.empty());

    when(() => mockReminderBloc.state).thenReturn(
      const ReminderLoaded(reminders: [], unreadCount: 0),
    );
    when(() => mockReminderBloc.stream).thenAnswer((_) => const Stream.empty());
  });

  void stubBudgetBloc(BudgetState state) {
    when(() => mockBudgetBloc.state).thenReturn(state);
    when(() => mockBudgetBloc.stream).thenAnswer((_) => const Stream.empty());
  }

  void setLargeViewport(WidgetTester tester) {
    tester.view.physicalSize = const Size(800, 1200);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() => tester.view.resetPhysicalSize());
    addTearDown(() => tester.view.resetDevicePixelRatio());
  }

  Widget buildApp({GlobalKey<ScaffoldState>? scaffoldKey}) {
    final key = scaffoldKey ?? GlobalKey<ScaffoldState>();
    return MaterialApp(
      home: MultiBlocProvider(
        providers: [
          BlocProvider<NavigationBloc>.value(value: mockNavigationBloc),
          BlocProvider<BudgetBloc>.value(value: mockBudgetBloc),
          BlocProvider<ReminderBloc>.value(value: mockReminderBloc),
        ],
        child: Scaffold(
          key: key,
          drawer: const NavigationDrawerWidget(),
          body: const Center(child: Text('Test')),
        ),
      ),
    );
  }

  group('NavigationDrawerWidget', () {
    testWidgets('renders NavigationDrawerWidget properly', (tester) async {
      stubBudgetBloc(const BudgetInitial());
      setLargeViewport(tester);
      final scaffoldKey = GlobalKey<ScaffoldState>();

      await tester.pumpWidget(buildApp(scaffoldKey: scaffoldKey));
      await tester.pumpAndSettle();

      scaffoldKey.currentState!.openDrawer();
      await tester.pumpAndSettle();

      expect(find.text('Budget App'), findsOneWidget);
      expect(find.text('Manage Categories'), findsOneWidget);
      expect(find.text('Projections'), findsOneWidget);
    });

    testWidgets('shows Create Disposable Budget button', (tester) async {
      stubBudgetBloc(const BudgetInitial());
      setLargeViewport(tester);
      final scaffoldKey = GlobalKey<ScaffoldState>();

      await tester.pumpWidget(buildApp(scaffoldKey: scaffoldKey));
      await tester.pumpAndSettle();

      scaffoldKey.currentState!.openDrawer();
      await tester.pumpAndSettle();

      expect(find.text('Create Disposable Budget'), findsOneWidget);
    });

    testWidgets('shows View History link when DisposableBudgetsLoaded', (tester) async {
      stubBudgetBloc(const DisposableBudgetsLoaded(active: [], history: []));
      setLargeViewport(tester);
      final scaffoldKey = GlobalKey<ScaffoldState>();

      await tester.pumpWidget(buildApp(scaffoldKey: scaffoldKey));
      await tester.pumpAndSettle();

      scaffoldKey.currentState!.openDrawer();
      await tester.pumpAndSettle();

      expect(find.text('View Disposable History'), findsOneWidget);
    });

    testWidgets('shows active disposable budgets with remaining balance', (tester) async {
      stubBudgetBloc(DisposableBudgetsLoaded(
        active: [disposableBudget],
        history: [],
        budgetExpenseTotals: {'disp-1': 1200.0},
      ));
      setLargeViewport(tester);
      final scaffoldKey = GlobalKey<ScaffoldState>();

      await tester.pumpWidget(buildApp(scaffoldKey: scaffoldKey));
      await tester.pumpAndSettle();

      scaffoldKey.currentState!.openDrawer();
      await tester.pumpAndSettle();

      expect(find.text('Equipment Fund'), findsOneWidget);
      expect(find.text('Disposable Budgets'), findsOneWidget);
      expect(find.textContaining('3800.00'), findsOneWidget);
    });

    testWidgets('shows ended label for past-period disposable budgets', (tester) async {
      const endedBudget = Budget(
        id: 'ended-1',
        name: 'Ended Fund',
        periodMonth: 1,
        periodYear: 2023,
        type: BudgetType.disposable,
        targetIncome: 1000.0,
      );

      stubBudgetBloc(DisposableBudgetsLoaded(
        active: [endedBudget],
        history: [],
        endedBudgetIds: {'ended-1'},
      ));
      setLargeViewport(tester);
      final scaffoldKey = GlobalKey<ScaffoldState>();

      await tester.pumpWidget(buildApp(scaffoldKey: scaffoldKey));
      await tester.pumpAndSettle();

      scaffoldKey.currentState!.openDrawer();
      await tester.pumpAndSettle();

      expect(find.text('(ended)'), findsOneWidget);
      expect(find.byIcon(Icons.warning_amber), findsOneWidget);
    });

    testWidgets('shows View History link even with active budgets', (tester) async {
      stubBudgetBloc(DisposableBudgetsLoaded(
        active: [disposableBudget],
        history: [],
        budgetExpenseTotals: {'disp-1': 0.0},
      ));
      setLargeViewport(tester);
      final scaffoldKey = GlobalKey<ScaffoldState>();

      await tester.pumpWidget(buildApp(scaffoldKey: scaffoldKey));
      await tester.pumpAndSettle();

      scaffoldKey.currentState!.openDrawer();
      await tester.pumpAndSettle();

      expect(find.text('View History'), findsOneWidget);
    });

    testWidgets('shows popup menu with Dispose and Persist options', (tester) async {
      stubBudgetBloc(DisposableBudgetsLoaded(
        active: [disposableBudget],
        history: [],
        budgetExpenseTotals: {'disp-1': 0.0},
      ));
      setLargeViewport(tester);
      final scaffoldKey = GlobalKey<ScaffoldState>();

      await tester.pumpWidget(buildApp(scaffoldKey: scaffoldKey));
      await tester.pumpAndSettle();

      scaffoldKey.currentState!.openDrawer();
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.more_vert));
      await tester.pumpAndSettle();

      expect(find.text('Dispose'), findsOneWidget);
      expect(find.text('Persist'), findsOneWidget);
    });
  });
}
