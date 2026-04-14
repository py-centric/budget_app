import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:path_provider/path_provider.dart';

import 'core/theme/app_theme.dart';
import 'features/app_lock/data/repositories/app_lock_repository_impl.dart';
import 'features/app_lock/presentation/bloc/app_lock_bloc.dart';
import 'features/app_lock/presentation/bloc/app_lock_event.dart';
import 'features/app_lock/presentation/bloc/app_lock_state.dart';
import 'features/app_lock/presentation/pages/lock_screen_page.dart';
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
import 'features/accounts/domain/repositories/account_repository.dart';
import 'features/accounts/data/repositories/account_repository_impl.dart';
import 'features/accounts/presentation/bloc/account_bloc.dart';
import 'features/accounts/presentation/bloc/account_event.dart';
import 'features/budget/domain/repositories/category_limit_repository.dart';
import 'features/budget/data/repositories/category_limit_repository_impl.dart';
import 'features/budget/presentation/bloc/category_limit_bloc.dart';
import 'features/savings/domain/repositories/savings_repository.dart';
import 'features/savings/data/repositories/savings_repository_impl.dart';
import 'features/savings/presentation/bloc/savings_bloc.dart';
import 'features/savings/presentation/bloc/savings_event.dart';
import 'features/reminders/domain/repositories/reminder_repository.dart';
import 'features/reminders/data/repositories/reminder_repository_impl.dart';
import 'features/reminders/presentation/bloc/reminder_bloc.dart';
import 'features/reminders/presentation/bloc/reminder_event.dart';
import 'core/notifications/notification_service.dart';
import 'features/budget/presentation/bloc/budget_comparison_bloc.dart';
import 'features/calendar/presentation/bloc/calendar_bloc.dart';

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
  final accountRepository = AccountRepositoryImpl(localDatabase);
  final categoryLimitRepository = CategoryLimitRepositoryImpl(localDatabase);
  final savingsRepository = SavingsRepositoryImpl(localDatabase);
  final reminderRepository = ReminderRepositoryImpl(localDatabase);
  final notificationService = NotificationService();
  await notificationService.initialize();

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
        RepositoryProvider<AppLockRepository>(
          create: (context) =>
              AppLockRepository(authService: AuthServiceImpl()),
        ),
        RepositoryProvider<AccountRepository>(
          create: (context) => accountRepository,
        ),
        RepositoryProvider<CategoryLimitRepository>(
          create: (context) => categoryLimitRepository,
        ),
        RepositoryProvider<SavingsRepository>(
          create: (context) => savingsRepository,
        ),
        RepositoryProvider<ReminderRepository>(
          create: (context) => reminderRepository,
        ),
      ],
      child: BudgetApp(
        repository: repository,
        recurringRepository: recurringRepository,
        financialRepository: financialRepository,
        emergencyFundRepository: emergencyFundRepository,
        businessRepository: businessRepository,
        notificationService: notificationService,
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
  final NotificationService notificationService;

  const BudgetApp({
    super.key,
    required this.repository,
    required this.recurringRepository,
    required this.financialRepository,
    required this.emergencyFundRepository,
    required this.businessRepository,
    required this.notificationService,
  });

  @override
  Widget build(BuildContext context) {
    final addIncomeUseCase = AddIncome(repository);
    final addExpenseUseCase = AddExpense(repository);
    final calculateSummaryUseCase = CalculateSummary(
      repository,
      recurringRepository: recurringRepository,
    );
    final getAvailablePeriodsUseCase = GetAvailablePeriods(repository);
    final deleteEntryUseCase = DeleteEntry(repository);
    final updateEntryUseCase = UpdateEntry(repository);
    final saveRecurringTransactionUseCase = SaveRecurringTransaction(
      recurringRepository,
    );
    final applyRecurringOverrideUseCase = ApplyRecurringOverride(
      recurringRepository,
    );
    final duplicateBudgetUseCase = DuplicateBudget(repository);
    final confirmPotentialTransactionUseCase = ConfirmPotentialTransaction(
      repository,
    );

    final addCategoryUseCase = AddCategory(repository);
    final deleteCategoryUseCase = DeleteCategory(repository);
    final reassignAndDeleteCategoryUseCase = ReassignAndDeleteCategory(
      repository,
    );
    final calculateProjectionUseCase = CalculateProjection(
      repository,
      recurringRepository,
    );

    final calculateNetWorthUseCase = CalculateNetWorth();
    final calculateAmortizationUseCase = CalculateAmortization();
    final calculateCompoundInterestUseCase = CalculateCompoundInterest();

    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) =>
              AppLockBloc(repository: context.read<AppLockRepository>())
                ..add(AppLockLoadSettings()),
        ),
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
            confirmPotentialTransactionUseCase:
                confirmPotentialTransactionUseCase,
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
          create: (_) =>
              EmergencyFundBloc(emergencyFundRepository)
                ..add(LoadEmergencyFund()),
        ),
        BlocProvider(
          create: (context) =>
              AccountBloc(context.read<AccountRepository>())
                ..add(LoadAccounts()),
        ),
        BlocProvider(
          create: (context) => CategoryLimitBloc(
            repository: context.read<CategoryLimitRepository>(),
            budgetRepository: repository,
          ),
        ),
        BlocProvider(
          create: (context) =>
              SavingsBloc(repository: context.read<SavingsRepository>())
                ..add(LoadSavingsGoals()),
        ),
        BlocProvider(
          create: (context) => ReminderBloc(
            repository: context.read<ReminderRepository>(),
            recurringRepository: recurringRepository,
            notificationService: notificationService,
          )..add(LoadReminders()),
        ),
        BlocProvider(
          create: (context) => BudgetComparisonBloc(
            budgetRepository: repository,
            categoryLimitRepository: context.read<CategoryLimitRepository>(),
          ),
        ),
        BlocProvider(
          create: (context) => CalendarBloc(budgetRepository: repository),
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

          return BlocBuilder<AppLockBloc, AppLockState>(
            builder: (context, appLockState) {
              // Show lock screen ONLY if lock is actually enabled and user hasn't authenticated yet
              // Don't show lock screen if:
              // - Lock is not enabled
              // - Status is loaded (initial load complete, lock not enabled)
              // - Status is initial (still loading)
              // - Status is authenticated
              final shouldShowLock =
                  appLockState.settings.isEnabled &&
                  appLockState.status != AppLockStatus.authenticated &&
                  appLockState.status != AppLockStatus.loaded &&
                  appLockState.status != AppLockStatus.initial &&
                  appLockState.status != AppLockStatus.loading;

              if (shouldShowLock) {
                return MaterialApp(
                  title: 'Budget App',
                  debugShowCheckedModeBanner: false,
                  theme: AppTheme.lightTheme,
                  darkTheme: AppTheme.darkTheme,
                  themeMode: mode,
                  home: LockScreenPage(
                    onUnlocked: () {
                      context.read<AppLockBloc>().add(AppLockLoadSettings());
                    },
                  ),
                );
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
          );
        },
      ),
    );
  }
}
