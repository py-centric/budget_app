import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mocktail/mocktail.dart';
import 'package:budget_app/features/savings/presentation/widgets/savings_goal_card.dart';
import 'package:budget_app/features/savings/presentation/widgets/savings_goal_progress_bar.dart';
import 'package:budget_app/features/savings/presentation/bloc/savings_state.dart';
import 'package:budget_app/features/savings/domain/entities/savings_goal.dart';
import 'package:budget_app/features/savings/domain/entities/savings_contribution.dart';
import 'package:budget_app/features/settings/presentation/bloc/settings_bloc.dart';

class MockSettingsBloc extends Mock implements SettingsBloc {}

void main() {
  late MockSettingsBloc mockSettingsBloc;

  final now = DateTime(2024, 6, 15);
  final goal = SavingsGoal(
    id: 'g-1', name: 'Vacation Fund', targetAmount: 5000,
    currentAmount: 2500, icon: 'flight', color: 'blue',
    createdAt: now, updatedAt: now,
  );

  final goalWithContributions = SavingsGoalWithContributions(
    goal: goal,
    contributions: [
      SavingsContribution(id: 'c-1', goalId: 'g-1', amount: 1000, date: now, createdAt: now),
      SavingsContribution(id: 'c-2', goalId: 'g-1', amount: 1500, date: now, createdAt: now),
    ],
  );

  setUp(() {
    mockSettingsBloc = MockSettingsBloc();
    when(() => mockSettingsBloc.state).thenReturn(const SettingsState());
    when(() => mockSettingsBloc.stream).thenAnswer((_) => const Stream.empty());
  });

  Widget buildCard({
    SavingsGoalWithContributions? data,
    VoidCallback? onEdit,
    VoidCallback? onDelete,
    VoidCallback? onAddContribution,
  }) {
    return MaterialApp(
      home: Scaffold(
        body: BlocProvider<SettingsBloc>.value(
          value: mockSettingsBloc,
          child: SavingsGoalCard(
            goalWithContributions: data ?? goalWithContributions,
            onEdit: onEdit,
            onDelete: onDelete,
            onAddContribution: onAddContribution,
          ),
        ),
      ),
    );
  }

  group('SavingsGoalCard', () {
    testWidgets('renders goal name', (tester) async {
      await tester.pumpWidget(buildCard());
      expect(find.text('Vacation Fund'), findsOneWidget);
    });

    testWidgets('shows progress bar', (tester) async {
      await tester.pumpWidget(buildCard());
      expect(find.byType(SavingsGoalProgressBar), findsOneWidget);
    });

    testWidgets('shows percentage and remaining', (tester) async {
      await tester.pumpWidget(buildCard());
      expect(find.textContaining('50%'), findsOneWidget);
      expect(find.textContaining('left'), findsOneWidget);
    });

    testWidgets('shows "Completed!" when goal is completed', (tester) async {
      final completedGoal = SavingsGoal(
        id: 'g-2', name: 'Done Goal', targetAmount: 5000,
        currentAmount: 5000, isCompleted: true,
        icon: 'savings', color: 'green',
        createdAt: now, updatedAt: now,
      );
      final completed = SavingsGoalWithContributions(
        goal: completedGoal, contributions: [],
      );
      await tester.pumpWidget(buildCard(data: completed));
      expect(find.text('Completed!'), findsOneWidget);
    });

    testWidgets('tapping card calls onAddContribution', (tester) async {
      var called = false;
      await tester.pumpWidget(buildCard(onAddContribution: () => called = true));
      await tester.tap(find.byType(InkWell));
      expect(called, isTrue);
    });

    testWidgets('shows flight icon', (tester) async {
      await tester.pumpWidget(buildCard());
      expect(find.byIcon(Icons.flight), findsOneWidget);
    });

    testWidgets('shows default savings icon when icon is null', (tester) async {
      final noIconGoal = SavingsGoal(
        id: 'g-3', name: 'No Icon Goal', targetAmount: 1000,
        currentAmount: 500, createdAt: now, updatedAt: now,
      );
      final noIcon = SavingsGoalWithContributions(goal: noIconGoal, contributions: []);
      await tester.pumpWidget(buildCard(data: noIcon));
      expect(find.byIcon(Icons.savings), findsOneWidget);
    });

    testWidgets('PopupMenuButton shows Edit and Delete options', (tester) async {
      await tester.pumpWidget(buildCard(onEdit: () {}, onDelete: () {}));
      await tester.tap(find.byType(PopupMenuButton<String>));
      await tester.pumpAndSettle();
      expect(find.text('Edit'), findsOneWidget);
      expect(find.text('Delete'), findsOneWidget);
    });

    testWidgets('Edit menu calls onEdit', (tester) async {
      var called = false;
      await tester.pumpWidget(buildCard(onEdit: () => called = true, onDelete: () {}));
      await tester.tap(find.byType(PopupMenuButton<String>));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Edit'));
      await tester.pumpAndSettle();
      expect(called, isTrue);
    });

    testWidgets('Delete menu calls onDelete', (tester) async {
      var called = false;
      await tester.pumpWidget(buildCard(onEdit: () {}, onDelete: () => called = true));
      await tester.tap(find.byType(PopupMenuButton<String>));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Delete'));
      await tester.pumpAndSettle();
      expect(called, isTrue);
    });

    testWidgets('hides menu when no callbacks provided', (tester) async {
      await tester.pumpWidget(buildCard());
      expect(find.byType(PopupMenuButton<String>), findsNothing);
    });

    testWidgets('shows "Linked to category" when linkedCategoryId is set', (tester) async {
      final linkedGoal = goal.copyWith(linkedCategoryId: 'food');
      final linked = SavingsGoalWithContributions(goal: linkedGoal, contributions: []);
      await tester.pumpWidget(buildCard(data: linked));
      expect(find.text('Linked to category'), findsOneWidget);
    });

    testWidgets('hides "Linked to category" when not linked', (tester) async {
      await tester.pumpWidget(buildCard());
      expect(find.text('Linked to category'), findsNothing);
    });
  });
}
