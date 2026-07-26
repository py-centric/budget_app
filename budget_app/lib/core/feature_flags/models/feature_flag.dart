enum FeatureFlag {
  // Personal Features
  personalBudgets,
  emergencyFund,
  debtPayoff,
  personalLoans,
  savingsGoals,

  // Business Features
  invoicingPayables,
  bankReconciliation,
  taxEstimation,
  billSplitting,

  // Universal Features
  multiBankAccounts,
  attachments,
  backupRestore,
  dataExport,
  financialCalculators,
  settingsAndTheme;

  String get key => name;
}
