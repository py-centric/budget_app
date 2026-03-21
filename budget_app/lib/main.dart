import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:path_provider/path_provider.dart';

import 'core/theme/app_theme.dart';
import 'features/budget/data/datasources/local_database.dart';
import 'features/budget/data/repositories/budget_repository_impl.dart';
import 'features/budget/data/repositories/recurring_repository_impl.dart';
import 'features/budget/domain/repositories/budget_repository.dart';
import 'features/budget/domain/repositories/recurring_repository.dart';
import 'features/budget/domain/usecases/add_income.dart';
import 'features/budget/domain/usecases/add_expense.dart';
import 'features/budget/domain/usecases/calculate_summary.dart';
import 'features/budget/domain/usecases/get_available_periods.dart';
import 'features/budget/domain/usecases/delete_entry.dart';
import 'features/budget/domain/usecases/update_entry.dart';
import 'features/budget/domain/usecases/manage_categories.dart';
import 'features/budget/domain/usecases/calculate_projection.dart';
import 'features/budget/domain/usecases/save_recurring_transaction.dart';
import 'features/budget/domain/usecases/apply_recurring_override.dart';
import 'features/budget/domain/usecases/duplicate_budget.dart';
import 'features/budget/domain/usecases/confirm_potential_transaction.dart';
import 'features/budget/presentation/budget_bloc.dart';
import 'features/budget/presentation/bloc/navigation_bloc.dart';
import 'features/budget/presentation/bloc/category_bloc.dart';
import 'features/budget/presentation/bloc/projection_bloc.dart';
import 'features/budget/presentation/bloc/projection_event.dart';
import 'features/budget/presentation/pages/home_page.dart';
import 'features/financial_tools/domain/repositories/financial_repository.dart';
import 'features/financial_tools/data/repositories/financial_repository_impl.dart';
import 'features/financial_tools/domain/usecases/calculate_net_worth.dart';
import 'features/financial_tools/domain/usecases/calculate_amortization.dart';
import 'features/financial_tools/domain/usecases/calculate_compound_interest.dart';
import 'features/financial_tools/presentation/bloc/financial_bloc.dart';
import 'features/settings/presentation/bloc/settings_bloc.dart';
import 'features/emergency_fund/domain/repositories/emergency_fund_repository.dart';
import 'features/emergency_fund/data/repositories/emergency_fund_repository_impl.dart';
import 'features/emergency_fund/presentation/bloc/emergency_fund_bloc.dart';
import 'features/emergency_fund/presentation/bloc/emergency_fund_event.dart';
import 'features/business_tools/domain/repositories/business_repository.dart';
import 'features/business_tools/data/repositories/business_repository_impl.dart';
import 'features/business_tools/presentation/bloc/business_bloc.dart';
import 'features/business_tools/presentation/bloc/business_event.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  HydratedBloc.storage = await HydratedStorage.build(
    storageDirectory: kIsWeb
        ? HydratedStorage.webStorageDirectory
        : await getApplicationDocumentsDirectory(),
  );

  // Initialize database (handles FFI on desktop)
  await LocalDatabase.initialize();

  final localDatabase = LocalDatabase.instance;
  final repository = BudgetRepositoryImpl(localDatabase);
  final recurringRepository = RecurringRepositoryImpl(localDatabase);
  final financialRepository = FinancialRepositoryImpl(localDatabase);
  final emergencyFundRepository = EmergencyFundRepositoryImpl(localDatabase);
  final businessRepository = BusinessRepositoryImpl(localDatabase);

  runApp(
    MultiRepositoryProvider(
      providers: [
        RepositoryProvider<RecurringRepository>(
          create: (context) => recurringRepository,
        ),
        RepositoryProvider<EmergencyFundRepository>(
          create: (context) => emergencyFundRepository,
        ),
        RepositoryProvider<BusinessRepository>(
          create: (context) => businessRepository,
        ),
      ],
      child: BudgetApp(
        repository: repository,
        recurringRepository: recurringRepository,
        financialRepository: financialRepository,
        emergencyFundRepository: emergencyFundRepository,
        businessRepository: businessRepository,
      ),
    ),
  );
}

