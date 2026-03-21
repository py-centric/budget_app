# Implementation Plan: Invoice Dashboard & Payables

**Branch**: `023-invoice-dashboard-and-payables` | **Date**: 2026-03-15 | **Spec**: [specs/023-invoice-dashboard-and-payables/spec.md](specs/023-invoice-dashboard-and-payables/spec.md)
**Input**: Feature specification from `/specs/023-invoice-dashboard-and-payables/spec.md`

## Summary

This feature involves a major update to the invoicing module. We will rename the "Invoice History" screen to "Invoices", add a "Create Invoice" FAB, and implement a dashboard at the top showing total receivables and payables with a payment status pie chart. Additionally, we will introduce a "Received Invoices" system to track payables to vendors, accessible via a sub-tab navigation on the main Invoices screen.

## Technical Context

**Language/Version**: Dart 3.x / Flutter 3.x  
**Primary Dependencies**: `flutter_bloc`, `sqflite`, `fl_chart`, `intl`, `uuid`  
**Storage**: SQLite (via `sqflite`) - requires new `received_invoices` table.  
**Testing**: `flutter_test`, `mocktail`  
**Target Platform**: mobile-app  
**Performance Goals**: Dashboard calculations refresh in < 500ms.  
**Constraints**: 100% offline-first; Material 3 design consistency.  
**Scale/Scope**: 1 renamed screen, 1 new sub-tab screen, 1 dashboard component, new DB table.

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

1. **Tech Stack Compliance**: Uses Flutter/Bloc/SQLite. (PASS)
2. **Offline-First**: All data stored locally. (PASS)
3. **Local Storage**: Requires database migration (v15). (PASS)
4. **UX & Accessibility**: Material 3 Tabs and Dashboard patterns. (PASS)
5. **Testing**: Unit tests for dashboard calculation logic required. (PASS)

## Project Structure

### Documentation (this feature)

```text
specs/023-invoice-dashboard-and-payables/
├── plan.md              # This file
├── research.md          # Chart implementation and data aggregation
├── data-model.md        # ReceivedInvoice entity and DB schema
├── quickstart.md        # Verification steps
├── contracts/           # Repository and Bloc updates
└── tasks.md             # Implementation tasks
```

### Source Code (repository root)

```text
budget_app/
├── lib/
│   ├── features/
│   │   └── business_tools/
│   │       ├── data/
│   │       │   ├── models/
│   │       │   │   └── received_invoice_model.dart  # New
│   │       │   └── repositories/
│   │       │       └── business_repository_impl.dart  # Updates for payables
│   │       ├── domain/
│   │       │   ├── entities/
│   │       │   │   └── received_invoice.dart         # New
│   │       │   └── usecases/
│   │       │       └── calculate_invoice_stats.dart   # New logic for dashboard
│   │       └── presentation/
│   │           ├── bloc/
│   │           │   └── business_bloc.dart             # New events/states
│   │           ├── pages/
│   │           │   ├── invoices_page.dart             # Renamed & Tabbed
│   │           │   ├── outgoing_invoices_tab.dart     # Old history logic
│   │           │   └── received_invoices_tab.dart     # New payables logic
│   │           └── widgets/
│   │               └── invoice_dashboard.dart         # New chart & totals
```

**Structure Decision**: Extending `business_tools` feature using sub-tabs for navigation between receivables (outgoing) and payables (received).

## Complexity Tracking

*None.*
