import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:mocktail/mocktail.dart';
import 'package:budget_app/features/budget/domain/entities/budget_period.dart';
import 'package:budget_app/features/budget/presentation/bloc/navigation_bloc.dart';
import 'package:budget_app/features/budget/presentation/bloc/budget_bloc.dart';
import 'package:budget_app/features/budget/presentation/bloc/budget_state.dart';
import 'package:budget_app/features/reminders/presentation/bloc/reminder_bloc.dart';
import 'package:budget_app/features/reminders/presentation/bloc/reminder_state.dart';
import 'package:budget_app/core/feature_flags/models/release_edition.dart';
import 'package:budget_app/core/feature_flags/presentation/bloc/feature_flags_bloc.dart';
import 'package:budget_app/shared/widgets/adaptive_workspace_shell.dart';

class MockNavigationBloc extends Mock implements NavigationBloc {}

class MockReminderBloc extends Mock implements ReminderBloc {}

class MockBudgetBloc extends Mock implements BudgetBloc {}

class MockStorage extends Mock implements Storage {}

void main() {
  late MockNavigationBloc mockNavigationBloc;
  late MockReminderBloc mockReminderBloc;
  late MockBudgetBloc mockBudgetBloc;

  setUpAll(() {
    final storage = MockStorage();
    when(() => storage.write(any(), any())).thenAnswer((_) async {});
    HydratedBloc.storage = storage;
  });

  setUp(() {
    mockNavigationBloc = MockNavigationBloc();
    mockReminderBloc = MockReminderBloc();
    mockBudgetBloc = MockBudgetBloc();

    when(() => mockNavigationBloc.state).thenReturn(
      const NavigationState(
        currentPeriod: BudgetPeriod(year: 2024, month: 1),
        availablePeriods: [BudgetPeriod(year: 2024, month: 1)],
      ),
    );
    when(
      () => mockNavigationBloc.stream,
    ).thenAnswer((_) => const Stream.empty());

    when(
      () => mockReminderBloc.state,
    ).thenReturn(const ReminderLoaded(reminders: [], unreadCount: 0));
    when(() => mockReminderBloc.stream).thenAnswer((_) => const Stream.empty());

    when(() => mockBudgetBloc.state).thenReturn(const BudgetInitial());
    when(() => mockBudgetBloc.stream).thenAnswer((_) => const Stream.empty());
  });

  Future<void> pumpDockedShell(WidgetTester tester) async {
    tester.view.physicalSize = const Size(900, 1200);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() => tester.view.resetPhysicalSize());
    addTearDown(() => tester.view.resetDevicePixelRatio());

    final featureFlagsBloc = FeatureFlagsBloc(
      initialDefaultEdition: ReleaseEdition.combined,
    );

    await tester.pumpWidget(
      MaterialApp(
        home: MultiBlocProvider(
          providers: [
            BlocProvider<NavigationBloc>.value(value: mockNavigationBloc),
            BlocProvider<BudgetBloc>.value(value: mockBudgetBloc),
            BlocProvider<ReminderBloc>.value(value: mockReminderBloc),
            BlocProvider<FeatureFlagsBloc>.value(value: featureFlagsBloc),
          ],
          child: AdaptiveWorkspaceShell(
            appBar: AppBar(title: const Text('Test Page')),
            body: const Center(child: Text('Body')),
            isHomePage: true,
            selectedIndex: 0,
          ),
        ),
      ),
    );
  }

  testWidgets(
    'docked sidebar collapse and expand cycle never overflows '
    '(mid-animation frames included)',
    (tester) async {
      AdaptiveWorkspaceShell.isSidebarCollapsed.value = false;
      addTearDown(() => AdaptiveWorkspaceShell.isSidebarCollapsed.value = false);

      await pumpDockedShell(tester);
      await tester.pumpAndSettle();

      expect(
        find.byKey(const ValueKey('docked_collapsible_sidebar')),
        findsOneWidget,
      );

      // Collapse: sample multiple mid-animation frames for overflow errors.
      await tester.tap(
        find.byKey(const ValueKey('appbar_sidebar_toggle')),
        warnIfMissed: false,
      );
      await tester.pump(const Duration(milliseconds: 40));
      expect(tester.takeException(), isNull);
      await tester.pump(const Duration(milliseconds: 60));
      expect(tester.takeException(), isNull);
      await tester.pump(const Duration(milliseconds: 60));
      expect(tester.takeException(), isNull);

      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      expect(
        find.byKey(const ValueKey('sidebar_expand_button')),
        findsOneWidget,
      );

      // Expand back: sample mid-animation frames again.
      await tester.tap(
        find.byKey(const ValueKey('sidebar_expand_button')),
      );
      await tester.pump(const Duration(milliseconds: 40));
      expect(tester.takeException(), isNull);
      await tester.pump(const Duration(milliseconds: 60));
      expect(tester.takeException(), isNull);
      await tester.pump(const Duration(milliseconds: 60));
      expect(tester.takeException(), isNull);

      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      expect(find.text('Budget App'), findsOneWidget);
    },
  );
}
