# Feature Specification: Invoice Dashboard & Payables

**Feature Branch**: `023-invoice-dashboard-and-payables`  
**Created**: 2026-03-15  
**Status**: Draft  
**Input**: User description: "rename `invoice history` to invoices, and then add a `create invoice button` on that screen, also include a dashboard at the top, with total recievables, total payable, a pie chart showing paid, unpaid, and partial payments for a given time period, also include the ability to record received invoices, i.e. invoices payable to other vendors, add a screen"

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Unified Invoices & Creation (Priority: P1)

As a business owner, I want to manage all my outgoing invoices from a single "Invoices" screen and be able to create a new one directly from there, so that I can manage my billing more efficiently.

**Why this priority**: Core navigation improvement that streamlines the primary business workflow.

**Independent Test**: Navigate to the sidebar and click "Invoices" (formerly "Invoice History"). Verify the screen title is "Invoices" and there is a prominent "Create Invoice" button that opens the invoice builder.

**Acceptance Scenarios**:

1. **Given** the app is open, **When** I look at the sidebar, **Then** I see "Invoices" instead of "Invoice History".
2. **Given** I am on the "Invoices" screen, **When** I click the "Create Invoice" button, **Then** the invoice builder screen opens.

---

### User Story 2 - Business Financial Dashboard (Priority: P2)

As a business owner, I want to see a summary of my financial state at the top of my invoices screen, including total receivables and payables, so that I can quickly assess my cash flow.

**Why this priority**: Provides critical business intelligence at a glance.

**Independent Test**: Open the "Invoices" screen and verify that the top section displays the "Total Receivables", "Total Payables", and a pie chart showing the distribution of payment statuses.

**Acceptance Scenarios**:

1. **Given** I have both outgoing and received invoices, **When** I view the "Invoices" dashboard, **Then** the "Total Receivables" shows the sum of all my unpaid/partial outgoing invoices, and "Total Payables" shows the sum of all unpaid/partial received invoices.
2. **Given** a set of invoices with various statuses, **When** I view the pie chart, **Then** it accurately reflects the proportion of Paid, Unpaid, and Partially Paid invoices for the selected period.

---

### User Story 3 - Received Invoices (Payables) (Priority: P3)

As a business owner, I want to record invoices I receive from vendors so that I can keep track of my outgoing costs and upcoming payments.

**Why this priority**: Completes the financial picture by adding the "expense" side of business invoicing.

**Independent Test**: Record a new received invoice from a vendor. Verify it appears in the "Received Invoices" list and its amount is included in the "Total Payables" on the dashboard.

**Acceptance Scenarios**:

1. **Given** I am in the Business Tools section, **When** I navigate to the "Received Invoices" screen and add an entry, **Then** the system saves the vendor name, date, amount, and status.
2. **Given** a received invoice exists, **When** I update its status to "Paid", **Then** the "Total Payables" on the dashboard decreases accordingly.

---

### Edge Cases

- **Zero Invoices**: The dashboard should show 0 values and an empty state for the chart if no invoices exist for the period.
- **Negative Balances**: System should handle or prevent negative invoice totals if such a case arises from returns or credits.
- **Deleted Vendors**: If a vendor linked to a received invoice is deleted, the invoice should retain its textual vendor name for historical accuracy.

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: System MUST rename the existing "Invoice History" screen to "Invoices".
- **FR-002**: System MUST add a prominent "Create Invoice" action (e.g., FAB or Header button) to the "Invoices" screen.
- **FR-003**: System MUST implement a dashboard widget at the top of the "Invoices" screen.
- **FR-004**: The dashboard MUST display "Total Receivables" (sum of balance due on all outgoing invoices).
- **FR-005**: The dashboard MUST display "Total Payables" (sum of balance due on all received invoices).
- **FR-006**: The dashboard MUST include a pie chart showing the breakdown of Paid, Unpaid, and Partially Paid invoices.
- **FR-007**: System MUST provide a mechanism to filter dashboard data by Standard Fiscal periods (Monthly, Quarterly, Yearly, All Time), Rolling Windows (Last 30 days, Last 90 days, Last Year), and Custom Date Ranges.
- **FR-008**: System MUST allow users to record "Received Invoices" (Payables) including Vendor, Date, Amount, Tax, and Status.
- **FR-009**: System MUST provide a dedicated screen to view and manage the list of "Received Invoices".
- **FR-010**: System MUST make Received Invoices accessible via a sub-tab on the main "Invoices" screen, allowing toggling between 'Outgoing' and 'Received'.

### Key Entities

- **ReceivedInvoice**: Represents an invoice received from a third-party vendor. Fields: ID, VendorName, Date, Amount, TaxAmount, Status (Unpaid, Partial, Paid), BalanceDue.
- **OutgoingInvoice**: Existing `Invoice` entity, used to calculate receivables.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: Navigation from the home screen to creating a new invoice is reduced to a maximum of 2 clicks.
- **SC-002**: Dashboard calculations (Receivables/Payables) refresh in under 500ms when an invoice is added or updated.
- **SC-003**: 100% of users can identify their total outstanding debt (Payables) within 5 seconds of opening the Invoices screen.
- **SC-004**: The pie chart correctly handles up to 1000 data points without visual lag or degradation.
