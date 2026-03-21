# Quickstart: Invoice Dashboard & Payables

## Developer Setup

### 1. Database Migration
Increment `AppConstants.databaseVersion` to `15`.  
Update `LocalDatabase._onUpgrade` to create the `received_invoices` table.

### 2. Rename Screen
Rename `lib/features/business_tools/presentation/pages/invoice_history_page.dart` to `invoices_page.dart` and update references in `NavigationDrawerWidget`.

## Verification Steps

### 1. Unified Invoices UI
- Open sidebar and click **Invoices**.
- Verify the screen title is "Invoices".
- Verify there are two tabs: **Outgoing** and **Received**.
- Verify the **Create Invoice** button is visible and opens the builder.

### 2. Dashboard Accuracy
- Add an outgoing invoice with a $100 balance.
- Add a received invoice with a $50 balance.
- Verify the dashboard shows **Total Receivables: $100** and **Total Payables: $50**.
- Verify the pie chart segments correctly reflect the statuses.

### 3. Payables Management
- Navigate to the **Received** tab.
- Add a new received invoice.
- Edit the status to **Paid** and verify it moves out of "Total Payables" summary.

## Critical Flows
- `Dashboard Check` -> `Switch Tab` -> `Add Received Invoice` -> `Dashboard Refresh`.
- `Outgoing Tab` -> `Create Invoice` -> `PDF Preview` -> `Back to Invoices`.
