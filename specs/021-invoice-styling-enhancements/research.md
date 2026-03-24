# Research: Invoice Styling & Branding Enhancements

## Decisions & Rationale

### 1. Logo Handling in PDF
- **Decision**: Store logos in the local `applicationDocumentsDirectory` and use `MemoryImage` or `FileImage` with the `pdf` package.
- **Rationale**: Persisting the file path in SQLite and reading the file on-demand during PDF generation is the most efficient and robust way for an offline-first app.
- **Alternatives considered**: Storing base64 in SQLite (rejected due to blob size limits/performance).

### 2. Styling Model
- **Decision**: Create a `CompanyBranding` or `InvoiceStyle` embedded object within `CompanyProfile` and `Invoice`.
- **Rationale**: This follows Clean Architecture by keeping styling separate from core business logic while allowing persistence in SQLite as JSON strings.

### 3. SQLite Migrations
- **Decision**: Add columns to `profiles` and `invoices` tables via `onUpgrade`.
- **Rationale**: Required to support existing user data while adding new fields like `bank_name`, `iban`, `primary_color`, `font_family`, etc.

### 4. Spacing Fixes
- **Decision**: Implement a `Gap` widget or use consistent `Padding` with a standard theme spacing unit (e.g., `8.0`).
- **Rationale**: Ensures visual rhythm and maintainability in the invoice creation form.

## Technology Best Practices
- **`pdf` Package**: Use `pw.Theme` to apply global styles (colors, fonts) across the document.
- **`sqflite`**: Increment `AppConstants.databaseVersion` and update `LocalDatabase` class.
- **Flutter UI**: Use `SingleChildScrollView` to prevent overflow when more fields are added to the creation screen.
