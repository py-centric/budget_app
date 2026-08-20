import 'package:flutter_bloc/flutter_bloc.dart';

// App Lock
import '../../features/app_lock/data/repositories/app_lock_repository_impl.dart';
import '../../features/app_lock/presentation/bloc/app_lock_bloc.dart';
import '../../features/app_lock/presentation/bloc/app_lock_event.dart';

// Budget
import '../../features/budget/data/datasources/local_database.dart';
import '../../features/budget/data/repositories/budget_repository_impl.dart';
import '../../features/budget/data/repositories/recurring_repository_impl.dart';
import '../../features/budget/data/repositories/category_limit_repository_impl.dart';
import '../../features/budget/domain/repositories/budget_repository.dart';
import '../../features/budget/domain/repositories/recurring_repository.dart';
import '../../features/budget/domain/repositories/category_limit_repository.dart';
import '../../features/budget/domain/usecases/add_income.dart';
import '../../features/budget/domain/usecases/add_expense.dart';
import '../../features/budget/domain/usecases/calculate_summary.dart';
import '../../features/budget/domain/usecases/get_available_periods.dart';
import '../../features/budget/domain/usecases/delete_entry.dart';
import '../../features/budget/domain/usecases/update_entry.dart';
import '../../features/budget/domain/usecases/manage_categories.dart';
import '../../features/budget/domain/usecases/calculate_projection.dart';
import '../../features/budget/domain/usecases/save_recurring_transaction.dart';
import '../../features/budget/domain/usecases/apply_recurring_override.dart';
import '../../features/budget/domain/usecases/duplicate_budget.dart';
import '../../features/budget/domain/usecases/confirm_potential_transaction.dart';
import '../../features/budget/presentation/bloc/budget_bloc.dart';
import '../../features/budget/presentation/bloc/navigation_bloc.dart';
import '../../features/budget/presentation/bloc/category_bloc.dart';
import '../../features/budget/presentation/bloc/projection_bloc.dart';
import '../../features/budget/presentation/bloc/projection_event.dart';
import '../../features/budget/presentation/bloc/category_limit_bloc.dart';
import '../../features/budget/presentation/bloc/budget_comparison_bloc.dart';

// Financial Tools
import '../../features/financial_tools/domain/repositories/financial_repository.dart';
import '../../features/financial_tools/data/repositories/financial_repository_impl.dart';
import '../../features/financial_tools/domain/usecases/calculate_net_worth.dart';
import '../../features/financial_tools/domain/usecases/calculate_amortization.dart';
import '../../features/financial_tools/domain/usecases/calculate_compound_interest.dart';
import '../../features/financial_tools/presentation/bloc/financial_bloc.dart';

// Settings
import '../../features/settings/presentation/bloc/settings_bloc.dart';

// Emergency Fund
import '../../features/emergency_fund/domain/repositories/emergency_fund_repository.dart';
import '../../features/emergency_fund/data/repositories/emergency_fund_repository_impl.dart';
import '../../features/emergency_fund/presentation/bloc/emergency_fund_bloc.dart';
import '../../features/emergency_fund/presentation/bloc/emergency_fund_event.dart';

// Business Tools
import '../../features/business_tools/domain/repositories/business_repository.dart';
import '../../features/business_tools/data/repositories/business_repository_impl.dart';
import '../../features/business_tools/presentation/bloc/business_bloc.dart';
import '../../features/business_tools/presentation/bloc/business_event.dart';

// Accounts
import '../../features/accounts/domain/repositories/account_repository.dart';
import '../../features/accounts/data/repositories/account_repository_impl.dart';
import '../../features/accounts/presentation/bloc/account_bloc.dart';
import '../../features/accounts/presentation/bloc/account_event.dart';

// Savings
import '../../features/savings/domain/repositories/savings_repository.dart';
import '../../features/savings/data/repositories/savings_repository_impl.dart';
import '../../features/savings/presentation/bloc/savings_bloc.dart';
import '../../features/savings/presentation/bloc/savings_event.dart';

// Reminders
import '../../features/reminders/domain/repositories/reminder_repository.dart';
import '../../features/reminders/data/repositories/reminder_repository_impl.dart';
import '../../features/reminders/presentation/bloc/reminder_bloc.dart';
import '../../features/reminders/presentation/bloc/reminder_event.dart';

