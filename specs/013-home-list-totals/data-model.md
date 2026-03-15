# Data Model: Home List Totals and Potential Balances

## Entities

### BudgetSummary (Updated)
The `BudgetSummary` entity (defined within `calculate_summary.dart`) will be expanded to include specific totals for headers.

- `totalIncome`: Actual Total income sum.
- `totalExpenses`: Actual Total expense sum.
- `balance`: Actual Total balance.
- `totalPotentialIncome`: Sum of actual + potential income (New).
- `totalPotentialExpenses`: Sum of actual + potential expenses (New).
- `incomeEntries`: List of all income entries.
- `expenseEntries`: List of all expense entries.
- `missedPotentialCount`: Count of past-due potential items.

## Logic Rules

| Field | Calculation |
|-------|-------------|
| `totalIncome` | `incomeEntries.where((e) => !e.isPotential).sum()` |
| `totalPotentialIncome` | `incomeEntries.sum()` |
| `totalExpenses` | `expenseEntries.where((e) => !e.isPotential).sum()` |
| `totalPotentialExpenses` | `expenseEntries.sum()` |
