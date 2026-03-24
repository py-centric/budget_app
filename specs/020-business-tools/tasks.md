# Tasks: Business Tools

**Input**: Design documents from `/specs/020-business-tools/`
**Prerequisites**: plan.md (required), spec.md (required for user stories), research.md, data-model.md, quickstart.md

**Organization**: Tasks are grouped by user story to enable independent implementation and testing of each story.

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Can run in parallel (different files, no dependencies)
- **[Story]**: Which user story this task belongs to (e.g., US1, US2, US3)
- Include exact file paths in descriptions

## Phase 1: Setup (Shared Infrastructure)

**Purpose**: Project initialization and basic structure

- [x] T001 Create feature directory structure in lib/features/business_tools/
- [x] T002 [P] Create data, domain, and presentation subdirectories in lib/features/business_tools/
- [x] T003 [P] Add barrel files for domain entities and repositories in lib/features/business_tools/

---

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: Core infrastructure that MUST be complete before ANY user story can be implemented

- [x] T004 Implement database migration for `company_profiles`, `invoices`, `invoice_items`, and `invoice_payments` in lib/shared/data/local_database.dart
- [x] T005 Increment `AppConstants.databaseVersion` in lib/core/constants/app_constants.dart
- [x] T006 [P] Create domain entities (Invoice, InvoiceItem, CompanyProfile, InvoicePayment) in lib/features/business_tools/domain/entities/
- [x] T007 [P] Create data models with fromMap/toMap in lib/features/business_tools/data/models/
- [x] T008 Implement BusinessRepository interface in lib/features/business_tools/domain/repositories/business_repository.dart
- [x] T009 Implement BusinessRepositoryImpl in lib/features/business_tools/data/repositories/business_repository_impl.dart
- [x] T010 [P] Create BusinessBloc for shared states (profiles, active invoice) in lib/features/business_tools/presentation/bloc/business_bloc.dart

**Checkpoint**: Foundation ready - user story implementation can now begin.

---

## Phase 3: User Story 1 - VAT and exVAT Calculators (Priority: P1) 🎯 MVP

**Goal**: Provide standalone VAT calculation utilities and UI.

**Independent Test**: Open VAT calculator, enter net amount + rate, see correct gross total.

### Implementation for User Story 1

- [x] T011 [US1] Create VAT calculation domain logic/utilities in lib/features/business_tools/domain/usecases/calculate_vat.dart
- [x] T012 [P] [US1] Create VatCalculatorPage in lib/features/business_tools/presentation/pages/vat_calculator_page.dart
- [x] T013 [US1] Implement dual-mode input (Net -> Gross and Gross -> Net) in VatCalculatorPage
- [x] T014 [US1] Add custom VAT rate selector to VatCalculatorPage

**Checkpoint**: User Story 1 (VAT utilities) is functional.

---

## Phase 4: Profile Management & Invoice History (Priority: P2)

**Goal**: Support multiple business profiles and basic invoice storage.

**Independent Test**: Save a company profile, then verify it persists after app restart.

### Implementation for User Story 4

- [x] T015 [US4] Create ProfileSettingsPage for managing CompanyProfile entities in lib/features/business_tools/presentation/pages/profile_settings_page.dart
- [x] T016 [US4] Implement CRUD operations for CompanyProfile in BusinessBloc and Repository
- [x] T017 [P] [US4] Create InvoiceHistoryPage to browse saved invoices in lib/features/business_tools/presentation/pages/invoice_history_page.dart
- [x] T018 [US4] Implement basic invoice listing and deletion in BusinessBloc

---

## Phase 5: User Story 2 - Basic Invoice Creation (Priority: P1)

**Goal**: Interactive invoice builder with line-item management.

**Independent Test**: Create an invoice, add 2 items, see correct grand total calculated instantly.

### Implementation for User Story 2

- [x] T019 [US2] Create InvoiceBuilderPage in lib/features/business_tools/presentation/pages/invoice_builder_page.dart
- [x] T020 [US2] Implement dynamic line-item list widget in lib/features/business_tools/presentation/widgets/invoice_item_list.dart
- [x] T021 [US2] Add ProfileSelector to InvoiceBuilderPage to choose the sender identity
- [x] T022 [US2] Implement real-time total calculation (sub-total, tax, grand total) in InvoiceBuilderPage
- [x] T023 [US2] Implement "Save Invoice" operation persisting to SQLite (invoices + items)
- [x] T024 [US2] Implement Status & Payment tracking logic (Draft/Sent/Paid) in lib/features/business_tools/presentation/widgets/payment_tracker.dart

**Checkpoint**: User Story 2 (Invoice Builder) is functional.

---

## Phase 6: User Story 3 - PDF Generation and Printing (Priority: P2)

**Goal**: Professional PDF export for created invoices.

**Independent Test**: Click "Print to PDF" on an invoice and view the generated document.

### Implementation for User Story 3

- [x] T025 [US3] Implement PDF layout generator with multi-page pagination logic (per SC-004) using `pdf` package in lib/features/business_tools/domain/usecases/generate_invoice_pdf.dart
- [x] T026 [US3] Add logo support to PDF generation (fetching from local path)
- [x] T027 [US3] Create PDF Preview screen using `printing` package in lib/features/business_tools/presentation/pages/pdf_preview_page.dart
- [x] T028 [US3] Integrate PDF generation with InvoiceBuilderPage and InvoiceHistoryPage

**Checkpoint**: User Story 3 (PDF Export) is functional.

---

## Phase 7: Polish & Cross-Cutting Concerns

**Purpose**: UI/UX refinements and final verification

- [x] T029 Add input validation for monetary fields and required invoice data
- [x] T030 Apply consistent Material Design 3 styling across all business tool pages
- [x] T031 Implement PDF pagination for large item lists
- [x] T032 Add navigation entry for Business Tools in ToolsHubPage
- [x] T033 Run `flutter run` to verify the feature executes correctly on target platform

---

## Dependencies & Execution Order

### Phase Dependencies

- **Setup (Phase 1)**: Can start immediately.
- **Foundational (Phase 2)**: Depends on Phase 1 - BLOCKS all story implementation.
- **VAT Calculators (Phase 3)**: Independent after Phase 2.
- **Profile/Persistence (Phase 4)**: Independent after Phase 2.
- **Invoice Creation (Phase 5)**: Depends on Phase 4 (needs profiles).
- **PDF Export (Phase 6)**: Depends on Phase 5 (needs invoice data).
- **Polish (Phase 7)**: Final step.

### Parallel Opportunities

- T002, T003 (Setup)
- T006, T007 (Data Layer scaffolding)
- Phase 3 (VAT) and Phase 4 (Profiles) can be developed in parallel once Phase 2 is complete.
- UI widget creation (T020, T021) can run in parallel.

---

## Implementation Strategy

### MVP First (User Story 1 & 2)

1. Complete Setup & Foundation.
2. Implement VAT calculators (US1) for immediate utility.
3. Build the Invoice Builder (US2) with basic profile support.
4. **STOP and VALIDATE**: Ensure invoices can be created and saved.

### Incremental Delivery

1. Add PDF Generation (US3).
2. Refine status and payment tracking (part of US4/C).
3. Final polish and pagination.