// Notifications
import '../notifications/notification_service.dart';

// Calendar
import '../../features/budget/domain/usecases/get_calendar_data.dart';
import '../../features/calendar/presentation/bloc/calendar_bloc.dart';

// Tags
import '../../features/tags/domain/repositories/tags_repository.dart';
import '../../features/tags/data/repositories/tags_repository_impl.dart';
import '../../features/tags/presentation/bloc/tags_bloc.dart';
import '../../features/tags/presentation/bloc/tags_event.dart';

// Attachments
import '../../features/attachments/domain/repositories/attachments_repository.dart';
import '../../features/attachments/data/repositories/attachments_repository_impl.dart';
import '../../features/attachments/presentation/bloc/attachments_bloc.dart';

// Budget Templates
import '../../features/budget_templates/domain/repositories/budget_templates_repository.dart';
import '../../features/budget_templates/data/repositories/budget_templates_repository_impl.dart';
import '../../features/budget_templates/presentation/bloc/budget_templates_bloc.dart';
import '../../features/budget_templates/presentation/bloc/budget_templates_event.dart';

// Feature Flags
import '../feature_flags/presentation/bloc/feature_flags_bloc.dart';
import '../feature_flags/services/feature_gate_service.dart';
import '../feature_flags/services/feature_gate_service_impl.dart';


// Financial Health
import '../../features/financial_health/domain/usecases/calculate_financial_health.dart';
import '../../features/financial_health/presentation/bloc/financial_health_bloc.dart';

// Net Worth
import '../../features/net_worth/domain/repositories/net_worth_repository.dart';
import '../../features/net_worth/data/repositories/net_worth_repository_impl.dart';
import '../../features/net_worth/presentation/bloc/net_worth_bloc.dart';
import '../../features/net_worth/presentation/bloc/net_worth_event.dart';

/// Holds all lazily-created repository and use-case instances.
class AppModule {
  // Repositories
  late final BudgetRepository budgetRepository;
  late final RecurringRepository recurringRepository;
  late final FinancialRepository financialRepository;
  late final EmergencyFundRepository emergencyFundRepository;
  late final BusinessRepository businessRepository;
  late final AccountRepository accountRepository;
  late final CategoryLimitRepository categoryLimitRepository;
  late final SavingsRepository savingsRepository;
  late final ReminderRepository reminderRepository;
  late final TagsRepository tagsRepository;
  late final AttachmentsRepository attachmentsRepository;
  late final BudgetTemplatesRepository budgetTemplatesRepository;
  late final NetWorthRepository netWorthRepository;

  // Use cases
  late final AddIncome addIncomeUseCase;
  late final AddExpense addExpenseUseCase;
  late final CalculateSummary calculateSummaryUseCase;
  late final GetAvailablePeriods getAvailablePeriodsUseCase;
  late final DeleteEntry deleteEntryUseCase;
  late final UpdateEntry updateEntryUseCase;
  late final AddCategory addCategoryUseCase;
  late final DeleteCategory deleteCategoryUseCase;
  late final ReassignAndDeleteCategory reassignAndDeleteCategoryUseCase;
  late final CalculateProjection calculateProjectionUseCase;
  late final SaveRecurringTransaction saveRecurringTransactionUseCase;
  late final ApplyRecurringOverride applyRecurringOverrideUseCase;
  late final DuplicateBudget duplicateBudgetUseCase;
  late final ConfirmPotentialTransaction confirmPotentialTransactionUseCase;
  late final CalculateNetWorth calculateNetWorthUseCase;
  late final CalculateAmortization calculateAmortizationUseCase;
  late final CalculateCompoundInterest calculateCompoundInterestUseCase;
  late final CalculateFinancialHealth calculateFinancialHealthUseCase;

  // Services
  late final NotificationService notificationService;
  late final FeatureFlagsBloc featureFlagsBloc;
  late final FeatureGateService featureGateService;

