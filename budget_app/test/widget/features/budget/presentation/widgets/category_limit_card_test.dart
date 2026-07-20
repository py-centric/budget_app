import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mocktail/mocktail.dart';
import 'package:budget_app/features/budget/presentation/widgets/category_limit_card.dart';
import 'package:budget_app/features/budget/presentation/widgets/category_limit_progress_bar.dart';
import 'package:budget_app/features/budget/domain/entities/category_limit.dart';
import 'package:budget_app/features/budget/presentation/bloc/category_limit_state.dart';
import 'package:budget_app/features/settings/presentation/bloc/settings_bloc.dart';

class MockSettingsBloc extends Mock implements SettingsBloc {}

void main() {
  late MockSettingsBloc mockSettingsBloc;

  setUp(() {
    mockSettingsBloc = MockSettingsBloc();
    when(() => mockSettingsBloc.state).thenReturn(const SettingsState());
    when(() => mockSettingsBloc.stream).thenAnswer((_) => const Stream.empty());
  });

  final limit = CategoryLimit(
    id: 'cl-1', categoryId: 'food', amount: 500,
    period: LimitPeriod.monthly,
    createdAt: DateTime(2024, 6, 1), updatedAt: DateTime(2024, 6, 1),
  );

  Widget buildCard({
    CategoryLimitWithSpending? data,
    VoidCallback? onEdit,
    VoidCallback? onDelete,
  }) {
    return MaterialApp(
      home: Scaffold(
        body: BlocProvider<SettingsBloc>.value(
          value: mockSettingsBloc,
          child: CategoryLimitCard(
            limitWithSpending: data ?? CategoryLimitWithSpending(
              limit: limit,
              spentAmount: 300,
              categoryName: 'Food',
              categoryIcon: 'restaurant',
            ),
            onEdit: onEdit,
            onDelete: onDelete,
          ),
        ),
      ),
    );
  }

  group('CategoryLimitCard', () {
    testWidgets('renders category name', (tester) async {
      await tester.pumpWidget(buildCard());
      expect(find.text('Food'), findsOneWidget);
    });

    testWidgets('shows monthly label for monthly limit', (tester) async {
      await tester.pumpWidget(buildCard());
      expect(find.text('Monthly'), findsOneWidget);
    });

    testWidgets('shows weekly label for weekly limit', (tester) async {
      final weeklyLimit = CategoryLimit(
        id: 'cl-2', categoryId: 'food', amount: 100,
        period: LimitPeriod.weekly,
        createdAt: DateTime.now(), updatedAt: DateTime.now(),
      );
      await tester.pumpWidget(buildCard(
        data: CategoryLimitWithSpending(
          limit: weeklyLimit, spentAmount: 50, categoryName: 'Food',
        ),
      ));
      expect(find.text('Weekly'), findsOneWidget);
    });

    testWidgets('shows remaining amount when under budget', (tester) async {
      await tester.pumpWidget(buildCard());
      expect(find.textContaining('left'), findsOneWidget);
    });

    testWidgets('shows over budget message', (tester) async {
      await tester.pumpWidget(buildCard(
        data: CategoryLimitWithSpending(
          limit: limit, spentAmount: 600, categoryName: 'Food',
        ),
      ));
      expect(find.textContaining('Over by'), findsOneWidget);
    });

    testWidgets('delete button visible when onDelete provided', (tester) async {
      await tester.pumpWidget(buildCard(onDelete: () {}));
      expect(find.byIcon(Icons.delete_outline), findsOneWidget);
    });

    testWidgets('delete button hidden when onDelete is null', (tester) async {
      await tester.pumpWidget(buildCard());
      expect(find.byIcon(Icons.delete_outline), findsNothing);
    });

    testWidgets('tapping card calls onEdit', (tester) async {
      var called = false;
      await tester.pumpWidget(buildCard(onEdit: () => called = true));
      await tester.tap(find.byType(InkWell));
      expect(called, isTrue);
    });

    testWidgets('renders CategoryLimitProgressBar', (tester) async {
      await tester.pumpWidget(buildCard());
      expect(find.byType(CategoryLimitProgressBar), findsOneWidget);
    });

    testWidgets('renders with null icon uses default', (tester) async {
      await tester.pumpWidget(buildCard(
        data: CategoryLimitWithSpending(
          limit: limit, spentAmount: 50, categoryName: 'Other',
        ),
      ));
      expect(find.byIcon(Icons.category), findsOneWidget);
    });

    testWidgets('renders restaurant icon', (tester) async {
      await tester.pumpWidget(buildCard());
      expect(find.byIcon(Icons.restaurant), findsOneWidget);
    });
  });
}