class BudgetApp extends StatelessWidget {
  final BudgetRepository repository;
  final RecurringRepository recurringRepository;
  final FinancialRepository financialRepository;
  final EmergencyFundRepository emergencyFundRepository;
  final BusinessRepository businessRepository;

  const BudgetApp({
    super.key,
    required this.repository,
    required this.recurringRepository,
    required this.financialRepository,
    required this.emergencyFundRepository,
    required this.businessRepository,
  });

  @override
  Widget build(BuildContext context) {
    final addIncomeUseCase = AddIncome(repository);
    final addExpenseUseCase = AddExpense(repository);
    final calculateSummaryUseCase = CalculateSummary(repository);
    final getAvailablePeriodsUseCase = GetAvailablePeriods(repository);
    final deleteEntryUseCase = DeleteEntry(repository);
    final updateEntryUseCase = UpdateEntry(repository);
    final saveRecurringTransactionUseCase = SaveRecurringTransaction(recurringRepository);
    final applyRecurringOverrideUseCase = ApplyRecurringOverride(recurringRepository);
    final duplicateBudgetUseCase = DuplicateBudget(repository);
    final confirmPotentialTransactionUseCase = ConfirmPotentialTransaction(repository);
    
    final addCategoryUseCase = AddCategory(repository);
    final deleteCategoryUseCase = DeleteCategory(repository);
    final reassignAndDeleteCategoryUseCase = ReassignAndDeleteCategory(repository);
    final calculateProjectionUseCase = CalculateProjection(repository, recurringRepository);

    final calculateNetWorthUseCase = CalculateNetWorth();
    final calculateAmortizationUseCase = CalculateAmortization();
    final calculateCompoundInterestUseCase = CalculateCompoundInterest();

    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => SettingsBloc()..add(const InitializeSettingsEvent()),
        ),
        BlocProvider(
          create: (_) => FinancialBloc(
            repository: financialRepository,
            calculateNetWorth: calculateNetWorthUseCase,
            calculateAmortization: calculateAmortizationUseCase,
            calculateCompoundInterest: calculateCompoundInterestUseCase,
          ),
        ),
        BlocProvider(
          create: (_) => NavigationBloc(
            getAvailablePeriodsUseCase: getAvailablePeriodsUseCase,
            budgetRepository: repository,
          )..add(const LoadAvailablePeriods()),
        ),
        BlocProvider(
          create: (_) => BudgetBloc(
            repository: repository,
            addIncomeUseCase: addIncomeUseCase,
            addExpenseUseCase: addExpenseUseCase,
            calculateSummaryUseCase: calculateSummaryUseCase,
            deleteEntryUseCase: deleteEntryUseCase,
            updateEntryUseCase: updateEntryUseCase,
            saveRecurringTransactionUseCase: saveRecurringTransactionUseCase,
            duplicateBudgetUseCase: duplicateBudgetUseCase,
            confirmPotentialTransactionUseCase: confirmPotentialTransactionUseCase,
          ),
        ),
        BlocProvider(
          create: (_) => CategoryBloc(
            repository: repository,
            addCategoryUseCase: addCategoryUseCase,
            deleteCategoryUseCase: deleteCategoryUseCase,
            reassignAndDeleteCategoryUseCase: reassignAndDeleteCategoryUseCase,
          )..add(LoadCategories()),
        ),
        BlocProvider(
          create: (_) => ProjectionBloc(
            calculateProjection: calculateProjectionUseCase,
            applyRecurringOverride: applyRecurringOverrideUseCase,
            emergencyFundRepository: emergencyFundRepository,
          )..add(const LoadProjection()),
        ),
        BlocProvider(
          create: (_) => EmergencyFundBloc(emergencyFundRepository)..add(LoadEmergencyFund()),
        ),
        BlocProvider(
          create: (_) => BusinessBloc(businessRepository)..add(LoadBusinessData()),
        ),
      ],
      child: BlocBuilder<SettingsBloc, SettingsState>(
        builder: (context, state) {
          ThemeMode mode;
          switch (state.settings.themeMode) {
            case 'light':
              mode = ThemeMode.light;
              break;
            case 'dark':
              mode = ThemeMode.dark;
              break;
            default:
              mode = ThemeMode.system;
          }

          return MaterialApp(
            title: 'Budget App',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: mode,
            home: const HomePage(),
          );
        },
      ),
    );
  }
}
