# Data Model: Multi-Bank Accounts

## Entities

### Account

Represents a bank or savings account.

| Field | Type | Constraints | Description |
|-------|------|-------------|-------------|
| id | String | UUID, primary key | Unique identifier |
| name | String | Required, max 100 chars | Account name |
| type | Enum | Required | checking, savings, investment, other |
| balance | Double | Required, default 0.0 | Current balance |
| currency | String | Required, ISO 4217 | Currency code (e.g., USD) |
| createdAt | DateTime | Auto-generated | Creation timestamp |
| updatedAt | DateTime | Auto-updated | Last modification timestamp |

### Transfer

Represents a money transfer between two accounts.

| Field | Type | Constraints | Description |
|-------|------|-------------|-------------|
| id | String | UUID, primary key | Unique identifier |
| fromAccountId | String | Required, foreign key | Source account |
| toAccountId | String | Required, foreign key | Destination account |
| amount | Double | Required, > 0 | Transfer amount |
| date | DateTime | Required | Transfer date |
| note | String | Optional, max 500 chars | Optional description |
| createdAt | DateTime | Auto-generated | Creation timestamp |

## Relationships

- Account has many Transfers (as source or destination)
- Transfer references exactly two Accounts
- No direct relationship to Budget - accounts are separate from budgets

## Validation Rules

1. Account name cannot be empty
2. Transfer amount must be positive
3. Transfer fromAccountId cannot equal toAccountId
4. Transfer cannot exceed source account balance (optional enforcement)

## State Transitions

### Account States
- Active: Default state when created
- Deleted: Soft delete when user removes account

### Transfer States
- Created: Initial state
- (No complex state machine - transfers are immutable)

## Database Schema (SQLite)

```sql
CREATE TABLE accounts (
  id TEXT PRIMARY KEY,
  name TEXT NOT NULL,
  type TEXT NOT NULL,
  balance REAL NOT NULL DEFAULT 0.0,
  currency TEXT NOT NULL DEFAULT 'USD',
  created_at INTEGER NOT NULL,
  updated_at INTEGER NOT NULL
);

CREATE TABLE transfers (
  id TEXT PRIMARY KEY,
  from_account_id TEXT NOT NULL,
  to_account_id TEXT NOT NULL,
  amount REAL NOT NULL,
  date INTEGER NOT NULL,
  note TEXT,
  created_at INTEGER NOT NULL,
  FOREIGN KEY (from_account_id) REFERENCES accounts(id) ON DELETE CASCADE,
  FOREIGN KEY (to_account_id) REFERENCES accounts(id) ON DELETE CASCADE
);
```
