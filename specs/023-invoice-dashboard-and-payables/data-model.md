# Data Model: Invoice Dashboard & Payables

## Core Entities

### 1. `ReceivedInvoice` (New)
| Field | Type | Description |
| :--- | :--- | :--- |
| `id` | `String` | Unique ID (UUID) |
| `vendorName`| `String` | Name of the vendor (equivalent to `clientName` on outgoing invoices) |
| `invoiceNumber`| `String?`| Vendor's invoice number |
| `date` | `DateTime`| Date of the invoice |
| `dueDate` | `DateTime?`| Payment due date |
| `amount` | `double` | Total invoice amount (Gross) |
| `taxAmount` | `double` | Tax portion of the amount |
| `status` | `Enum` | `unpaid`, `partial`, `paid` |
| `balanceDue`| `double` | Remaining amount to be paid |
| `notes` | `String?` | Internal notes |

### 2. `InvoiceSummary` (Transient/Dashboard)
| Field | Type | Description |
| :--- | :--- | :--- |
| `totalReceivables`| `double` | Sum of `balanceDue` from Outgoing Invoices |
| `totalPayables` | `double` | Sum of `balanceDue` from Received Invoices |
| `paidCount` | `int` | Count of Paid invoices (both types) |
| `unpaidCount` | `int` | Count of Unpaid invoices (both types) |
| `partialCount` | `int` | Count of Partial invoices (both types) |

## Persistence Mapping (SQLite)

### Table: `received_invoices`
- `id` TEXT PRIMARY KEY
- `vendor_name` TEXT NOT NULL
- `invoice_number` TEXT
- `date` TEXT NOT NULL
- `due_date` TEXT
- `amount` REAL NOT NULL
- `tax_amount` REAL NOT NULL
- `status` TEXT NOT NULL
- `balance_due` REAL NOT NULL
- `notes` TEXT

## Relationships
- `ReceivedInvoice` is currently standalone (vendor mapping via text).
- `Invoice` (Outgoing) remains unchanged but its usage in the dashboard is added.
