# Data Model: Daily Budget Planning and Projections

## Entities

### IncomeEntry / ExpenseEntry (Updates)
- **date**: `DateTime` (Mandatory, defaulted to 1st of the month for income if not provided)

### UserSettings
- **weekStartDay**: `int` (1-7, where 1 = Monday)
- **defaultProjectionHorizon**: `String` (e.g., "MONTH", "30_DAYS", "90_DAYS")

### ProjectionPoint
- **date**: `DateTime`
- **balance**: `double`
- **netChange**: `double` (Sum of income - sum of expenses for this point)
- **isWeekEnding**: `bool` (Used for weekly view)

## Relationships
- **UserSettings** is a singleton per user.
- **Transactions** are queried by a date range to generate a series of **ProjectionPoints**.

## Validation Rules
- **Income Date**: Cannot be null; system MUST provide a default if the user doesn't.
- **Projection Horizon**: Must be one of the pre-defined options.
- **Week Start Day**: Must be a valid day of the week (integer 1-7).

## State Transitions
1. **Initial**: User adds/edits a transaction with a date.
2. **Persistence**: Transaction saved to SQLite with its date.
3. **Calculation**: `ProjectionUseCase` is triggered (on view open or transaction change).
4. **Display**: UI renders table and graph from the list of `ProjectionPoint` objects.
