import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mocktail/mocktail.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:budget_app/features/budget/presentation/widgets/income_form.dart';
import 'package:budget_app/features/budget/domain/entities/category.dart';
import 'package:budget_app/features/settings/presentation/bloc/settings_bloc.dart';
import 'package:budget_app/features/budget/presentation/widgets/split_transaction_dialog.dart';

class MockSettingsBloc extends MockBloc<SettingsEvent, SettingsState>
    implements SettingsBloc {}

void main() {
  late MockSettingsBloc mockSettingsBloc;

  setUp(() {
    mockSettingsBloc = MockSettingsBloc();
    when(() => mockSettingsBloc.state).thenReturn(const SettingsState());
  });

  final testCategories = [
    const Category(
      id: '1',
      name: 'Salary',
      type: CategoryType.income,
      icon: 'attach_money',
    ),
    const Category(
      id: '2',
      name: 'Gift',
      type: CategoryType.income,
      icon: 'card_giftcard',
    ),
  ];

  group('IncomeForm Widget Tests', () {
    testWidgets('should render correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider<SettingsBloc>.value(
            value: mockSettingsBloc,
            child: Scaffold(
              body: IncomeForm(
                categories: testCategories,
                onSubmit:
                    (
                      id,
                      amount,
                      categoryId,
                      description,
                      date, {
                      endDate,
                      interval,
                      isRecurring = false,
                      unit,
                      isPotential = false,
                      splits,
                    }) {},
              ),
            ),
          ),
        ),
      );

      expect(find.text('Add Income'), findsNWidgets(2));
      expect(find.text('Amount'), findsOneWidget);
      expect(find.text('Category'), findsOneWidget);
      expect(find.text('Description (optional)'), findsOneWidget);
    });

    testWidgets('should show validation error for empty amount', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider<SettingsBloc>.value(
            value: mockSettingsBloc,
            child: Scaffold(
              body: IncomeForm(
                categories: testCategories,
                onSubmit:
                    (
                      id,
                      amount,
                      categoryId,
                      description,
                      date, {
                      endDate,
                      interval,
                      isRecurring = false,
                      unit,
                      isPotential = false,
                      splits,
                    }) {},
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.widgetWithText(ElevatedButton, 'Add Income'));
      await tester.pumpAndSettle();

      expect(find.text('Please enter an amount'), findsOneWidget);
    });

    testWidgets('should show validation error for zero amount', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider<SettingsBloc>.value(
            value: mockSettingsBloc,
            child: Scaffold(
              body: IncomeForm(
                categories: testCategories,
                onSubmit:
                    (
                      id,
                      amount,
                      categoryId,
                      description,
                      date, {
                      endDate,
                      interval,
                      isRecurring = false,
                      unit,
                      isPotential = false,
                      splits,
                    }) {},
              ),
            ),
          ),
        ),
      );

      await tester.enterText(find.widgetWithText(TextFormField, 'Amount'), '0');
      await tester.tap(find.widgetWithText(ElevatedButton, 'Add Income'));
      await tester.pumpAndSettle();

      expect(
        find.text('Please enter a valid positive amount or expression'),
        findsOneWidget,
      );
    });
  });
}
