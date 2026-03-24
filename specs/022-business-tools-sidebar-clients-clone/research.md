# Research: Business Tools Sidebar & Client CRM

## Decisions & Rationale

### 1. Sidebar Navigation (Expandable Group)
- **Decision**: Use `ExpansionTile` or a custom stateful wrapper within the `NavigationDrawer`'s `ListView`.
- **Rationale**: Material 3 `NavigationDrawer` does not have a native "ExpansionGroup" component like some web frameworks, but `ExpansionTile` is the standard Flutter way to handle collapsible sections.
- **Alternatives considered**: Simple flat links (rejected per user preference for an expandable group).

### 2. Client-Invoice Relationship
- **Decision**: Store `client_id` as an optional foreign key in the `invoices` table.
- **Rationale**: Allows invoices to be linked to a central CRM while maintaining backwards compatibility for existing invoices that only have raw text client details. If a client is selected, we sync their current details to the invoice fields to preserve the "snapshot" of the client at the time of billing.
- **Alternatives considered**: Mandatory foreign key (rejected because it would break existing data or force migration of all text-only invoices).

### 3. Invoice Cloning Logic
- **Decision**: Implement a `CloneInvoice` use case that fetches an invoice and its items, then saves new entries with fresh UUIDs and a "Draft" status.
- **Rationale**: Keeps business logic out of the UI layer and ensures atomic operations (saving both the invoice and its line items).
- **Alternatives considered**: Cloning logic within the BLoC (rejected to keep BLoC lean and focus on state).

### 4. Client CRM Fields
- **Decision**: Implement a dedicated `clients` table with all fields specified in FR-003.
- **Rationale**: Full compliance with the "Extended" CRM requirement (Name, Address, Tax ID, Primary Contact, Email, Phone, Website, Industry, Notes).

## Technology Best Practices
- **SQLite Migrations**: Use `batch` operations in `_onUpgrade` for consistency.
- **BLoC State**: Introduce a `ClientBloc` or extend `BusinessBloc` to handle CRM state. Given the existing structure, extending `BusinessBloc` is more consistent with the "Business Tools" feature grouping.
- **UI Consistency**: Use `ListTile` with `leading` icons for the new sidebar entries to match the existing drawer style.
