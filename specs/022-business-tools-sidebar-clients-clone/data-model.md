# Data Model: Business Tools Sidebar & Client CRM

## Core Entities

### 1. `Client` (New)
| Field | Type | Description |
| :--- | :--- | :--- |
| `id` | `String` | Unique ID (UUID) |
| `name` | `String` | Business or individual name |
| `address` | `String` | Billing address |
| `taxId` | `String?` | VAT / Tax ID |
| `primaryContact`| `String?`| Person to contact |
| `email` | `String?` | Contact email |
| `phone` | `String?` | Contact phone |
| `website` | `String?` | Client website |
| `industry` | `String?` | Business industry |
| `notes` | `String?` | Internal internal notes |

### 2. `Invoice` (Updated)
| Field | Type | Description |
| :--- | :--- | :--- |
| `clientId` | `String?` | Optional reference to a `Client` ID |
| ... | ... | (Existing fields retained) |

## Persistence Mapping (SQLite)

### Table: `clients`
- `id` TEXT PRIMARY KEY
- `name` TEXT NOT NULL
- `address` TEXT NOT NULL
- `tax_id` TEXT
- `primary_contact` TEXT
- `email` TEXT
- `phone` TEXT
- `website` TEXT
- `industry` TEXT
- `notes` TEXT

### Table: `invoices`
- Add column: `client_id` TEXT (nullable)

## State Transitions

### Client Management
`List View` -> `Edit/Create Dialog` -> `Save (SQLite)` -> `Refresh List`

### Invoice Selection
`Builder` -> `Select Client` -> `Fetch Client Details` -> `Populate Invoice Form`

### Cloning
`History Item` -> `Action: Clone` -> `Deep Copy Invoice & Items` -> `New UUIDs` -> `Builder (Draft)`
