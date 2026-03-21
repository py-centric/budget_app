# Tasks: Invoice Dashboard & Payables

**Feature Branch**: `023-invoice-dashboard-and-payables`
**Spec**: [specs/023-invoice-dashboard-and-payables/spec.md](specs/023-invoice-dashboard-and-payables/spec.md)
**Implementation Plan**: [specs/023-invoice-dashboard-and-payables/plan.md](specs/023-invoice-dashboard-and-payables/plan.md)

## Summary
Transform the Invoice History into a comprehensive Invoices module featuring a financial dashboard with pie charts, receivables/payables tracking, and a new system for recording received vendor invoices.

## Phase 1: Setup (DB & Infrastructure)
Goal: Prepare the database and file structure for the new features.

- [X] T001 Increment `AppConstants.databaseVersion` to `15` in `budget_app/lib/core/constants/app_constants.dart`
- [X] T002 Add `received_invoices` table creation to `LocalDatabase._onUpgrade` and `_onCreate` in `budget_app/lib/features/budget/data/datasources/local_database.dart`
- [X] T003 Rename `invoice_history_page.dart` to `invoices_page.dart` and update all imports in `budget_app/lib/features/business_tools/presentation/pages/`
- [X] T012 [P] Update `NavigationDrawerWidget` to point to the renamed `InvoicesPage` in `budget_app/lib/features/budget/presentation/widgets/navigation_drawer_widget.dart`

## Phase 2: Foundational (Data Layer & Business Logic)
Goal: Implement the data models, repository extensions, and statistical calculation logic.

- [X] T004 [P] Create `ReceivedInvoice` entity in `budget_app/lib/features/business_tools/domain/entities/received_invoice.dart`
- [X] T005 [P] Create `ReceivedInvoiceModel` with mapping logic in `budget_app/lib/features/business_tools/data/models/received_invoice_model.dart`
- [X] T006 Create `InvoiceSummary` transient model for dashboard data in `budget_app/lib/features/business_tools/domain/entities/invoice_summary.dart`
- [X] T007 Update `BusinessRepository` interface with Received Invoice methods in `budget_app/lib/features/business_tools/domain/repositories/business_repository.dart`
- [X] T008 Implement Received Invoice methods in `BusinessRepositoryImpl` in `budget_app/lib/features/business_tools/data/repositories/business_repository_impl.dart`
- [X] T008a [P] Add unit tests for `BusinessRepository` Received Invoice methods in `budget_app/test/unit/features/business_tools/data/repositories/business_repository_test.dart`
- [X] T009 [P] Implement `CalculateInvoiceStats` use case for dashboard aggregation in `budget_app/lib/features/business_tools/domain/usecases/calculate_invoice_stats.dart`
- [X] T009a [P] Add unit tests for `CalculateInvoiceStats` use case in `budget_app/test/unit/features/business_tools/domain/usecases/calculate_invoice_stats_test.dart`
- [X] T010 [P] Extend `BusinessEvent` and `BusinessState` for Payables and Dashboard stats in `budget_app/lib/features/business_tools/presentation/bloc/`
- [X] T011 Update `BusinessBloc` to handle Received Invoice actions and stat calculations in `budget_app/lib/features/business_tools/presentation/bloc/business_bloc.dart`

## Phase 3: [US1] Unified Invoices & Creation (P1)
Goal: Implement the tabbed interface and primary creation entry point.

- [X] T013 [US1] Refactor `InvoicesPage` to use `DefaultTabController` with "Outgoing" and "Received" tabs in `budget_app/lib/features/business_tools/presentation/pages/invoices_page.dart`
- [X] T014 [US1] Extract existing history list into `OutgoingInvoicesTab` in `budget_app/lib/features/business_tools/presentation/pages/outgoing_invoices_tab.dart`
- [X] T015 [US1] Add a FloatingActionButton (FAB) for "Create Invoice" to `InvoicesPage` that opens `InvoiceBuilderPage`

**Story Goal**: Users can navigate between outgoing and received invoices and start new creations from one screen.
**Independent Test**: Verify tabs switch correctly and FAB opens the builder.

## Phase 4: [US2] Business Financial Dashboard (P2)
Goal: Build the visual dashboard with charts and totals.

- [X] T016 [P] [US2] Create `InvoiceDashboard` widget with receivables/payables totals in `budget_app/lib/features/business_tools/presentation/widgets/invoice_dashboard.dart`
- [X] T017 [US2] Integrate `fl_chart` PieChart into `InvoiceDashboard` to show payment status distribution
- [X] T018 [US2] Add period selection filter (Monthly, Rolling, Custom) to the dashboard in `budget_app/lib/features/business_tools/presentation/widgets/invoice_dashboard.dart`
- [X] T019 [US2] Embed `InvoiceDashboard` at the top of `InvoicesPage` above the tab view

**Story Goal**: Users see a clear financial summary and status breakdown at the top of their invoices.
**Independent Test**: Verify totals and chart segments update when filtering by different periods.

## Phase 5: [US3] Received Invoices (Payables) (P3)
Goal: Enable recording and tracking of vendor invoices.

- [X] T020 [US3] Create `ReceivedInvoicesTab` list view for vendor invoices in `budget_app/lib/features/business_tools/presentation/pages/received_invoices_tab.dart`
- [X] T021 [US3] Create `ReceivedInvoiceEditPage` form for recording vendor invoice details in `budget_app/lib/features/business_tools/presentation/pages/received_invoice_edit_page.dart`
- [X] T022 [US3] Add "Add Received Invoice" action to the `ReceivedInvoicesTab`

**Story Goal**: Users can track debt to vendors and manage payment statuses for received bills.
**Independent Test**: Add a received invoice and verify it appears in the list and updates the dashboard payables total.

## Final Phase: Polish & Cross-Cutting Concerns
Goal: Ensure data integrity and UI consistency.

- [X] T023 Implement confirmation dialogs for deleting received invoices
- [X] T024 Ensure currency formatting is consistent across the dashboard and lists
- [X] T025 Audit dashboard and chart performance with 1000+ data points to verify SC-002 (<500ms refresh) and SC-004
- [X] T026 Verify SC-001 (2-click navigation) and SC-003 (Dashboard scannability) through manual UX walkthrough

## Dependency Graph & Parallel Execution
- Phase 1 (T001-T003) -> Phase 2 (Foundational logic)
- US1 (Tabs) must be ready before US2 (Dashboard) and US3 (Payables) UI integration
- T004, T005, T009, T010 [P] can be developed in parallel after DB setup

## Implementation Strategy
Start with **Phase 1 & 2** to enable the new data structure. Deliver **US1** to establish the new UI pattern. Implement **US3** to enable data entry for payables, then finish with **US2** to aggregate all data into the dashboard.
