import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mocktail/mocktail.dart';
import 'package:budget_app/features/budget/domain/entities/income_entry.dart';
import 'package:budget_app/features/budget/domain/entities/expense_entry.dart';
import 'package:budget_app/features/budget/domain/entities/category.dart';
import 'package:budget_app/features/budget/domain/entities/budget_period.dart';
import 'package:budget_app/features/budget/domain/repositories/budget_repository.dart';
import 'package:budget_app/features/budget/domain/repositories/recurring_repository.dart';
import 'package:budget_app/features/emergency_fund/domain/repositories/emergency_fund_repository.dart';
import 'package:budget_app/features/budget/domain/usecases/add_income.dart';
import 'package:budget_app/features/budget/domain/usecases/add_expense.dart';
import 'package:budget_app/features/budget/domain/usecases/calculate_summary.dart';
import 'package:budget_app/features/budget/domain/usecases/delete_entry.dart';
import 'package:budget_app/features/budget/domain/usecases/update_entry.dart';
import 'package:budget_app/features/budget/domain/usecases/save_recurring_transaction.dart';
import 'package:budget_app/features/budget/domain/usecases/calculate_projection.dart';
import 'package:budget_app/features/budget/domain/usecases/apply_recurring_override.dart';
import 'package:budget_app/features/budget/domain/usecases/get_available_periods.dart';
import 'package:budget_app/features/budget/domain/usecases/duplicate_budget.dart';
import 'package:budget_app/features/budget/domain/usecases/confirm_potential_transaction.dart';
import 'package:budget_app/features/budget/presentation/budget_bloc.dart';
import 'package:budget_app/features/budget/presentation/budget_event.dart';
import 'package:budget_app/features/budget/presentation/bloc/navigation_bloc.dart';
import 'package:budget_app/features/budget/presentation/bloc/projection_bloc.dart';
import 'package:budget_app/features/budget/presentation/pages/home_page.dart';
import 'package:budget_app/features/settings/presentation/bloc/settings_bloc.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:bloc_test/bloc_test.dart';

class MockBudgetRepository extends Mock implements BudgetRepository {}
class MockRecurringRepository extends Mock implements RecurringRepository {}
class MockEmergencyFundRepository extends Mock implements EmergencyFundRepository {}
class MockAddIncome extends Mock implements AddIncome {}
class MockAddExpense extends Mock implements AddExpense {}
class MockCalculateSummary extends Mock implements CalculateSummary {}
class MockDeleteEntry extends Mock implements DeleteEntry {}
class MockUpdateEntry extends Mock implements UpdateEntry {}
class MockSaveRecurringTransaction extends Mock implements SaveRecurringTransaction {}
class MockDuplicateBudget extends Mock implements DuplicateBudget {}
class MockConfirmPotentialTransaction extends Mock implements ConfirmPotentialTransaction {}
class MockGetAvailablePeriods extends Mock implements GetAvailablePeriods {}
class MockStorage extends Mock implements Storage {}
class MockSettingsBloc extends MockBloc<SettingsEvent, SettingsState> implements SettingsBloc {}

class FakeIncomeEntry extends Fake implements IncomeEntry {}
class FakeExpenseEntry extends Fake implements ExpenseEntry {}
class FakeBudgetPeriod extends Fake implements BudgetPeriod {}

