# Research: Duplicate Budgets

## Decisions

### Decision 1: Data Model Expansion
- **What was chosen**: Introduce a `budgets` table and link entries via `budget_id`.
- **Rationale**: The user explicitly requested "multiple distinct budgets per month". The current implicit grouping by year/month cannot support this. A dedicated `budgets` table allows for naming and versioning plans within the same period.
- **Alternatives considered**: 
    - Using a "version" integer in existing tables: Messy and hard to manage metadata (like names).
    - Stay with single budget per month: Directly contradicts user requirement.

### Decision 2: Migration Path
- **What was chosen**: Create a "Default" budget for each existing unique period during migration.
- **Rationale**: Ensures backward compatibility with existing data. All current income, expenses, and goals will be automatically assigned to these default budget records.
- **Alternatives considered**: 
    - Wipe data: unacceptable.
    - Keep existing data detached: would break all existing summaries and views.

### Decision 3: Duplication Scope
- **What was chosen**: Full deep copy by default (structural and transactional).
- **Rationale**: User Story 2 explicitly requests a full mirror as the default. This includes shifting transaction dates to the target month while preserving the relative day-of-month.
- **Alternatives considered**: 
    - Template only: useful but not the requested default.

## Findings

1. **Navigation Impact**: The app currently identifies the "view" by `BudgetPeriod`. This must be updated to `Budget` ID. If no budget is selected for a period, the app should default to the most recently created one or a "Default" budget.
2. **Date Arithmetic**: Shifting dates from January 31st to February requires clamping to the last day of the target month.
3. **ID Uniqueness**: Using UUIDs for `budget_id` and all copied entries is critical to avoid primary key conflicts during duplication.

## Best Practices

### SQLite Duplication
- Perform the entire duplication (creating budget record + copying income + copying expenses + copying goals) within a single SQL **Transaction** to ensure atomicity.
- Use `INSERT INTO ... SELECT ...` for performance if possible, though mapping UUIDs might require row-by-page processing in Dart.

### UI/UX
- Use a "Duplicate" action in the budget settings or period selector.
- Provide a clear naming field for the new budget (defaulting to "Source Name (Copy)").