  Future<void> init() async {
    // Feature Flags BLoC & Service
    featureFlagsBloc = FeatureFlagsBloc();
    featureGateService = FeatureGateServiceImpl(featureFlagsBloc);

    // Initialize database
    await LocalDatabase.initialize();
    final localDatabase = LocalDatabase.instance;


    // Repositories
    budgetRepository = BudgetRepositoryImpl(localDatabase);
    recurringRepository = RecurringRepositoryImpl(localDatabase);
    financialRepository = FinancialRepositoryImpl(localDatabase);
    emergencyFundRepository = EmergencyFundRepositoryImpl(localDatabase);
    businessRepository = BusinessRepositoryImpl(localDatabase);
    accountRepository = AccountRepositoryImpl(localDatabase);
    categoryLimitRepository = CategoryLimitRepositoryImpl(localDatabase);
    savingsRepository = SavingsRepositoryImpl(localDatabase);
    reminderRepository = ReminderRepositoryImpl(localDatabase);
    tagsRepository = TagsRepositoryImpl(localDatabase);
    attachmentsRepository = AttachmentsRepositoryImpl(localDatabase);
    budgetTemplatesRepository = BudgetTemplatesRepositoryImpl(localDatabase);
    netWorthRepository = NetWorthRepositoryImpl(localDatabase);

    // Use cases
    addIncomeUseCase = AddIncome(budgetRepository);
    addExpenseUseCase = AddExpense(budgetRepository);
    calculateSummaryUseCase = CalculateSummary(
      budgetRepository,
      recurringRepository: recurringRepository,
    );
    getAvailablePeriodsUseCase = GetAvailablePeriods(budgetRepository);
    deleteEntryUseCase = DeleteEntry(budgetRepository);
    updateEntryUseCase = UpdateEntry(budgetRepository);
    saveRecurringTransactionUseCase = SaveRecurringTransaction(
      recurringRepository,
    );
    applyRecurringOverrideUseCase = ApplyRecurringOverride(recurringRepository);
    duplicateBudgetUseCase = DuplicateBudget(budgetRepository);
    confirmPotentialTransactionUseCase = ConfirmPotentialTransaction(
      budgetRepository,
    );
    addCategoryUseCase = AddCategory(budgetRepository);
    deleteCategoryUseCase = DeleteCategory(budgetRepository);
    reassignAndDeleteCategoryUseCase = ReassignAndDeleteCategory(
      budgetRepository,
    );
    calculateProjectionUseCase = CalculateProjection(
      budgetRepository,
      recurringRepository,
    );
    calculateNetWorthUseCase = CalculateNetWorth();
    calculateAmortizationUseCase = CalculateAmortization();
    calculateCompoundInterestUseCase = CalculateCompoundInterest();
    calculateFinancialHealthUseCase = const CalculateFinancialHealth();

    // Services
    notificationService = NotificationService();
    await notificationService.initialize();
  }

  /// Returns the list of [RepositoryProvider]s that wrap the repositories.
  List<RepositoryProvider> get repositoryProviders => [
    RepositoryProvider<RecurringRepository>(create: (_) => recurringRepository),
    RepositoryProvider<EmergencyFundRepository>(
      create: (_) => emergencyFundRepository,
    ),
    RepositoryProvider<BusinessRepository>(create: (_) => businessRepository),
    RepositoryProvider<AppLockRepository>(
      create: (_) => AppLockRepository(authService: AuthServiceImpl()),
    ),
    RepositoryProvider<AccountRepository>(create: (_) => accountRepository),
    RepositoryProvider<CategoryLimitRepository>(
      create: (_) => categoryLimitRepository,
    ),
    RepositoryProvider<SavingsRepository>(create: (_) => savingsRepository),
    RepositoryProvider<ReminderRepository>(create: (_) => reminderRepository),
    RepositoryProvider<TagsRepository>(create: (_) => tagsRepository),
    RepositoryProvider<AttachmentsRepository>(create: (_) => attachmentsRepository),
    RepositoryProvider<BudgetTemplatesRepository>(create: (_) => budgetTemplatesRepository),
    RepositoryProvider<NetWorthRepository>(create: (_) => netWorthRepository),
    RepositoryProvider<FeatureGateService>(create: (_) => featureGateService),
  ];

