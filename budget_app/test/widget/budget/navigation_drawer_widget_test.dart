import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mocktail/mocktail.dart';
import 'package:budget_app/features/budget/domain/entities/budget_period.dart';
import 'package:budget_app/features/budget/presentation/bloc/navigation_bloc.dart';
import 'package:budget_app/features/budget/presentation/widgets/navigation_drawer_widget.dart';
import 'package:budget_app/features/reminders/presentation/bloc/reminder_bloc.dart';
import 'package:budget_app/features/reminders/presentation/bloc/reminder_state.dart';

class MockNavigationBloc extends Mock implements NavigationBloc {}

class MockReminderBloc extends Mock implements ReminderBloc {}

void main() {
  late MockNavigationBloc mockNavigationBloc;
  late MockReminderBloc mockReminderBloc;
  late BudgetPeriod currentPeriod;

  setUp(() {
    mockNavigationBloc = MockNavigationBloc();
    mockReminderBloc = MockReminderBloc();
    currentPeriod = BudgetPeriod(year: 2024, month: 1);

    when(() => mockNavigationBloc.state).thenReturn(
      NavigationState(
        currentPeriod: currentPeriod,
        availablePeriods: [currentPeriod, BudgetPeriod(year: 2024, month: 2)],
      ),
    );
    when(
      () => mockNavigationBloc.stream,
    ).thenAnswer((_) => const Stream.empty());

    when(
      () => mockReminderBloc.state,
    ).thenReturn(const ReminderLoaded(reminders: [], unreadCount: 0));
    when(() => mockReminderBloc.stream).thenAnswer((_) => const Stream.empty());
  });

  testWidgets('renders NavigationDrawerWidget properly', (
    WidgetTester tester,
  ) async {
    final scaffoldKey = GlobalKey<ScaffoldState>();

    await tester.pumpWidget(
      MaterialApp(
        home: MultiBlocProvider(
          providers: [
            BlocProvider<NavigationBloc>.value(value: mockNavigationBloc),
            BlocProvider<ReminderBloc>.value(value: mockReminderBloc),
          ],
          child: Scaffold(
            key: scaffoldKey,
            drawer: const NavigationDrawerWidget(),
            body: const Center(child: Text('Test')),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    scaffoldKey.currentState!.openDrawer();
    await tester.pumpAndSettle();

    expect(find.text('Budget App'), findsOneWidget);
    expect(find.text('Manage Categories'), findsOneWidget);
    expect(find.text('Projections'), findsOneWidget);
  });
}
