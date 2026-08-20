import 'database_tables_core.dart';
import 'database_tables_advanced.dart';

class DatabaseTables {
  static const List<String> allTables = [
    ...DatabaseTablesCore.tables,
    ...DatabaseTablesAdvanced.tables,
  ];

  // Core tables
  static const String budgets = DatabaseTablesCore.budgets;
  static const String incomeEntries = DatabaseTablesCore.incomeEntries;
  static const String expenseEntries = DatabaseTablesCore.expenseEntries;
  static const String budgetGoals = DatabaseTablesCore.budgetGoals;
  static const String categories = DatabaseTablesCore.categories;
  static const String recurringTransactions = DatabaseTablesCore.recurringTransactions;
  static const String recurringOverrides = DatabaseTablesCore.recurringOverrides;
  static const String savedCalculations = DatabaseTablesCore.savedCalculations;
  static const String emergencyExpenses = DatabaseTablesCore.emergencyExpenses;
  static const String metadata = DatabaseTablesCore.metadata;
  static const String companyProfiles = DatabaseTablesCore.companyProfiles;
  static const String invoices = DatabaseTablesCore.invoices;
  static const String clients = DatabaseTablesCore.clients;
  static const String invoiceItems = DatabaseTablesCore.invoiceItems;
  static const String invoicePayments = DatabaseTablesCore.invoicePayments;
  static const String receivedInvoices = DatabaseTablesCore.receivedInvoices;

  // Advanced tables
  static const String accounts = DatabaseTablesAdvanced.accounts;
  static const String transfers = DatabaseTablesAdvanced.transfers;
  static const String categoryLimits = DatabaseTablesAdvanced.categoryLimits;
  static const String savingsGoals = DatabaseTablesAdvanced.savingsGoals;
  static const String savingsContributions = DatabaseTablesAdvanced.savingsContributions;
  static const String billReminders = DatabaseTablesAdvanced.billReminders;
  static const String transactionSplits = DatabaseTablesAdvanced.transactionSplits;
  static const String tags = DatabaseTablesAdvanced.tags;
  static const String transactionTags = DatabaseTablesAdvanced.transactionTags;
  static const String attachments = DatabaseTablesAdvanced.attachments;
  static const String budgetTemplates = DatabaseTablesAdvanced.budgetTemplates;
  static const String budgetTemplateAllocations = DatabaseTablesAdvanced.budgetTemplateAllocations;
  static const String netWorthSnapshots = DatabaseTablesAdvanced.netWorthSnapshots;
  static const String creditCards = DatabaseTablesAdvanced.creditCards;
  static const String investments = DatabaseTablesAdvanced.investments;
  static const String loanAccounts = DatabaseTablesAdvanced.loanAccounts;
  static const String savingsAccounts = DatabaseTablesAdvanced.savingsAccounts;
  static const String investmentPortfolios = DatabaseTablesAdvanced.investmentPortfolios;
  static const String accountTransactions = DatabaseTablesAdvanced.accountTransactions;
}
