# Data Model: Emergency Fund Calculator

## Entities

### EmergencyExpense
Represents a single cost item (suggested or custom) in the calculator.

| Field | Type | Description | Validation |
|-------|------|-------------|------------|
| id | String (UUID) | Unique identifier | Required |
| name | String | Display name | Max 50 chars, non-empty |
| amount | Double | Target amount for this item | Min 0.0 |
| is_suggestion | Boolean | True if it's a default system suggestion | Required |
| category_type | String? | Grouping (e.g., 'Insurance', 'Personal') | Optional |
| sort_order | Int | Display sequence | Non-negative |

### EmergencyFundTarget
Global configuration for the final calculated target.

| Field | Type | Description | Validation |
|-------|------|-------------|------------|
| key | String | 'emergency_fund_target' | Constant |
| value | Double | Total calculated sum | Min 0.0 |

## Relationships
- `EmergencyFundTarget` is the aggregate sum of all `EmergencyExpense.amount` entries.
- One-to-many: The "Emergency Calculator" manages many `EmergencyExpense` records.

## Database Schema (SQLite)

```sql
CREATE TABLE emergency_expenses (
    id TEXT PRIMARY KEY,
    name TEXT NOT NULL,
    amount REAL NOT NULL DEFAULT 0.0,
    is_suggestion INTEGER NOT NULL,
    category_type TEXT,
    sort_order INTEGER NOT NULL
);
```

## State Transitions
1. **Initial**: Load all suggestions (e.g., Car Tyres, Insurance Excess) with `amount = 0.0`.
2. **Update**: User modifies `amount` → Save to DB → Recalculate total.
3. **Add Custom**: User adds "Pet Emergency" → Create new entry → Save → Recalculate.
4. **Delete Custom**: Remove record from DB → Recalculate.
5. **Reset Suggestion**: Set `amount` to `0.0` → Save → Recalculate.
