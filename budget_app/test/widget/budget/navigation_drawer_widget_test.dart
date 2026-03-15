import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mocktail/mocktail.dart';
import 'package:intl/intl.dart';
import 'package:budget_app/features/budget/domain/entities/budget_period.dart';
import 'package:budget_app/features/budget/presentation/bloc/navigation_bloc.dart';
import 'package:budget_app/features/budget/presentation/widgets/navigation_drawer_widget.dart';

class MockNavigationBloc extends Mock implements NavigationBloc {}

void main() {
  late MockNavigationBloc mockNavigationBloc;
  late BudgetPeriod currentPeriod;

  setUp(() {
    mockNavigationBloc = MockNavigationBloc();
    currentPeriod = BudgetPeriod(year: 2024, month: 1);
    
    when(() => mockNavigationBloc.state).thenReturn(
      NavigationState(
        currentPeriod: currentPeriod,
        availablePeriods: [
          currentPeriod,
          BudgetPeriod(year: 2024, month: 2),
        ],
      ),
    );
    when(() => mockNavigationBloc.stream).thenAnswer((_) => const Stream.empty());
  });

  Widget createWidgetUnderTest() {
    return MaterialApp(
      home: Scaffold(
        body: BlocProvider<NavigationBloc>.value(
          value: mockNavigationBloc,
          child: const NavigationDrawerWidget(),
        ),
      ),
    );
  }

  testWidgets('renders NavigationDrawerWidget properly', (WidgetTester tester) async {
    await tester.pumpWidget(createWidgetUnderTest());

    expect(find.text('Budget App'), findsOneWidget);
    
    // Default expanded year should show months
    final monthName = DateFormat('MMMM').format(currentPeriod.startDate);
    expect(find.text(monthName), findsOneWidget);
  });
}
