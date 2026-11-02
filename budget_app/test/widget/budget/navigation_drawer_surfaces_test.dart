import 'package:budget_app/core/feature_flags/models/release_edition.dart';
import 'package:budget_app/core/feature_flags/presentation/bloc/feature_flags_bloc.dart';
import 'package:budget_app/features/budget/domain/entities/budget_period.dart';
import 'package:budget_app/features/budget/presentation/bloc/budget_bloc.dart';
import 'package:budget_app/features/budget/presentation/bloc/budget_state.dart';
import 'package:budget_app/features/budget/presentation/bloc/category_bloc.dart';
import 'package:budget_app/features/budget/presentation/bloc/navigation_bloc.dart';
import 'package:budget_app/features/budget/presentation/widgets/create_budget_dialog.dart';
import 'package:budget_app/features/budget/presentation/widgets/create_disposable_dialog.dart';
import 'package:budget_app/features/reminders/presentation/bloc/reminder_bloc.dart';
import 'package:budget_app/features/reminders/presentation/bloc/reminder_state.dart';
import 'package:budget_app/shared/widgets/adaptive_workspace_shell.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:mocktail/mocktail.dart';

class MockNavigationBloc extends Mock implements NavigationBloc {}

class MockReminderBloc extends Mock implements ReminderBloc {}

class MockBudgetBloc extends Mock implements BudgetBloc {}

class MockCategoryBloc extends Mock implements CategoryBloc {}

class MockStorage extends Mock implements Storage {}

