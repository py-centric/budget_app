import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mocktail/mocktail.dart';
import 'package:budget_app/features/budget/domain/entities/income_entry.dart';
import 'package:budget_app/features/budget/presentation/widgets/income_list.dart';
import 'package:budget_app/features/settings/presentation/bloc/settings_bloc.dart';

class MockSettingsBloc extends Mock implements SettingsBloc {}

void main() {
  late MockSettingsBloc mockSettingsBloc;

  final testIncomes = [
    IncomeEntry(
      id: 'inc-1',
      budgetId: 'b1',
      amount: 5000.0,
      categoryId: 'salary',
      description: 'Salary',
      date: DateTime(2024, 1, 15),
    ),
    IncomeEntry(
      id: 'inc-2',
      budgetId: 'b1',
      amount: 500.0,
      categoryId: 'freelance',
      description: 'Side gig',
      date: DateTime(2024, 1, 20),
    ),
  ];

  setUp(() {
    mockSettingsBloc = MockSettingsBloc();
    when(() => mockSettingsBloc.state).thenReturn(const SettingsState());
    when(() => mockSettingsBloc.stream).thenAnswer((_) => const Stream.empty());
  });

  Widget buildIncomeList({
    required List<IncomeEntry> entries,
    Function(IncomeEntry)? onEdit,
    Function(IncomeEntry)? onDelete,
    Function(IncomeEntry)? onConfirm,
    Set<String>? disposableBudgetIds,
  }) {
    return MaterialApp(
      home: Scaffold(
        body: BlocProvider<SettingsBloc>.value(
          value: mockSettingsBloc,
          child: IncomeList(
            entries: entries,
            onEdit: onEdit ?? (_) {},
            onDelete: onDelete ?? (_) {},
            onConfirm: onConfirm,
            disposableBudgetIds: disposableBudgetIds,
          ),
        ),
      ),
    );
  }

  group('IncomeList', () {
    testWidgets('shows empty state when no entries', (tester) async {
      await tester.pumpWidget(buildIncomeList(entries: []));

      expect(find.textContaining('No income entries'), findsOneWidget);
    });

    testWidgets('renders income entries', (tester) async {
      await tester.pumpWidget(buildIncomeList(entries: testIncomes));

      expect(find.textContaining('Salary'), findsOneWidget);
      expect(find.textContaining('Side gig'), findsOneWidget);
    });

    testWidgets('renders with disposable budget badge', (tester) async {
      await tester.pumpWidget(buildIncomeList(
        entries: testIncomes,
        disposableBudgetIds: {'b1'},
      ));

      expect(find.byIcon(Icons.all_inbox), findsWidgets);
    });

    testWidgets('renders without disposable badge when no ids provided', (tester) async {
      await tester.pumpWidget(buildIncomeList(entries: testIncomes));

      expect(find.byIcon(Icons.all_inbox), findsNothing);
    });
  });
}
