# Data Model: Duplicate Budgets

## Entities

### Budget (New)
- **id**: `String` (UUID) - Primary Key
- **name**: `String` - User-defined label (e.g., "Main", "Alt Plan")
- **period_month**: `int` - 1-12
- **period_year**: `int` - YYYY
- **is_active**: `bool` - Current active selection for this period

### IncomeEntry / ExpenseEntry / BudgetGoal (Update)
- **budget_id**: `String` - Foreign Key to `Budgets.id` (Required)

## Relationships
- **Budget** (1) ↔ (N) **IncomeEntry**
- **Budget** (1) ↔ (N) **ExpenseEntry**
- **Budget** (1) ↔ (N) **BudgetGoal**

## Validation Rules
- **Name**: Cannot be empty.
- **Period**: Must be valid (1-12 month).
- **Uniqueness**: The combination of (name, period_month, period_year) should ideally be unique to avoid user confusion, but the system must allow multiple budgets per period.

## State Transitions
1. **Initial**: Budget created via duplication or fresh setup.
2. **Persistence**: All child entries saved with the new `budget_id`.
3. **Selection**: User switches between budgets in the UI → Updates `NavigationState`.
