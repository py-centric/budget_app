# Data Model: Business Tools

## Entities

### CompanyProfile
User's business identity.

| Field | Type | Description | Validation |
|-------|------|-------------|------------|
| id | String (UUID) | Unique ID | Required |
| name | String | Business name | Non-empty |
| address | String | Full address | Required |
| tax_id | String? | Business Tax/VAT number | Optional |
| logo_path | String? | Local path to logo file | Optional |
| payment_info | String? | Bank details, PayPal, etc. | Optional |
| default_vat_rate | Double | Default VAT for new invoices | Min 0.0 |

### Invoice
A billing document.

| Field | Type | Description | Validation |
|-------|------|-------------|------------|
| id | String (UUID) | Unique ID | Required |
| profile_id | String | Link to CompanyProfile | Required |
| invoice_number | String | Display number (e.g. INV-001) | Required |
| date | DateTime | Invoice date | Required |
| client_name | String | Name of the client | Required |
| client_details | String | Client address/info | Required |
| status | Enum | Draft, Sent, Paid | Required |
| sub_total | Double | Sum of items before tax | Min 0.0 |
| tax_total | Double | Total tax amount | Min 0.0 |
| grand_total | Double | Final amount due | Min 0.0 |
| notes | String? | Custom message/footer | Optional |

### InvoiceItem
Line item on an invoice.

| Field | Type | Description | Validation |
|-------|------|-------------|------------|
| id | String (UUID) | Unique ID | Required |
| invoice_id | String | Link to Invoice | Required |
| description | String | Service/Product name | Non-empty |
| quantity | Double | Number of units | Min 0.0 |
| rate | Double | Price per unit | Min 0.0 |
| tax_rate | Double | VAT rate for this item | Min 0.0 |
| total | Double | Calculated total (qty * rate) | Min 0.0 |

### InvoicePayment
Payment record against an invoice.

| Field | Type | Description | Validation |
|-------|------|-------------|------------|
| id | String (UUID) | Unique ID | Required |
| invoice_id | String | Link to Invoice | Required |
| amount | Double | Paid amount | Min 0.0 |
| date | DateTime | Date of payment | Required |
| method | String | Cash, Transfer, Card, etc. | Required |

## Relationships
- `CompanyProfile` (1) --- (N) `Invoice`
- `Invoice` (1) --- (N) `InvoiceItem`
- `Invoice` (1) --- (N) `InvoicePayment`

## Database Schema (SQLite)

```sql
CREATE TABLE company_profiles (
    id TEXT PRIMARY KEY,
    name TEXT NOT NULL,
    address TEXT NOT NULL,
    tax_id TEXT,
    logo_path TEXT,
    payment_info TEXT,
    default_vat_rate REAL NOT NULL DEFAULT 0.0
);

CREATE TABLE invoices (
    id TEXT PRIMARY KEY,
    profile_id TEXT NOT NULL,
    invoice_number TEXT NOT NULL,
    date TEXT NOT NULL,
    client_name TEXT NOT NULL,
    client_details TEXT NOT NULL,
    status TEXT NOT NULL,
    sub_total REAL NOT NULL,
    tax_total REAL NOT NULL,
    grand_total REAL NOT NULL,
    notes TEXT,
    FOREIGN KEY (profile_id) REFERENCES company_profiles (id) ON DELETE CASCADE
);

CREATE TABLE invoice_items (
    id TEXT PRIMARY KEY,
    invoice_id TEXT NOT NULL,
    description TEXT NOT NULL,
    quantity REAL NOT NULL,
    rate REAL NOT NULL,
    tax_rate REAL NOT NULL,
    total REAL NOT NULL,
    FOREIGN KEY (invoice_id) REFERENCES invoices (id) ON DELETE CASCADE
);

CREATE TABLE invoice_payments (
    id TEXT PRIMARY KEY,
    invoice_id TEXT NOT NULL,
    amount REAL NOT NULL,
    date TEXT NOT NULL,
    method TEXT NOT NULL,
    FOREIGN KEY (invoice_id) REFERENCES invoices (id) ON DELETE CASCADE
);
```
