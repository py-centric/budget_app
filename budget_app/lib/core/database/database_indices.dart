class DatabaseIndices {
  static const List<String> allIndices = [
    idxIncomePeriod,
    idxIncomeDate,
    idxIncomeBudget,
    idxIncomeCategory,
    idxIncomeAccount,
    idxExpensePeriod,
    idxExpenseDate,
    idxExpenseBudget,
    idxExpenseCategory,
    idxExpenseAccount,
    idxBudgetGoalsPeriod,
    idxBudgetGoalsBudget,
    idxRecurringOverridesTemplate,
    idxTransfersFrom,
    idxTransfersTo,
    idxCategoryLimitsBudget,
    idxCategoryLimitsCategory,
    idxSavingsContributionsGoal,
    idxBillRemindersTransaction,
    idxBillRemindersDueDate,
    idxTransactionSplitsParent,
    idxTransactionSplitsCategory,
    idxTagsName,
    idxTransactionTagsTag,
    idxTransactionTagsTransaction,
    idxAttachmentsTransaction,
    idxTemplateAllocationsTemplate,
    idxNetWorthDate,
    idxAccountTransactionsAcc,
  ];

  static const String idxIncomePeriod =
      'CREATE INDEX IF NOT EXISTS idx_income_period ON income_entries (period_year, period_month)';
  static const String idxIncomeDate =
      'CREATE INDEX IF NOT EXISTS idx_income_date ON income_entries (date)';
  static const String idxIncomeBudget =
      'CREATE INDEX IF NOT EXISTS idx_income_budget ON income_entries (budget_id)';
  static const String idxIncomeCategory =
      'CREATE INDEX IF NOT EXISTS idx_income_category ON income_entries (category_id)';
  static const String idxIncomeAccount =
      'CREATE INDEX IF NOT EXISTS idx_income_account ON income_entries (account_id)';

  static const String idxExpensePeriod =
      'CREATE INDEX IF NOT EXISTS idx_expense_period ON expense_entries (period_year, period_month)';
  static const String idxExpenseDate =
      'CREATE INDEX IF NOT EXISTS idx_expense_date ON expense_entries (date)';
  static const String idxExpenseBudget =
      'CREATE INDEX IF NOT EXISTS idx_expense_budget ON expense_entries (budget_id)';
  static const String idxExpenseCategory =
      'CREATE INDEX IF NOT EXISTS idx_expense_category ON expense_entries (category_id)';
  static const String idxExpenseAccount =
      'CREATE INDEX IF NOT EXISTS idx_expense_account ON expense_entries (account_id)';

  static const String idxBudgetGoalsPeriod =
      'CREATE INDEX IF NOT EXISTS idx_budget_goals_period ON budget_goals (period_year, period_month)';
  static const String idxBudgetGoalsBudget =
      'CREATE INDEX IF NOT EXISTS idx_budget_goals_budget ON budget_goals (budget_id)';

  static const String idxRecurringOverridesTemplate =
      'CREATE INDEX IF NOT EXISTS idx_recurring_overrides_template ON recurring_overrides (recurring_transaction_id)';

  static const String idxTransfersFrom =
      'CREATE INDEX IF NOT EXISTS idx_transfers_from ON transfers (from_account_id)';
  static const String idxTransfersTo =
      'CREATE INDEX IF NOT EXISTS idx_transfers_to ON transfers (to_account_id)';

  static const String idxCategoryLimitsBudget =
      'CREATE INDEX IF NOT EXISTS idx_category_limits_budget ON category_limits(budget_id)';
  static const String idxCategoryLimitsCategory =
      'CREATE INDEX IF NOT EXISTS idx_category_limits_category ON category_limits(category_id)';

  static const String idxSavingsContributionsGoal =
      'CREATE INDEX IF NOT EXISTS idx_savings_contributions_goal ON savings_contributions(goal_id)';

  static const String idxBillRemindersTransaction =
      'CREATE INDEX IF NOT EXISTS idx_bill_reminders_transaction ON bill_reminders(recurring_transaction_id)';
  static const String idxBillRemindersDueDate =
      'CREATE INDEX IF NOT EXISTS idx_bill_reminders_due_date ON bill_reminders(due_date)';

  static const String idxTransactionSplitsParent =
      'CREATE INDEX IF NOT EXISTS idx_transaction_splits_parent ON transaction_splits(parent_transaction_id)';
  static const String idxTransactionSplitsCategory =
      'CREATE INDEX IF NOT EXISTS idx_transaction_splits_category ON transaction_splits(category_id)';

  static const String idxTagsName =
      'CREATE INDEX IF NOT EXISTS idx_tags_name ON tags(name)';
  static const String idxTransactionTagsTag =
      'CREATE INDEX IF NOT EXISTS idx_transaction_tags_tag ON transaction_tags(tag_id)';
  static const String idxTransactionTagsTransaction =
      'CREATE INDEX IF NOT EXISTS idx_transaction_tags_transaction ON transaction_tags(transaction_id, transaction_type)';

  static const String idxAttachmentsTransaction =
      'CREATE INDEX IF NOT EXISTS idx_attachments_transaction ON attachments(transaction_id, transaction_type)';

  static const String idxTemplateAllocationsTemplate =
      'CREATE INDEX IF NOT EXISTS idx_template_allocations_template ON budget_template_allocations(template_id)';

  static const String idxNetWorthDate =
      'CREATE INDEX IF NOT EXISTS idx_net_worth_date ON net_worth_snapshots(date)';

  static const String idxAccountTransactionsAcc =
      'CREATE INDEX IF NOT EXISTS idx_account_transactions_acc ON account_transactions(account_id)';
}
