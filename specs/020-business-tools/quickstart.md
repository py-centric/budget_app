# Quickstart: Business Tools

## Overview
Implement business utilities (VAT/exVAT) and a complete invoicing system with PDF support.

## Project Structure
- `lib/features/business_tools/`:
  - `data/`: `BusinessRepository`, models for Profile, Invoice, Item, Payment.
  - `domain/`: Entities and use cases (`CalculateVAT`, `GenerateInvoicePDF`, `ManageProfiles`).
  - `presentation/`:
    - `bloc/`: `BusinessBloc`, `InvoiceBloc`.
    - `pages/`: `VatCalculatorPage`, `InvoiceBuilderPage`, `ProfileSettingsPage`, `InvoiceHistoryPage`.
    - `widgets/`: `InvoiceItemTile`, `ProfileSelector`, `PaymentDialog`.

## Development Steps
1. **Database Migration**: Update `LocalDatabase` to include the 4 new business tables. Increment `databaseVersion` in `AppConstants`.
2. **Core Logic**: Implement the VAT calculation logic (standalone utilities).
3. **Repository & Models**: Build the data layer for persistence.
4. **Invoice Builder**: Create the UI for adding line items and calculating totals in real-time.
5. **PDF Integration**: Implement the `pdf` and `printing` logic to render the invoice entity into a document.
6. **Payment Tracking**: Add the ability to record partial payments and update invoice status.

## Verification
- Run unit tests for VAT accuracy.
- Verify PDF output matches MD3 design expectations.
- Ensure all business data is persisted and accessible offline.
