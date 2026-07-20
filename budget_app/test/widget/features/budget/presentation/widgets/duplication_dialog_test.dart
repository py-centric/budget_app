import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mocktail/mocktail.dart';
import 'package:budget_app/features/budget/presentation/widgets/duplication_dialog.dart';
import 'package:budget_app/features/budget/domain/entities/budget.dart';
import 'package:budget_app/features/budget/presentation/bloc/budget_bloc.dart';
import 'package:budget_app/features/budget/presentation/bloc/budget_event.dart';
import 'package:budget_app/features/budget/presentation/bloc/budget_state.dart';

class MockBudgetBloc extends Mock implements BudgetBloc {}
class FakeBudgetEvent extends Fake implements BudgetEvent {}
class FakeDuplicateBudgetEvent extends Fake implements DuplicateBudgetEvent {}

void main() {
  late MockBudgetBloc mockBudgetBloc;

  final sourceBudget = Budget(
    id: 'b-1', name: 'June Budget', periodMonth: 6, periodYear: 2024,
    currencyCode: 'USD',
  );

  setUpAll(() {
    registerFallbackValue(FakeBudgetEvent());
    registerFallbackValue(FakeDuplicateBudgetEvent());
  });

  setUp(() {
    mockBudgetBloc = MockBudgetBloc();
    when(() => mockBudgetBloc.state).thenReturn(const BudgetInitial());
    when(() => mockBudgetBloc.stream).thenAnswer((_) => const Stream.empty());
  });

  Widget buildDialog({Budget? budget}) {
    return MaterialApp(
      home: Scaffold(
        body: BlocProvider<BudgetBloc>.value(
          value: mockBudgetBloc,
          child: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () => showDialog(
                context: context,
                builder: (_) => BlocProvider<BudgetBloc>.value(
                  value: mockBudgetBloc,
                  child: DuplicationDialog(
                    sourceBudget: budget ?? sourceBudget,
                  ),
                ),
              ),
              child: const Text('Open'),
            ),
          ),
        ),
      ),
    );
  }

  group('DuplicationDialog', () {
    testWidgets('shows title "Duplicate Budget"', (tester) async {
      await tester.pumpWidget(buildDialog());
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();
      expect(find.text('Duplicate Budget'), findsOneWidget);
    });

    testWidgets('pre-fills name with source budget name + Copy', (tester) async {
      await tester.pumpWidget(buildDialog());
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();
      expect(find.text('June Budget - Copy'), findsOneWidget);
    });

    testWidgets('shows currency dropdown', (tester) async {
      await tester.pumpWidget(buildDialog());
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();
      expect(find.byType(DropdownButtonFormField<String>), findsOneWidget);
    });

    testWidgets('shows month and year dropdowns', (tester) async {
      await tester.pumpWidget(buildDialog());
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();
      expect(find.text('Month 7'), findsOneWidget); // next month
    });

    testWidgets('shows Include Transactions switch', (tester) async {
      await tester.pumpWidget(buildDialog());
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();
      expect(find.text('Include Transactions'), findsOneWidget);
      expect(find.byType(SwitchListTile), findsOneWidget);
    });

    testWidgets('switch starts as true', (tester) async {
      await tester.pumpWidget(buildDialog());
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();
      final switchWidget = tester.widget<SwitchListTile>(find.byType(SwitchListTile));
      expect(switchWidget.value, isTrue);
    });

    testWidgets('Cancel closes dialog', (tester) async {
      await tester.pumpWidget(buildDialog());
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(TextButton, 'Cancel'));
      await tester.pumpAndSettle();
      expect(find.byType(AlertDialog), findsNothing);
    });

    testWidgets('Duplicate dispatches DuplicateBudgetEvent', (tester) async {
      await tester.pumpWidget(buildDialog());
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();
      clearInteractions(mockBudgetBloc);
      await tester.tap(find.widgetWithText(ElevatedButton, 'Duplicate'));
      await tester.pumpAndSettle();
      verify(() => mockBudgetBloc.add(any<DuplicateBudgetEvent>())).called(1);
    });

    testWidgets('can toggle Include Transactions switch', (tester) async {
      await tester.pumpWidget(buildDialog());
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();
      await tester.tap(find.byType(SwitchListTile));
      await tester.pumpAndSettle();
      final switchWidget = tester.widget<SwitchListTile>(find.byType(SwitchListTile));
      expect(switchWidget.value, isFalse);
    });
  });
}
