# Research: Recurring Transactions

## Decisions

### Decision 1: Recurrence Calculation Logic
- **What was chosen**: Custom calculation logic.
- **Rationale**: While the `rrule` package is powerful, our requirements (flexible interval + unit) are straightforward enough to implement with basic `DateTime` arithmetic. This avoids an extra dependency and keeps the "Offline-First" and "License Compliance" principles easily manageable.
- **Alternatives considered**: `rrule` package (rejected for overkill).

### Decision 2: Override Storage Strategy
- **What was chosen**: Separate `recurring_overrides` table.
- **Rationale**: Storing overrides in a separate table with a `recurring_transaction_id` and `target_date` allows us to efficiently query for deviations when generating projections. It keeps the main template table clean.
- **Alternatives considered**: Storing overrides as a JSON blob in the main table (harder to query/update individual occurrences).

### Decision 3: Integration with Projections
- **What was chosen**: Update `ProjectionUseCase` to inject recurring instances into the daily calculation loop.
- **Rationale**: The `ProjectionUseCase` already iterates through days. By checking for recurring occurrences (and their overrides) during this loop, we can accurately update the running balance.
- **Alternatives considered**: Pre-generating recurring "shadow" transactions in the main transaction table (complex to sync when templates change).

## Findings

1. **Flexible Frequencies**: Implementing "Every X [Unit]" requires a base date (`startDate`) and calculating multiples of the interval. For months/years, we must handle the "last day of month" edge case (e.g., Feb 28th vs Jan 31st).
2. **SQLite NOT NULL constraints**: Existing transaction tables have NOT NULL constraints on some fields. Recurring templates and overrides must be carefully mapped to avoid crashes.
3. **UI for Recurrence**: A dedicated "Recurring" toggle in the transaction dialog followed by a row of inputs (Interval number, Unit dropdown) is the standard mobile pattern.

## Best Practices

### Data Integrity
- Ensure `recurring_transaction_id` in the overrides table has a CASCADE DELETE constraint.
- Validate `startDate` is before `endDate` (if provided).

### Performance
- Cache active recurring templates in memory during projection calculation to avoid repeated DB hits inside the day-iteration loop.
- Use a single query to fetch all overrides for the projection horizon.
