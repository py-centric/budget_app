# Feature Specification: Invoice Styling & Branding Enhancements

**Feature Branch**: `021-invoice-styling-enhancements`  
**Created**: 2026-03-15  
**Status**: Draft  
**Input**: User description: "add the option to style the invoices and to add a logo to the invoice, as well as banking details, and a VAT summary table breakdown, when the invoice is created it should open the preview, please also fix the spacing in the invoice creation screen"

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Branded Invoice Creation (Priority: P1)

As a business owner, I want to add my logo and banking details to my invoices so that my customers can recognize my brand and know where to send payments.

**Why this priority**: Branding and payment instructions are fundamental to professional invoicing.

**Independent Test**: Create an invoice after uploading a logo and entering banking details. The generated PDF should display both correctly.

**Acceptance Scenarios**:

1. **Given** a business profile with a logo uploaded, **When** I create a new invoice, **Then** the logo appears at the top of the invoice preview.
2. **Given** banking details are saved in the settings, **When** I generate an invoice, **Then** the IBAN, BIC, and Bank Name are clearly listed in the footer/payment section.

---

### User Story 2 - Tax Compliance with VAT Breakdown (Priority: P2)

As a business owner, I want a VAT summary table on my invoices so that I can provide clear tax breakdowns for my customers and tax authorities.

**Why this priority**: Required for legal compliance in many regions.

**Independent Test**: Add items with different VAT rates to an invoice. The summary table should correctly group and sum the amounts by rate.

**Acceptance Scenarios**:

1. **Given** an invoice with items at 5% and 20% VAT, **When** the invoice is generated, **Then** a table shows the Net, VAT Amount, and Gross for each rate separately.

---

### User Story 3 - Seamless Creation Workflow (Priority: P3)

As a user, I want the invoice preview to open immediately after I click create, and for the creation screen to be well-spaced, so that I can work efficiently.

**Why this priority**: Improves user experience and reduces manual clicks.

**Independent Test**: Complete the invoice form and click 'Save/Create'. The PDF preview should open automatically without further user action.

**Acceptance Scenarios**:

1. **Given** the invoice creation form is open, **When** I click 'Create', **Then** the system saves the invoice and transitions immediately to the PDF preview screen.
2. **Given** the invoice creation screen, **When** I view the form fields, **Then** there is clear visual separation and consistent padding between input groups.

### Edge Cases

- **Missing Logo**: If no logo is uploaded, the invoice should layout gracefully without a broken image placeholder.
- **Large Logos**: System should scale logos to fit the designated header area while maintaining aspect ratio.
- **No VAT Items**: If an invoice has no VAT-applicable items, the VAT summary table should be omitted or show a 0% summary.

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: System MUST allow users to upload a business logo (PNG/JPG) to be stored locally.
- **FR-002**: System MUST provide fields for banking details (Bank Name, Account Holder, IBAN, BIC).
- FR-003: System MUST support full styling customization, allowing users to choose primary/secondary colors, select from a predefined list of fonts, and toggle between available layout positions for header/footer elements.
- FR-004: System MUST automatically generate a detailed VAT summary matrix showing the Net Amount, VAT Amount, and Gross Amount for each individual tax rate used in the invoice.
- FR-005: System MUST trigger the PDF preview viewer immediately upon successful invoice creation.
- FR-006: System MUST persist default banking details in the Business Profile but allow users to override or edit these details for any specific invoice during creation.
- **FR-007**: System MUST implement improved layout spacing in the invoice creation form to avoid visual clutter.

### Key Entities

- **CompanyProfile**: Represents business identity (Logo, Name, Address, Banking Details).
- **Invoice**: The document itself, containing items, totals, and a reference to the profile branding at the time of creation.
- **VATBreakdown**: A calculated summary object grouping invoice items by their tax rate.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: Users can complete the transition from "Click Create" to "View Preview" in under 1 second (excluding PDF generation time).
- **SC-002**: The invoice creation form passes a visual audit for consistent vertical rhythm and spacing (no overlapping fields).
- **SC-003**: 100% of generated PDFs correctly render the uploaded logo without distortion.
- **SC-004**: VAT summary table totals always match the sum of individual line item taxes.
