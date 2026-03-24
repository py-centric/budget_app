# Data Model: Invoice Styling & Branding Enhancements

## Core Entities

### 1. `CompanyProfile` (Enhanced)
| Field | Type | Description |
| :--- | :--- | :--- |
| `id` | `String` | Unique ID (UUID) |
| `name` | `String` | Business name |
| `address` | `String` | Business address |
| `taxId` | `String?` | Tax ID / VAT number |
| `logoPath` | `String?` | Path to logo file in app documents |
| `bankName` | `String?` | Name of the bank |
| `bankIban` | `String?` | IBAN for payments |
| `bankBic` | `String?` | BIC/SWIFT code |
| `bankHolder`| `String?` | Account holder name |
| `primaryColor`| `int?` | ARGB color value |
| `fontFamily` | `String?` | Name of selected font |

### 2. `Invoice` (Enhanced)
| Field | Type | Description |
| :--- | :--- | :--- |
| `id` | `String` | Unique ID (UUID) |
| `bankName` | `String?` | Overridden bank name (optional) |
| `bankIban` | `String?` | Overridden IBAN (optional) |
| `bankBic` | `String?` | Overridden BIC/SWIFT (optional) |
| `bankHolder`| `String?` | Overridden account holder (optional) |

### 3. `VATSummary` (Transient/Calculated)
Used for the PDF matrix breakdown. Not stored directly in SQLite but computed from `InvoiceItem` entries.

| Field | Type | Description |
| :--- | :--- | :--- |
| `rate` | `double` | VAT percentage (e.g., 20.0) |
| `netAmount` | `double` | Sum of prices before tax for this rate |
| `vatAmount` | `double` | Total tax calculated for this rate |
| `grossAmount`| `double` | Total net + tax |

## Persistence Mapping (SQLite)

### Table: `profiles`
- Add: `bank_name`, `bank_iban`, `bank_bic`, `bank_holder`, `primary_color`, `font_family`.

### Table: `invoices`
- Add: `bank_name`, `bank_iban`, `bank_bic`, `bank_holder`.

## State Transitions
1. **Creation Screen**: `Initial` -> `Update Form` -> `Saving` -> `Success (PDF Preview)`.
2. **Branding Management**: `Load Profile` -> `Edit Styles/Logo` -> `Save Profile`.