  /// Returns the list of [BlocProvider]s for the app.
  List<BlocProvider> get blocProviders => [
    BlocProvider<FeatureFlagsBloc>(
      create: (_) => featureFlagsBloc,
      lazy: false,
    ),
    BlocProvider<SettingsBloc>(
      create: (_) => SettingsBloc()..add(const InitializeSettingsEvent()),
      lazy: false,
    ),
    BlocProvider<AppLockBloc>(
      create: (context) =>
          AppLockBloc(repository: context.read<AppLockRepository>())
            ..add(AppLockLoadSettings()),
    ),
    BlocProvider<FinancialBloc>(
      create: (_) => FinancialBloc(
        repository: financialRepository,
        calculateNetWorth: calculateNetWorthUseCase,
        calculateAmortization: calculateAmortizationUseCase,
        calculateCompoundInterest: calculateCompoundInterestUseCase,
      ),
    ),
    BlocProvider<NavigationBloc>(
      create: (_) => NavigationBloc(
        getAvailablePeriodsUseCase: getAvailablePeriodsUseCase,
        budgetRepository: budgetRepository,
      )..add(const LoadAvailablePeriods()),
    ),
    BlocProvider<BudgetBloc>(
      create: (_) => BudgetBloc(
        repository: budgetRepository,
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
    BlocProvider<CategoryBloc>(
      create: (_) => CategoryBloc(
        repository: budgetRepository,
        addCategoryUseCase: addCategoryUseCase,
        deleteCategoryUseCase: deleteCategoryUseCase,
        reassignAndDeleteCategoryUseCase: reassignAndDeleteCategoryUseCase,
      )..add(LoadCategories()),
    ),
    BlocProvider<ProjectionBloc>(
      create: (_) => ProjectionBloc(
        calculateProjection: calculateProjectionUseCase,
        applyRecurringOverride: applyRecurringOverrideUseCase,
        emergencyFundRepository: emergencyFundRepository,
      )..add(const LoadProjection()),
    ),
    BlocProvider<EmergencyFundBloc>(
      create: (_) =>
          EmergencyFundBloc(emergencyFundRepository)..add(LoadEmergencyFund()),
    ),
    BlocProvider<AccountBloc>(
      create: (context) =>
          AccountBloc(context.read<AccountRepository>())..add(LoadAccounts()),
    ),
    BlocProvider<CategoryLimitBloc>(
      create: (context) => CategoryLimitBloc(
        repository: context.read<CategoryLimitRepository>(),
        budgetRepository: budgetRepository,
      ),
    ),
    BlocProvider<SavingsBloc>(
      create: (context) =>
          SavingsBloc(repository: context.read<SavingsRepository>())
            ..add(LoadSavingsGoals()),
    ),
    BlocProvider<ReminderBloc>(
      create: (context) => ReminderBloc(
        repository: context.read<ReminderRepository>(),
        recurringRepository: recurringRepository,
        notificationService: notificationService,
      )..add(LoadReminders()),
    ),
    BlocProvider<BudgetComparisonBloc>(
      create: (context) => BudgetComparisonBloc(
        budgetRepository: budgetRepository,
        categoryLimitRepository: context.read<CategoryLimitRepository>(),
      ),
    ),
    BlocProvider<CalendarBloc>(
      create: (context) =>
          CalendarBloc(getCalendarData: GetCalendarData(budgetRepository)),
    ),
    BlocProvider<BusinessBloc>(
      create: (_) =>
          BusinessBloc(businessRepository)..add(LoadBusinessData()),
    ),
    BlocProvider<TagsBloc>(
      create: (_) =>
          TagsBloc(repository: tagsRepository)..add(const LoadAllTags()),
    ),
    BlocProvider<AttachmentsBloc>(
      create: (_) => AttachmentsBloc(repository: attachmentsRepository),
    ),
    BlocProvider<BudgetTemplatesBloc>(
      create: (_) => BudgetTemplatesBloc(repository: budgetTemplatesRepository)
        ..add(const LoadAllTemplates()),
    ),
    BlocProvider<FinancialHealthBloc>(
      create: (_) => FinancialHealthBloc(calculateHealth: calculateFinancialHealthUseCase),
    ),
    BlocProvider<NetWorthBloc>(
      create: (_) => NetWorthBloc(repository: netWorthRepository)
        ..add(const LoadNetWorthSnapshots()),
    ),
  ];
}