/// Drawer behavior coverage (US5 surfaces): reminder badge, no-bloc fallback,
/// navigation handlers, create-budget dialogs and the period/year section.
void main() {
  late MockNavigationBloc mockNavigationBloc;
  late MockReminderBloc mockReminderBloc;
  late MockBudgetBloc mockBudgetBloc;
  late MockCategoryBloc mockCategoryBloc;

  setUpAll(() {
    final storage = MockStorage();
    when(() => storage.write(any(), any())).thenAnswer((_) async {});
    HydratedBloc.storage = storage;
  });

  setUp(() {
    mockNavigationBloc = MockNavigationBloc();
    mockReminderBloc = MockReminderBloc();
    mockBudgetBloc = MockBudgetBloc();
    mockCategoryBloc = MockCategoryBloc();

    when(() => mockNavigationBloc.state).thenReturn(
      const NavigationState(
        currentPeriod: BudgetPeriod(year: 2024, month: 1),
        availablePeriods: [
          BudgetPeriod(year: 2023, month: 12),
          BudgetPeriod(year: 2024, month: 1),
        ],
      ),
    );
    when(
      () => mockNavigationBloc.stream,
    ).thenAnswer((_) => const Stream<NavigationState>.empty());

    when(
      () => mockReminderBloc.stream,
    ).thenAnswer((_) => const Stream<ReminderState>.empty());

    when(() => mockBudgetBloc.state).thenReturn(const BudgetInitial());
    when(
      () => mockBudgetBloc.stream,
    ).thenAnswer((_) => const Stream<BudgetState>.empty());

    when(() => mockCategoryBloc.state).thenReturn(CategoryInitial());
    when(
      () => mockCategoryBloc.stream,
    ).thenAnswer((_) => const Stream<CategoryState>.empty());
  });

  Widget wrap(Widget child, {bool withReminderBloc = true}) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<NavigationBloc>.value(value: mockNavigationBloc),
        BlocProvider<BudgetBloc>.value(value: mockBudgetBloc),
        if (withReminderBloc) BlocProvider<ReminderBloc>.value(value: mockReminderBloc),
        BlocProvider<CategoryBloc>.value(value: mockCategoryBloc),
        BlocProvider<FeatureFlagsBloc>.value(
          value: FeatureFlagsBloc(initialDefaultEdition: ReleaseEdition.combined),
        ),
      ],
      child: child,
    );
  }

  void setDockedSize(WidgetTester tester) {
    tester.view.physicalSize = const Size(900, 1200);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });
  }

  Future<void> pumpDockedShell(WidgetTester tester) async {
    setDockedSize(tester);
    await tester.pumpWidget(
      wrap(
        MaterialApp(
          home: AdaptiveWorkspaceShell(
            appBar: AppBar(title: const Text('Probe')),
            body: const SizedBox(),
            selectedIndex: 0,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('reminder tile shows the unread badge', (tester) async {
    when(() => mockReminderBloc.state)
        .thenReturn(const ReminderLoaded(reminders: [], unreadCount: 5));

    await pumpDockedShell(tester);

    expect(find.text('5'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('reminder badge clamps double digits to 9+', (tester) async {
    when(() => mockReminderBloc.state)
        .thenReturn(const ReminderLoaded(reminders: [], unreadCount: 12));

    await pumpDockedShell(tester);

    expect(find.text('9+'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('reminder tile falls back without a ReminderBloc', (tester) async {
    when(() => mockReminderBloc.state)
        .thenReturn(const ReminderLoaded(reminders: [], unreadCount: 0));

    setDockedSize(tester);
    await tester.pumpWidget(
      wrap(
        MaterialApp(
          home: AdaptiveWorkspaceShell(
            appBar: AppBar(title: const Text('Probe')),
            body: const SizedBox(),
            selectedIndex: 0,
          ),
        ),
        withReminderBloc: false,
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Bill Reminders'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('tapping a nav row pushes its page', (tester) async {
    when(() => mockReminderBloc.state)
        .thenReturn(const ReminderLoaded(reminders: [], unreadCount: 0));

    await pumpDockedShell(tester);

    await tester.tap(find.text('Manage Categories'));
    await tester.pumpAndSettle();

    expect(find.byType(Scaffold), findsWidgets);
    expect(find.text('Manage Categories'), findsWidgets);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Dashboard Overview pops back to the first route', (tester) async {
    when(() => mockReminderBloc.state)
        .thenReturn(const ReminderLoaded(reminders: [], unreadCount: 0));

    setDockedSize(tester);
    await tester.pumpWidget(
      wrap(
        MaterialApp(
          home: Builder(
            builder: (BuildContext context) => Center(
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => AdaptiveWorkspaceShell(
                        appBar: AppBar(title: const Text('Pushed')),
                        body: const SizedBox(),
                        selectedIndex: 0,
                      ),
                    ),
                  );
                },
                child: const Text('Open pushed shell'),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Open pushed shell'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Dashboard Overview'));
    await tester.pumpAndSettle();

    expect(find.text('Open pushed shell'), findsOneWidget,
        reason: 'the pushed shell must pop back to the first route');
    expect(tester.takeException(), isNull);
  });

  testWidgets('create budget rows open their dialogs', (tester) async {
    when(() => mockReminderBloc.state)
        .thenReturn(const ReminderLoaded(reminders: [], unreadCount: 0));

    await pumpDockedShell(tester);

    await tester.tap(find.text('Create Budget'));
    await tester.pumpAndSettle();
    expect(find.byType(CreateBudgetDialog), findsOneWidget);
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Create Disposable Budget'));
    await tester.pumpAndSettle();
    expect(find.byType(CreateDisposableDialog), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('year section renders periods and toggles expansion',
      (tester) async {
    when(() => mockReminderBloc.state)
        .thenReturn(const ReminderLoaded(reminders: [], unreadCount: 0));

    await pumpDockedShell(tester);

    expect(find.byKey(const ValueKey('period_2024_1')), findsOneWidget);
    expect(find.byKey(const ValueKey('period_2023_12')), findsNothing,
        reason: 'the second year starts collapsed');

    // The year section sits below the drawer fold: scroll it into view first.
    await tester.drag(find.byType(ListView).first, const Offset(0, -800));
    await tester.pumpAndSettle();
    await tester.tap(find.text('2023'));
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('period_2023_12')), findsOneWidget);

    await tester.tap(find.text('2024'));
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('period_2024_1')), findsNothing);
    expect(tester.takeException(), isNull);
  });
}
