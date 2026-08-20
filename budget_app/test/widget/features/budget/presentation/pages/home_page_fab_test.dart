import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mocktail/mocktail.dart';
import 'package:budget_app/features/accounts/presentation/bloc/account_bloc.dart';
import 'package:budget_app/features/accounts/presentation/bloc/account_state.dart';
import 'package:budget_app/features/budget/domain/entities/budget.dart';
import 'package:budget_app/features/budget/domain/entities/budget_period.dart';
import 'package:budget_app/features/budget/domain/entities/category.dart';
import 'package:budget_app/features/budget/domain/entities/income_entry.dart';
import 'package:budget_app/features/budget/domain/entities/expense_entry.dart';
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
import 'package:budget_app/features/budget/presentation/bloc/budget_bloc.dart';
import 'package:budget_app/features/budget/presentation/bloc/budget_event.dart';
import 'package:budget_app/features/budget/presentation/bloc/category_limit_bloc.dart';
import 'package:budget_app/features/budget/presentation/bloc/category_limit_state.dart';
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

class MockNavigationBloc extends Cubit<NavigationState> implements NavigationBloc {
  MockNavigationBloc()
      : super(
          const NavigationState(
            currentPeriod: BudgetPeriod(year: 2026, month: 4),
            activeBudget: Budget(
              id: 'b_1',
              name: 'Main Budget',
              periodMonth: 4,
              periodYear: 2026,
              isActive: true,
            ),
          ),
        );

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class MockAccountBloc extends Cubit<AccountState> implements AccountBloc {
  MockAccountBloc() : super(const AccountLoaded(accounts: [], totalBalance: 0.0));

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class MockCategoryLimitBloc extends Cubit<CategoryLimitState> implements CategoryLimitBloc {
  MockCategoryLimitBloc() : super(CategoryLimitInitial());

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

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
  late MockGetAvailablePeriods mockGetAvailablePeriods;
  late MockConfirmPotentialTransaction mockConfirmPotentialTransaction;
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

  Widget createWidgetUnderTest() {
    when(() => mockRepository.getCategories()).thenAnswer(
      (_) async => [
        const Category(id: '1', name: 'Food', type: CategoryType.expense),
      ],
    );
    when(() => mockRepository.getAllIncome()).thenAnswer((_) async => []);
    when(() => mockRepository.getAllExpenses()).thenAnswer((_) async => []);
    when(
      () => mockCalculateSummary.call(
        period: any(named: 'period'),
        budgetId: any(named: 'budgetId'),
        accountFilter: any(named: 'accountFilter'),
      ),
    ).thenAnswer(
      (_) async => BudgetSummary(
        totalIncome: 1000.0,
        totalExpenses: 0.0,
        balance: 1000.0,
        totalPotentialIncome: 1000.0,
        totalPotentialExpenses: 0.0,
        incomeEntries: [
          IncomeEntry(
            id: '1',
            budgetId: 'b_1',
            amount: 1000.0,
            description: 'Salary',
            date: DateTime(2026, 4, 15),
          ),
        ],
        expenseEntries: [],
      ),
    );
    when(() => mockGetAvailablePeriods.call()).thenAnswer((_) async => [const BudgetPeriod(year: 2026, month: 4)]);
    when(() => mockRepository.getBudgetsForPeriod(any())).thenAnswer(
      (_) async => [
        const Budget(
          id: 'b_1',
          name: 'Main Budget',
          periodMonth: 4,
          periodYear: 2026,
          isActive: true,
        ),
      ],
    );

    final calculateProjection = CalculateProjection(
      mockRepository,
      mockRecurringRepository,
    );
    final applyRecurringOverride = ApplyRecurringOverride(
      mockRecurringRepository,
    );

    return MultiBlocProvider(
      providers: [
        BlocProvider<SettingsBloc>.value(value: mockSettingsBloc),
        BlocProvider<AccountBloc>(create: (_) => MockAccountBloc()),
        BlocProvider<CategoryLimitBloc>(create: (_) => MockCategoryLimitBloc()),
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
          create: (_) => MockNavigationBloc(),
        ),
        BlocProvider<ProjectionBloc>(
          create: (_) => ProjectionBloc(
            calculateProjection: calculateProjection,
            applyRecurringOverride: applyRecurringOverride,
            emergencyFundRepository: mockEmergencyFundRepository,
          ),
        ),
      ],
      child: const MaterialApp(
        home: HomePage(),
      ),
    );
  }

  group('HomePage Floating Action Buttons Tests', () {
    testWidgets('renders Add Income and Add Expense floating action buttons', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pump(const Duration(seconds: 1));
      await tester.pump(const Duration(seconds: 1));

      final fabAddIncome = find.widgetWithText(FloatingActionButton, 'Add Income');
      final fabAddExpense = find.widgetWithText(FloatingActionButton, 'Add Expense');

      expect(fabAddIncome, findsOneWidget);
      expect(fabAddExpense, findsOneWidget);
    });

    testWidgets('tapping Add Income FAB opens transaction dialog with Add Income title', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pump(const Duration(seconds: 1));
      await tester.pump(const Duration(seconds: 1));

      final fabAddIncome = find.widgetWithText(FloatingActionButton, 'Add Income');
      await tester.tap(fabAddIncome);
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pump(const Duration(milliseconds: 500));

      // Dialog title
      expect(find.text('Add Income'), findsWidgets);
      expect(find.byType(AlertDialog), findsOneWidget);
    });

    testWidgets('tapping Add Expense FAB opens transaction dialog with Add Expense title', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pump(const Duration(seconds: 1));
      await tester.pump(const Duration(seconds: 1));

      final fabAddExpense = find.widgetWithText(FloatingActionButton, 'Add Expense');
      await tester.tap(fabAddExpense);
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pump(const Duration(milliseconds: 500));

      // Dialog title
      expect(find.text('Add Expense'), findsWidgets);
      expect(find.byType(AlertDialog), findsOneWidget);
    });

    testWidgets('floating action buttons span 90% of screen width', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pump(const Duration(seconds: 1));
      await tester.pump(const Duration(seconds: 1));

      final fabAddIncome = find.widgetWithText(FloatingActionButton, 'Add Income');
      final fabAddExpense = find.widgetWithText(FloatingActionButton, 'Add Expense');

      final incomeSize = tester.getSize(fabAddIncome);
      final expenseSize = tester.getSize(fabAddExpense);

      // Default tester screen width is 800. 90% = 720, so each button is ~352 (half minus spacing)
      final screenWidth = tester.view.physicalSize.width / tester.view.devicePixelRatio;
      final expectedContainerWidth = screenWidth * 0.9;
      final totalButtonsWidth = incomeSize.width + expenseSize.width;

      expect(totalButtonsWidth, closeTo(expectedContainerWidth - 16, 2.0));
    });
  });
}