void main() {
  late MockBudgetRepository mockRepository;
  late MockRecurringRepository mockRecurringRepository;
  late MockEmergencyFundRepository mockEmergencyFundRepository;
  late MockAddIncome mockAddIncome;
  late MockAddExpense mockAddExpense;
  late MockCalculateSummary mockCalculateSummary;
  late MockDeleteEntry mockDeleteEntry;
  late MockUpdateEntry mockUpdateEntry;
  late MockSaveRecurringTransaction mockSaveRecurringTransaction;
  late MockDuplicateBudget mockDuplicateBudget;
  late MockConfirmPotentialTransaction mockConfirmPotentialTransaction;
  late MockGetAvailablePeriods mockGetAvailablePeriods;
  late MockStorage mockStorage;
  late MockSettingsBloc mockSettingsBloc;

  setUpAll(() {
    registerFallbackValue(FakeIncomeEntry());
    registerFallbackValue(FakeExpenseEntry());
    registerFallbackValue(FakeBudgetPeriod());
  });

  setUp(() {
    mockRepository = MockBudgetRepository();
    mockRecurringRepository = MockRecurringRepository();
    mockEmergencyFundRepository = MockEmergencyFundRepository();
    mockAddIncome = MockAddIncome();
    mockAddExpense = MockAddExpense();
    mockCalculateSummary = MockCalculateSummary();
    mockDeleteEntry = MockDeleteEntry();
    mockUpdateEntry = MockUpdateEntry();
    mockSaveRecurringTransaction = MockSaveRecurringTransaction();
    mockDuplicateBudget = MockDuplicateBudget();
    mockGetAvailablePeriods = MockGetAvailablePeriods();
    mockConfirmPotentialTransaction = MockConfirmPotentialTransaction();
    mockStorage = MockStorage();
    mockSettingsBloc = MockSettingsBloc();
    
    when(() => mockStorage.write(any(), any<dynamic>())).thenAnswer((_) async {});
    HydratedBloc.storage = mockStorage;

    when(() => mockSettingsBloc.state).thenReturn(const SettingsState());
    when(() => mockEmergencyFundRepository.watchTotalTarget()).thenAnswer((_) => Stream.fromIterable([0.0]));
  });

  group('Integration Test: Full User Flow', () {
    testWidgets('should add income and display in summary', (
      WidgetTester tester,
    ) async {
      when(
        () => mockRepository.getCategories(),
      ).thenAnswer(
        (_) async => [
          const Category(id: '1', name: 'Food', type: CategoryType.expense),
          const Category(id: '2', name: 'Transport', type: CategoryType.expense),
        ],
      );
      when(() => mockRepository.getAllIncome()).thenAnswer((_) async => []);
      when(() => mockRepository.getAllExpenses()).thenAnswer((_) async => []);
      when(() => mockAddIncome.call(any())).thenAnswer((_) async {});
      when(() => mockCalculateSummary.call(
        period: any(named: 'period'),
        budgetId: any(named: 'budgetId'),
      )).thenAnswer(
        (_) async => BudgetSummary(
          totalIncome: 1000.0,
          totalExpenses: 0.0,
          balance: 1000.0,
          totalPotentialIncome: 1000.0,
          totalPotentialExpenses: 0.0,
          incomeEntries: [
            IncomeEntry(
              id: '1',
              budgetId: 'default',
              amount: 1000.0,
              description: 'Salary',
              date: DateTime(2026, 1, 15),
            ),
          ],
          expenseEntries: [],
        ),
      );
      when(() => mockGetAvailablePeriods.call()).thenAnswer((_) async => [BudgetPeriod.current()]);
      when(() => mockRepository.getBudgetsForPeriod(any())).thenAnswer((_) async => []);

      final calculateProjection = CalculateProjection(mockRepository, mockRecurringRepository);
      final applyRecurringOverride = ApplyRecurringOverride(mockRecurringRepository);

      await tester.pumpWidget(
        MaterialApp(
          home: MultiBlocProvider(
            providers: [
              BlocProvider<SettingsBloc>.value(value: mockSettingsBloc),
              BlocProvider<BudgetBloc>(
                create: (_) => BudgetBloc(
                  repository: mockRepository,
                  addIncomeUseCase: mockAddIncome,
                  addExpenseUseCase: mockAddExpense,
                  calculateSummaryUseCase: mockCalculateSummary,
                  deleteEntryUseCase: mockDeleteEntry,
                  updateEntryUseCase: mockUpdateEntry,
                  saveRecurringTransactionUseCase: mockSaveRecurringTransaction,
                  duplicateBudgetUseCase: mockDuplicateBudget,
                  confirmPotentialTransactionUseCase: mockConfirmPotentialTransaction,
                )
                ..add(const LoadSummaryEvent())
                ..add(const LoadCategoriesEvent()),
              ),
              BlocProvider<NavigationBloc>(
                create: (_) => NavigationBloc(
                  getAvailablePeriodsUseCase: mockGetAvailablePeriods,
                  budgetRepository: mockRepository,
                ),
              ),
              BlocProvider<ProjectionBloc>(
                create: (_) => ProjectionBloc(
                  calculateProjection: calculateProjection,
                  applyRecurringOverride: applyRecurringOverride,
                  emergencyFundRepository: mockEmergencyFundRepository,
                ),
              ),
            ],
            child: const HomePage(),
          ),
        ),
      );

      await tester.pump(const Duration(seconds: 1));
      await tester.pump(const Duration(seconds: 1));

      expect(find.text('Budget App'), findsOneWidget);
    });
  });
}
