# Data Model: Loan Management

## Core Entities

### 1. `Loan`
| Field | Type | Description |
| :--- | :--- | :--- |
| `id` | `String` | Unique ID (UUID) |
| `borrowerName`| `String` | Name of the person who borrowed money |
| `loanAmount` | `double` | Original loan amount |
| `loanDate` | `DateTime`| Date the loan was made |
| `status` | `Enum` | `outstanding`, `partial`, `settled` |
| `remainingBalance`| `double` | Amount still owed (loanAmount - totalPayments) |
| `createdAt` | `DateTime`| Record creation timestamp |
| `updatedAt` | `DateTime`| Last update timestamp |

### 2. `LoanPayment`
| Field | Type | Description |
| :--- | :--- | :--- |
| `id` | `String` | Unique ID (UUID) |
| `loanId` | `String` | Foreign key to Loan |
| `amount` | `double` | Payment amount |
| `paymentDate` | `DateTime`| Date payment was made |
| `createdAt` | `DateTime`| Record creation timestamp |

### 3. `LoanSummary` (Transient/Dashboard)
| Field | Type | Description |
| :--- | :--- | :--- |
| `totalOutstanding` | `double` | Sum of remainingBalance for all non-settled loans |
| `totalLoans` | `int` | Count of all loans |
| `settledCount` | `int` | Count of settled loans |
| `outstandingCount` | `int` | Count of outstanding loans |
| `partialCount` | `int` | Count of partial payments made |

## Persistence Mapping (SQLite)

### Table: `loans`
- `id` TEXT PRIMARY KEY
- `borrower_name` TEXT NOT NULL
- `loan_amount` REAL NOT NULL
- `loan_date` TEXT NOT NULL
- `status` TEXT NOT NULL
- `remaining_balance` REAL NOT NULL
- `created_at` TEXT NOT NULL
- `updated_at` TEXT NOT NULL

### Table: `loan_payments`
- `id` TEXT PRIMARY KEY
- `loan_id` TEXT NOT NULL (FK to loans)
- `amount` REAL NOT NULL
- `payment_date` TEXT NOT NULL
- `created_at` TEXT NOT NULL

## Relationships

- `Loan` has many `LoanPayment` (one-to-many)
- When a Loan is deleted, all associated payments should be deleted (cascade)
