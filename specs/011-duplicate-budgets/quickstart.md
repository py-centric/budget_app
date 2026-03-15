# Quickstart: Duplicate Budgets

## Implementation Order

### 1. Data Layer (Migration)
- Update `LocalDatabase` to version 6.
- Create `budgets` table.
- Add `budget_id` column to `income_entries`, `expense_entries`, and `budget_goals`.
- **MIGRATE**: Create a default budget for all existing month/year combinations and link existing data.

### 2. Domain Layer
- Create `Budget` entity.
- Create `DuplicateBudget` use case.
- Implement date-shifting logic for transactions.

### 3. Presentation Layer (Navigation)
- Update `NavigationBloc` to track `activeBudget` alongside `currentPeriod`.
- Add a "Budget Selector" to the home page or sidebar if multiple budgets exist for a month.

### 4. UI - Duplication Flow
- Implement "Duplicate Budget" dialog (Name, Scope, Target Month).
- Integrate the use case into the `BudgetBloc`.

## Success Checklist
- [ ] Existing data is correctly migrated to a "Default" budget record.
- [ ] Users can create a second budget for the same month.
- [ ] Duplicating a budget to a different month shifts transaction dates correctly.
- [ ] Switching between budgets in the same month updates the summary and lists instantly.
