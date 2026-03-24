# Tasks: Business Tools Sidebar & Client CRM

**Feature Branch**: `022-business-tools-sidebar-clients-clone`
**Spec**: [specs/022-business-tools-sidebar-clients-clone/spec.md](specs/022-business-tools-sidebar-clients-clone/spec.md)
**Implementation Plan**: [specs/022-business-tools-sidebar-clients-clone/plan.md](specs/022-business-tools-sidebar-clients-clone/plan.md)

## Summary
Elevate Business Tools to a top-level sidebar category, implement a comprehensive Client CRM, and add deep-copy invoice cloning functionality.

## Phase 1: Setup (Project Init)
Goal: Initialize database schema and basic infrastructure.

- [X] T001 Increment `databaseVersion` to `14` in `budget_app/lib/core/constants/app_constants.dart`
- [X] T002 Add `clients` table creation and `invoices.client_id` column migration in `budget_app/lib/features/budget/data/datasources/local_database.dart`
- [X] T003 Update `_onCreate` in `LocalDatabase` to include new schema for fresh installs in `budget_app/lib/features/budget/data/datasources/local_database.dart`

## Phase 2: Foundational (Entities & Data Layer)
Goal: Define data structures and persistence logic.

- [X] T004 [P] Create `Client` entity in `budget_app/lib/features/business_tools/domain/entities/client.dart`
- [X] T005 [P] Create `ClientModel` with mapping logic in `budget_app/lib/features/business_tools/data/models/client_model.dart`
- [X] T006 Update `Invoice` entity to include `clientId` in `budget_app/lib/features/business_tools/domain/entities/invoice.dart`
- [X] T007 Update `InvoiceModel` with `clientId` mapping in `budget_app/lib/features/business_tools/data/models/invoice_model.dart`
- [X] T008 Update `BusinessRepository` interface with Client CRUD methods in `budget_app/lib/features/business_tools/domain/repositories/business_repository.dart`
- [X] T009 Implement Client CRUD and extended fetch methods in `budget_app/lib/features/business_tools/data/repositories/business_repository_impl.dart`
- [X] T009a [P] Add unit tests for Client repository logic in `budget_app/test/unit/features/business_tools/data/repositories/business_repository_test.dart`
- [X] T010 [P] Extend `BusinessEvent` and `BusinessState` for Client management in `budget_app/lib/features/business_tools/presentation/bloc/`
- [X] T011 Implement Client event handlers in `BusinessBloc` in `budget_app/lib/features/business_tools/presentation/bloc/business_bloc.dart`

## Phase 3: [US1] Dedicated Sidebar Navigation (P1)
Goal: Move Business Tools to top-level navigation.

- [X] T012 [P] [US1] Refactor `NavigationDrawerWidget` to include an `ExpansionTile` for Business Tools in `budget_app/lib/features/budget/presentation/widgets/navigation_drawer_widget.dart`
- [X] T013 [US1] Link sidebar sub-items (Invoices, Clients, Profiles) to their respective pages in `budget_app/lib/features/budget/presentation/widgets/navigation_drawer_widget.dart`
- [X] T014 [US1] Remove "Business Tools" entry from `ToolsHubPage` in `budget_app/lib/features/financial_tools/presentation/pages/tools_hub_page.dart`

**Story Goal**: Business Tools are accessible directly from sidebar via an expandable group.
**Independent Test**: Verify "Business Tools" appears in sidebar and navigates correctly to history, clients, and profile.

## Phase 4: [US2] Client Management (P2)
Goal: Implement CRM functionality and integration with Invoices.

- [X] T015 [P] [US2] Implement `ManageClients` use case in `budget_app/lib/features/business_tools/domain/usecases/manage_clients.dart`
- [X] T015a [US2] Add unit tests for `ManageClients` use case in `budget_app/test/unit/features/business_tools/domain/usecases/manage_clients_test.dart`
- [X] T016 [US2] Create `ClientsPage` list view with CRUD actions in `budget_app/lib/features/business_tools/presentation/pages/clients_page.dart`
- [X] T017 [US2] Create `ClientEditPage` form for client details in `budget_app/lib/features/business_tools/presentation/pages/client_edit_page.dart`
- [X] T018 [US2] Create `ClientSelectorDialog` for choosing clients during invoice creation in `budget_app/lib/features/business_tools/presentation/widgets/client_selector_dialog.dart`
- [X] T019 [US2] Integrate `ClientSelectorDialog` into `InvoiceBuilderPage` and implement auto-population logic in `budget_app/lib/features/business_tools/presentation/pages/invoice_builder_page.dart`

**Story Goal**: Users can store clients and auto-populate their details in new invoices.
**Independent Test**: Add a client, start a new invoice, select the client, and confirm details are filled.

## Phase 5: [US3] Invoice Cloning (P3)
Goal: Enable deep-copying of existing invoices.

- [X] T020 [P] [US3] Implement `CloneInvoice` use case (fetch source + save as draft with new UUIDs and next available INV-YYYYMMDD number) in `budget_app/lib/features/business_tools/domain/usecases/clone_invoice.dart`
- [X] T021 [US3] Add "Clone" action to invoice items in `InvoiceHistoryPage` in `budget_app/lib/features/business_tools/presentation/pages/invoice_history_page.dart`
- [X] T022 [US3] Implement BLoC logic to trigger cloning and navigate to `InvoiceBuilderPage` with cloned data in `budget_app/lib/features/business_tools/presentation/bloc/business_bloc.dart`

**Story Goal**: Users can clone an existing invoice to create a new draft with same items.
**Independent Test**: Clone an invoice from history and verify builder opens with identical items but current date.

## Final Phase: Polish & Cross-Cutting Concerns
Goal: Final validation and UI refinement.

- [X] T023 Ensure "Clone" action resets status to "Draft" and clears payment history
- [X] T024 Audit Material 3 spacing and consistency across new Client screens
- [X] T025 Implement confirmation dialog for client deletion with active invoices
- [X] T026 Verify SC-004 (500+ clients performance) via scrolling audit in the ClientsPage list

## Dependency Graph & Parallel Execution
- Phase 1 (Blocking)
- T004, T005, T010 [P] (Foundational entities can be done together)
- US1, US2, US3 (Sequential story delivery)
- T012, T015, T020 [P] (Logic/UI components for stories can start early)

## Implementation Strategy
Deliver **US1 (Sidebar)** first to establish the new entry point. Follow with **US2 (CRM)** as it provides the most data value. Conclude with **US3 (Cloning)** for workflow optimization.
