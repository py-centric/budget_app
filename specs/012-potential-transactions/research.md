# Research: Potential Transactions Tracking

## Dec-01: Visualization (fl_chart)
- **Decision**: Use a single `LineChart` with two `LineChartBarData` series.
- **Rationale**: Provides clear visual contrast between the "Guaranteed" (solid line) and "Potential" (dashed or lighter line) paths.
- **Alternatives considered**:
    - Two separate charts: Rejected as it makes direct point-by-point comparison difficult.
    - Stacked charts: Rejected because balance projections are absolute, not additive over time in a way that suits stacking.

## Dec-02: Projection Logic Integration
- **Decision**: Update `CalculateProjection` use case to return a single list of `ProjectionPoint` objects where each point contains both `actualBalance` and `potentialBalance`.
- **Rationale**: Ensures the projection is calculated in a single pass over the date range, maximizing performance.
- **Alternatives considered**:
    - Separate use cases for actual vs potential: Rejected due to redundant database queries and logic duplication.

## Dec-03: Storage Strategy (SQLite)
- **Decision**: Add an `is_potential` (INTEGER, 0 or 1) column to the existing `income_entries` and `expense_entries` tables.
- **Rationale**: 
    - Converting a potential transaction to "Actual" becomes a simple update operation (flip a flag).
    - Shared schema (amount, date, description, category) avoids table duplication.
- **Alternatives considered**:
    - Dedicated `potential_transactions` table: Rejected because it would require union queries or complex repository joins whenever a list of all items is needed.

## Dec-04: Migration Path
- **Decision**: Bump `AppConstants.databaseVersion` to 8 and implement `ALTER TABLE` in `LocalDatabase._onUpgrade`.
- **Rationale**: Ensures existing users get the new capability without data loss.
- **Alternatives considered**:
    - Manual migration script: SQLite FFI/sqflite handles this best via `onUpgrade`.
