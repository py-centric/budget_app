# Feature Specification: Business Tools

**Feature Branch**: `020-business-tools`  
**Created**: Sunday, 15 March 2026  
**Status**: Draft  
**Input**: User description: "implement business tools, such as VAT calculator, exVAT calculator, invoice creation, ability to print the invoice to PDF, etc."

## User Scenarios & Testing *(mandatory)*

### User Story 1 - VAT and exVAT Calculators (Priority: P1)

As a business user, I want to quickly calculate VAT and ex-VAT amounts so that I can determine final prices or base costs for products and services.

**Why this priority**: Core utility that provides immediate value with minimal complexity.

**Independent Test**: Can be fully tested by entering a net amount and a VAT rate to get the gross amount, and vice versa.

**Acceptance Scenarios**:

1. **Given** the user is on the VAT Calculator screen, **When** they enter a net amount of 100 and a VAT rate of 20%, **Then** the system displays a VAT amount of 20 and a total gross amount of 120.
2. **Given** the user is on the exVAT Calculator screen, **When** they enter a gross amount of 120 and a VAT rate of 20%, **Then** the system displays a VAT amount of 20 and a total net amount of 100.

---

### User Story 2 - Basic Invoice Creation (Priority: P1)

As a business user, I want to create a professional invoice by entering client details and line items so that I can document my services and request payment.

**Why this priority**: Essential for business operations and forms the basis for the PDF generation.

**Independent Test**: Can be tested by filling out an invoice form with at least one line item and verifying the total is calculated correctly.

**Acceptance Scenarios**:

1. **Given** the user is on the New Invoice screen, **When** they enter client name "Acme Corp" and add a line item "Consulting" for 500, **Then** the invoice total is displayed as 500.
2. **Given** an invoice with multiple line items, **When** the user changes the quantity or rate of an item, **Then** the line total and grand total are updated instantly.

---

### User Story 3 - PDF Generation and Printing (Priority: P2)

As a business user, I want to export my created invoices to a PDF document so that I can send them to clients via email or print them.

**Why this priority**: High value for professional communication, though it depends on the invoice creation being functional.

**Independent Test**: Can be tested by clicking "Export to PDF" on an invoice and verifying a PDF file is generated with all the invoice details.

**Acceptance Scenarios**:

1. **Given** a completed invoice, **When** the user selects the "Export to PDF" action, **Then** a PDF document is generated containing the client details, itemized list, and totals.

---

### User Story 4 - Invoice Persistence (Priority: P2)

As a business user, I want my invoices to be saved in the app so that I can review, edit, or re-print them later.

**Why this priority**: Critical for long-term usability and tracking business history.

**Independent Test**: Create an invoice, close the app, and verify the invoice appears in a "Saved Invoices" list.

**Acceptance Scenarios**:

1. **Given** the user has created an invoice, **When** they save it, **Then** it appears in the list of saved invoices with its unique ID and date.

### Edge Cases

- **Zero or Negative VAT**: System should handle 0% VAT correctly and prevent negative VAT rates or amounts.
- **Missing Client Details**: How should the system handle invoices where required fields like "Client Name" are missing? (Requirement: Validation should prevent saving/printing until mandatory fields are filled).
- **Large Item Lists**: Invoices with many items should correctly paginate in the PDF export.

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: System MUST provide a VAT calculator that computes gross and VAT amounts from net input.
- **FR-002**: System MUST provide an exVAT calculator that computes net and VAT amounts from gross input.
- **FR-003**: System MUST allow users to set a custom VAT rate (e.g., 5%, 20%).
- **FR-004**: System MUST provide an invoice builder with fields for Client Name, Address, Date, Invoice Number, Tax ID, Payment Terms, Logo support, Notes/Footer, and dynamic Tax Rate per line item.
- **FR-005**: System MUST allow users to add, edit, and remove line items (description, quantity, rate) on an invoice.
- **FR-006**: System MUST automatically calculate line item totals and grand total including tax.
- **FR-007**: System MUST generate a professional PDF layout including:
  - Header with Company Logo and Profile Details
  - Client Name and Address
  - Invoice Metadata (Number, Date, Due Date)
  - Itemized Table (Description, Quantity, Rate, Tax Rate, Line Total)
  - Summary Section (Sub-total, Total Tax, Grand Total, Balance Due)
  - Footer with Notes and Payment Info
- **FR-008**: System MUST allow users to manage multiple Company Profiles (name, address, logo, tax ID, payment info) and select one as the sender when creating an invoice.
- **FR-009**: System MUST allow users to save, browse, and delete created invoices.
- **FR-010**: System MUST provide a way to track invoice status (Draft, Sent, Paid) and record multiple partial payments against the total balance.
- **FR-011**: System MUST calculate the `balance_due` for an invoice by subtracting the sum of all associated `InvoicePayment` amounts from the `grand_total`.

### Key Entities *(include if feature involves data)*

- **Invoice**: Represents a single billing document.
  - Attributes: `id`, `profile_id`, `invoice_number`, `date`, `client_name`, `client_details`, `sub_total`, `tax_total`, `grand_total`, `status`, `balance_due`.
- **InvoiceItem**: A single line item on an invoice.
  - Attributes: `description`, `quantity`, `rate`, `tax_rate`, `total`.
- **CompanyProfile**: A business identity for the user.
  - Attributes: `id`, `name`, `address`, `tax_id`, `logo_path`, `payment_info`.
- **InvoicePayment**: A record of a payment made against an invoice.
  - Attributes: `id`, `invoice_id`, `amount`, `date`, `method`.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: Users can calculate a VAT amount in under 10 seconds.
- **SC-002**: Users can create and save a basic 3-item invoice in under 2 minutes.
- **SC-003**: 100% of generated PDFs accurately reflect the data entered in the invoice builder.
- **SC-004**: Invoices with up to 50 items are correctly paginated and rendered in PDF format.
