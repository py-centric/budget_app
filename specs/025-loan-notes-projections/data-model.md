# Data Model: Loan Notes & Projections

## Enhanced Entity

### Loan (Extended from 024)
| Field | Type | Description |
| :--- | :--- | :--- |
| `id` | `String` | Unique ID (UUID) - existing |
| `borrowerName`| `String` | Name of the person - existing |
| `loanAmount` | `double` | Original loan amount - existing |
| `loanDate` | `DateTime`| Date the loan was made - existing |
| `status` | `Enum` | `outstanding`, `partial`, `settled` - existing |
| `remainingBalance`| `double` | Amount still owed - existing |
| `notes` | `String?` | NEW: User notes about the loan |
| `direction` | `Enum` | NEW: `lent` (default) or `owed` |
| `includeInProjections` | `bool` | NEW: Include in financial projections |
| `createdAt` | `DateTime`| Record creation timestamp - existing |
| `updatedAt` | `DateTime`| Last update timestamp - existing |

## Persistence Mapping (SQLite)

### Table: `loans` (Enhanced)
- Add columns via migration v16 → v17:
  - `notes` TEXT (nullable, max 1000 chars)
  - `direction` TEXT NOT NULL DEFAULT 'lent'
  - `include_in_projections` INTEGER NOT NULL DEFAULT 0

## Relationships

- Loan → same as before, no new relationships
- Projection calculates net position: (sum of lent remaining) - (sum of owed remaining)
