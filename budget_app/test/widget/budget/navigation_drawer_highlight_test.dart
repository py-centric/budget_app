import 'package:budget_app/core/feature_flags/models/release_edition.dart';
import 'package:budget_app/core/feature_flags/presentation/bloc/feature_flags_bloc.dart';
import 'package:budget_app/features/budget/domain/entities/budget_period.dart';
import 'package:budget_app/features/budget/presentation/bloc/budget_bloc.dart';
import 'package:budget_app/features/budget/presentation/bloc/budget_state.dart';
import 'package:budget_app/features/budget/presentation/bloc/category_bloc.dart';
import 'package:budget_app/features/budget/presentation/bloc/navigation_bloc.dart';
import 'package:budget_app/features/budget/presentation/pages/category_settings_page.dart';
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

/// US5 (FR-013 stage 2): drawer rows must highlight the screen the user is on.
/// Regression for the live bug where the "Dashboard Overview" row stayed
/// highlighted on every page (hardcoded styling, no destination tracking).
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
        availablePeriods: [BudgetPeriod(year: 2024, month: 1)],
      ),
    );
    when(
      () => mockNavigationBloc.stream,
    ).thenAnswer((_) => const Stream<NavigationState>.empty());

    when(() => mockReminderBloc.state).thenReturn(
      const ReminderLoaded(reminders: [], unreadCount: 0),
    );
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

  Widget wrap(Widget child) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<NavigationBloc>.value(value: mockNavigationBloc),
        BlocProvider<BudgetBloc>.value(value: mockBudgetBloc),
        BlocProvider<ReminderBloc>.value(value: mockReminderBloc),
        BlocProvider<CategoryBloc>.value(value: mockCategoryBloc),
        BlocProvider<FeatureFlagsBloc>.value(
          value: FeatureFlagsBloc(initialDefaultEdition: ReleaseEdition.combined),
        ),
      ],
      child: child,
    );
  }

  void setSize(WidgetTester tester, Size size) {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });
  }

  bool rowSelected(WidgetTester tester, String title) {
    final Finder tileFinder = find.ancestor(
      of: find.text(title),
      matching: find.byType(ListTile),
    );
    return tester.widget<ListTile>(tileFinder).selected;
  }

  group('drawer row highlight (docked sidebar)', () {
    testWidgets('wallet-family page highlights Accounts, not Dashboard Overview',
        (tester) async {
      setSize(tester, const Size(900, 1200));
      await tester.pumpWidget(
        MaterialApp(
          home: wrap(
            AdaptiveWorkspaceShell(
              appBar: AppBar(title: const Text('Probe')),
              body: const SizedBox(),
              selectedIndex: 2,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(rowSelected(tester, 'Accounts'), isTrue,
          reason: 'the wallet-family row must follow the declared destination');
      expect(rowSelected(tester, 'Dashboard Overview'), isFalse,
          reason: 'Dashboard Overview must NOT be permanently highlighted');
    });

    testWidgets('overview page highlights Dashboard Overview', (tester) async {
      setSize(tester, const Size(900, 1200));
      await tester.pumpWidget(
        MaterialApp(
          home: wrap(
            AdaptiveWorkspaceShell(
              appBar: AppBar(title: const Text('Probe')),
              body: const SizedBox(),
              selectedIndex: 0,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(rowSelected(tester, 'Dashboard Overview'), isTrue);
      expect(rowSelected(tester, 'Accounts'), isFalse);
    });

    testWidgets(
        'exact drawer row wins over the family anchor (Manage Categories on its own page)',
        (tester) async {
      setSize(tester, const Size(900, 1200));
      await tester.pumpWidget(
        MaterialApp(
          home: wrap(const CategorySettingsPage()),
        ),
      );
      await tester.pumpAndSettle();

      expect(rowSelected(tester, 'Manage Categories'), isTrue,
          reason: 'the row of the hosted page must highlight exactly');
      expect(rowSelected(tester, 'App Settings'), isFalse,
          reason: 'the family anchor must not highlight when an exact row exists');
    });
  });

  group('compact bottom navbar tracking (regression guard)', () {
    testWidgets('navbar highlights the declared destination, not Overview',
        (tester) async {
      setSize(tester, const Size(400, 800));
      await tester.pumpWidget(
        MaterialApp(
          home: wrap(
            AdaptiveWorkspaceShell(
              appBar: AppBar(title: const Text('Probe')),
              body: const SizedBox(),
              selectedIndex: 2,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final NavigationBar bar = tester.widget<NavigationBar>(
        find.byType(NavigationBar),
      );
      expect(bar.selectedIndex, 2);
    });
  });
}
