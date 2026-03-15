# Data Model: Potential Transactions Tracking

## Entities

### IncomeEntry / ExpenseEntry (Updated)
- `id`: String (UUID)
- `budgetId`: String
- `amount`: Double
- `categoryId`: String
- `description`: String
- `date`: DateTime
- `isPotential`: Boolean (New) - Defaults to `false`

### ProjectionPoint (Updated)
- `date`: DateTime
- `actualBalance`: Double (Existing `balance` will map here)
- `potentialBalance`: Double (New) - Sum of all actuals + all potential items up to this point
- `netChangeActual`: Double
- `netChangePotential`: Double
- `isWeekEnding`: Boolean
- `potentialInstances`: List<Entry> (Summary of potential items on this date)

## State Transitions (Potential Transaction)

| Initial State | Action | Final State |
|---------------|--------|-------------|
| Potential | Confirm | Actual (isPotential = false) |
| Potential | Delete | Deleted (Removed from DB) |
| Potential | Edit | Updated Potential (isPotential remains true) |

## Database Schema Updates

### Table: income_entries
- Add column `is_potential` (INTEGER, DEFAULT 0)

### Table: expense_entries
- Add column `is_potential` (INTEGER, DEFAULT 0)
