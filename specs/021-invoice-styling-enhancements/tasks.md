# Tasks: Invoice Styling & Branding Enhancements

**Feature Branch**: `021-invoice-styling-enhancements`
**Spec**: [specs/021-invoice-styling-enhancements/spec.md](specs/021-invoice-styling-enhancements/spec.md)
**Implementation Plan**: [specs/021-invoice-styling-enhancements/plan.md](specs/021-invoice-styling-enhancements/plan.md)

## Summary
Enhance the business invoicing feature with logo support, full styling customization, banking details, and automated VAT summary matrices in PDF exports. Improvements also include a more intuitive creation workflow and optimized UI spacing.

## Phase 1: Setup (Database & Project Init)
Goal: Prepare the infrastructure for new branding and banking data.

- [X] T001 Increment `AppConstants.databaseVersion` to `13` in `budget_app/lib/core/constants/app_constants.dart`
- [X] T002 Add migration to version `13` in `LocalDatabase._onUpgrade` within `budget_app/lib/features/budget/data/datasources/local_database.dart` (Add columns: `bank_name`, `bank_iban`, `bank_bic`, `bank_holder`, `primary_color`, `font_family` to `company_profiles`; `bank_name`, `bank_iban`, `bank_bic`, `bank_holder` to `invoices`)
- [X] T003 Update `_onCreate` in `LocalDatabase` within `budget_app/lib/features/budget/data/datasources/local_database.dart` to include new branding and banking columns

## Phase 2: Foundational (Entities & Data Layer)
Goal: Update core models and persistence logic to handle styling and banking details.

- [X] T004 [P] Update `CompanyProfile` entity with new banking and styling fields in `budget_app/lib/features/business_tools/domain/entities/company_profile.dart`
- [X] T005 [P] Update `Invoice` entity with override banking fields in `budget_app/lib/features/business_tools/domain/entities/invoice.dart`
- [X] T006 Update `CompanyProfileModel` with mapping logic for new fields in `budget_app/lib/features/business_tools/data/models/company_profile_model.dart`
- [X] T007 Update `InvoiceModel` with mapping logic for new banking override fields in `budget_app/lib/features/business_tools/data/models/invoice_model.dart`
- [X] T008 Update repository methods to ensure new fields are correctly saved and retrieved from SQLite

## Phase 3: [US1] Branded Invoice Creation (P1)
Goal: Implement logo upload and professional banking details on invoices.

- [X] T009 [P] [US1] Create logo picking and storage utility in `budget_app/lib/features/business_tools/presentation/utils/logo_picker.dart`
- [X] T010 [US1] Add logo upload and banking detail fields to the Profile Edit screen in `budget_app/lib/features/business_tools/presentation/pages/company_profile_page.dart`
- [X] T011 [US1] Add banking override fields to the Invoice Creation form in `budget_app/lib/features/business_tools/presentation/pages/create_invoice_page.dart`
- [X] T012 [US1] Update PDF Generator header/footer to include banking details and apply user-selected logo in `budget_app/lib/features/business_tools/domain/usecases/generate_invoice_pdf.dart`

**Story Goal**: Logo and banking details are visible on generated PDFs.
**Independent Test**: Upload a logo and set banking details in Profile; generate an invoice and verify they appear on the PDF.

## Phase 4: [US2] VAT Breakdown (P2)
Goal: Provide a compliant VAT summary matrix on generated PDFs.

- [X] T013 [P] [US2] Implement `VATSummary` calculation logic in `budget_app/lib/features/business_tools/domain/utils/vat_calculator.dart`
- [X] T013a [US2] Add unit tests for `VATSummary` calculation logic in `budget_app/test/unit/features/business_tools/domain/utils/vat_calculator_test.dart`
- [X] T014 [US2] Add the VAT Summary Matrix table to the PDF generation logic in `budget_app/lib/features/business_tools/domain/usecases/generate_invoice_pdf.dart`

**Story Goal**: Invoices show a detailed tax breakdown table grouped by VAT rate.
**Independent Test**: Add items with different VAT rates to an invoice and verify the summary table totals match the sum of items per rate.

## Phase 5: [US3] Seamless Creation Workflow (P3)
Goal: Automate preview opening and optimize form layout.

- [X] T015 [US3] Update `InvoiceBloc` to navigate to the PDF preview page immediately upon successful creation in `budget_app/lib/features/business_tools/presentation/pages/create_invoice_page.dart`
- [X] T016 [US3] Refactor `CreateInvoicePage` layout with improved spacing and vertical rhythm using a standard `Gap` or `Padding` strategy
- [X] T017 [US3] Implement header/footer layout toggling, brand color accents, and font selection in `budget_app/lib/features/business_tools/domain/usecases/generate_invoice_pdf.dart`

**Story Goal**: Clicking 'Create' opens the PDF preview instantly; creation form feels less cluttered.
**Independent Test**: Complete the creation form, click create, and confirm the PDF preview loads without extra navigation.

## Final Phase: Polish & Cross-Cutting Concerns
Goal: Final validation and edge case handling.

- [X] T018 Ensure PDF layouts handle missing logos or empty banking details gracefully (no broken icons)
- [X] T019 Verify color accessibility for user-selected brand colors against font colors on the PDF
- [X] T020 [US3] Verify SC-001 (Preview transition < 1s) and SC-004 (VAT matrix accuracy) via manual and automated checks

## Dependency Graph & Parallel Execution
- T001-T003 (Blocking)
- T004-T005 [P]
- T006-T008 (Sequence)
- T009, T013 [P] (Independent Utilities)
- US1 (P1) -> US2 (P2) -> US3 (P3)

## Implementation Strategy
Start with **Phase 1 & 2** to enable data persistence. Implement **US1** as the MVP for branding. US2 and US3 add regulatory and UX polish respectively.
