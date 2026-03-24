# Feature Specification: Business Tools Sidebar & Client CRM

**Feature Branch**: `022-business-tools-sidebar-clients-clone`  
**Created**: 2026-03-15  
**Status**: Draft  
**Input**: User description: "move the business tools to the sidebar and out of financial tools, also include the feature to store clients and their details, as well as the ability to clone invoices"

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Dedicated Sidebar Navigation (Priority: P1)

As a business user, I want to access Business Tools directly from the main sidebar so that I can manage my invoices and profiles without navigating through the Financial Tools hub.

**Why this priority**: Elevates the feature to a top-level capability, improving accessibility and reducing navigation friction.

**Independent Test**: Open the sidebar and click "Business Tools". The app should navigate directly to the business dashboard.

**Acceptance Scenarios**:

1. **Given** I am on the Home screen, **When** I open the sidebar, **Then** I see a "Business Tools" entry at the top level.
2. **Given** I am in the Financial Tools hub, **When** I look for Business Tools, **Then** it is no longer listed there.

---

### User Story 2 - Client Management (Priority: P2)

As a business owner, I want to store my clients' details (Name, Address, Tax ID) in a central database so that I can quickly select them when creating new invoices instead of typing them manually every time.

**Why this priority**: Core productivity enhancement that prevents data duplication and errors.

**Independent Test**: Create a client, then create an invoice and select that client from a dropdown. The client's details should auto-populate.

**Acceptance Scenarios**:

1. **Given** I am in Business Tools, **When** I navigate to "Clients" and add a new client, **Then** that client is saved and visible in the list.
2. **Given** I am creating an invoice, **When** I select a saved client, **Then** the client details (address, etc.) are automatically filled into the invoice fields.

---

### User Story 3 - Invoice Cloning (Priority: P3)

As a freelancer, I want to clone an existing invoice so that I can quickly generate a new bill for recurring work with similar items without re-entering all data.

**Why this priority**: Saves significant time for users with repetitive billing cycles.

**Independent Test**: Select an existing invoice and click "Clone". A new draft invoice should appear with identical line items but a new ID and current date.

**Acceptance Scenarios**:

1. **Given** an existing invoice, **When** I select "Clone" from the actions menu, **Then** a new invoice builder screen opens with all fields and line items pre-populated from the source.

---

### Edge Cases

- **Deleting a Client with Invoices**: System should handle existing invoices linked to a deleted client (e.g., keep the details on the invoice but mark the client as "Deleted" or "Archived").
- **Cloning a Paid Invoice**: A cloned invoice should always default to "Draft" status regardless of the source invoice's status.
- **Duplicate Client Names**: System should allow or warn about duplicate client names to prevent confusion.

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: System MUST move "Business Tools" from the `Financial Tools` screen to the main navigation sidebar as a top-level item.
- **FR-002**: System MUST provide a Client management interface (Create, Read, Update, Delete).
- **FR-003**: Client entities MUST include fields for Name, Address, Tax ID, Primary Contact, Email, Phone, Website, Industry, and internal Notes.
- **FR-004**: Invoice creation MUST allow selecting a Client from the stored database to auto-fill details.
- **FR-005**: System MUST provide a "Clone" action on the Invoice list/detail view.
- **FR-006**: Cloned invoices MUST generate a new invoice number using the standard auto-increment logic, ignoring the source invoice's number.
- **FR-007**: Business Tools sidebar entry SHOULD be an expandable group, allowing users to navigate directly to 'Invoices', 'Clients', or 'Profiles'.

### Key Entities

- **Client**: Represents a business or individual billed. Fields: ID, Name, Address, TaxID, etc.
- **Invoice**: Existing entity, now extended with a `clientId` reference.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: Accessing any Business Tool from the home screen requires 1 fewer click than the current implementation.
- **SC-002**: Users can create a new invoice for an existing client in under 30 seconds.
- **SC-003**: 100% of cloned invoices retain 100% of line item data from the source invoice.
- **SC-004**: System supports storing at least 500 clients without performance degradation in selection lists.
