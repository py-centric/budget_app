# Data Model: Recurring Transactions

## Entities

### RecurringTransaction (New)
- **id**: `String` (UUID)
- **type**: `String` ("INCOME" | "EXPENSE")
- **amount**: `double`
- **categoryId**: `String`
- **description**: `String`
- **startDate**: `DateTime`
- **endDate**: `DateTime?` (Optional)
- **interval**: `int` (e.g., 1, 2)
- **unit**: `String` ("DAYS" | "WEEKS" | "MONTHS" | "YEARS")

### RecurringOverride (New)
- **id**: `String` (UUID)
- **recurringTransactionId**: `String` (FK to RecurringTransaction)
- **targetDate**: `DateTime` (The specific occurrence date being modified)
- **newAmount**: `double?`
- **newDate**: `DateTime?`
- **isDeleted**: `bool` (Default: false)

### ProjectionPoint (Update)
- **recurringInstances**: `List<RecurringInstance>` (Virtual entity for display)

### RecurringInstance (Virtual)
- **templateId**: `String`
- **description**: `String`
- **amount**: `double`
- **isOverride**: `bool`

## Relationships
- **RecurringTransaction** (1) ↔ (N) **RecurringOverride**
- **RecurringTransaction** (1) ↔ (N) **ProjectionPoint** (via calculation)

## Validation Rules
- `interval` MUST be > 0.
- `startDate` MUST be <= `endDate` (if provided).
- `targetDate` in Override MUST be a valid occurrence date based on the template's start and frequency.

## State Transitions
1. **Creation**: User saves a recurring template.
2. **Override**: User edits a specific occurrence in the projection table → creates `RecurringOverride`.
3. **Calculation**: `ProjectionUseCase` scans templates → calculates dates → checks overrides → injects into total.
