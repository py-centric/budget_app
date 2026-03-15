# Research: Emergency Fund Calculator

## Decision: Automatic Living Expenses Algorithm
**Decision**: Use the average of the last 3 full months of actual spending.
**Rationale**: 3 months provides a balanced view that accounts for recent changes in spending habits without being skewed by a single outlier month. It's more realistic than all-time data or the current month's budget which might not reflect real behavior. If the user has < 3 months of history, the system will fall back to the average of all available complete months to ensure a calculation is always provided.
**Alternatives considered**: 
- All-time average (too slow to react to lifestyle changes).
- Current budget (often aspirational and doesn't reflect actual spending).

## Decision: Exposing Global Target
**Decision**: Store the global target in a dedicated `EmergencyFundRepository` and have other Blocs (like Projections) listen to its stream.
**Rationale**: Keeps concerns separated. The `EmergencyFundRepository` is the source of truth for all things related to this tool. It avoids cluttering `SettingsRepository`.
**Alternatives considered**:
- `SettingsRepository` (feels like a UI configuration, but the target is a financial data point).
- Direct Database Access (violates Clean Architecture; we want Blocs to interact with Repositories).

## Decision: Persistence Mechanism
**Decision**: A single SQLite table `emergency_expenses` with a boolean flag `is_suggestion`. The "Global Target" will be a sum of these items, but also persisted in a `preferences` or `metadata` table for fast access without recalculation.
**Rationale**: Consistent with current app architecture (`sqflite`). 

## Decision: UI Pattern for Suggestions
**Decision**: A `ListView.builder` where suggestions are pre-populated but have zero amounts by default. Custom entries are added to the list and identified by a unique ID.
**Rationale**: Simple, follows Material Design 3 patterns, and handles dynamic list sizes efficiently.
