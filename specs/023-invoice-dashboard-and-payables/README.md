# Invoice Dashboard & Payables

## Overview

Feature spec for adding a financial dashboard with invoice status visualization and vendor payables management.

## What's Included

| Document | Purpose |
|----------|---------|
| `spec.md` | Feature requirements and scope |
| `research.md` | Technology decisions and rationale |
| `data-model.md` | Entity definitions and database schema |
| `plan.md` | Technical implementation plan |
| `tasks.md` | Task breakdown and acceptance criteria |
| `quickstart.md` | Developer setup and verification steps |
| `docs/` | Sphinx documentation |
| `checklists/` | Requirements quality checklists |

## Quick Start

```bash
# Verify setup
flutter doctor

# Run verification steps from quickstart.md
```

## Key Features

1. **Dashboard Metrics**
   - Total Receivables (outgoing invoices balance)
   - Total Payables (received invoices balance)
   - Invoice status breakdown (Paid/Unpaid/Partial counts)
   - Pie chart visualization

2. **Invoice Management**
   - Outgoing invoices (existing functionality)
   - Received invoices (new - vendor payables)
   - Status transitions

3. **Data Model**
   - `ReceivedInvoice`: vendorName, invoiceNumber, date, dueDate, amount, taxAmount, status, balanceDue
   - `InvoiceSummary`: aggregated dashboard metrics

## Database

- Table: `received_invoices` (new)
- Migration: `databaseVersion` 14 → 15

## Dependencies

- `fl_chart` for pie chart visualization
- BLoC pattern for state management
- SQLite for local persistence
