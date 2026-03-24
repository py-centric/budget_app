# Quickstart: Business Tools Sidebar & Client CRM

## Developer Setup

### 1. SQLite Migration
Increment `AppConstants.databaseVersion` to `14`.
Update `LocalDatabase._onUpgrade` to:
- Create the `clients` table.
- Add `client_id` column to the `invoices` table.

### 2. Sidebar Update
Locate `NavigationDrawerWidget` and replace the existing "Financial Tools" sub-link (if any) or add the new `ExpansionTile` at the top level.

## Verification Steps

### 1. Sidebar Transition
- Open sidebar.
- Verify "Business Tools" is present and expands.
- Verify "Invoices", "Clients", and "Profiles" sub-links function correctly.

### 2. Client CRUD
- Navigate to **Clients**.
- Add a new client with extended fields.
- Edit the client and verify persistence.
- Delete the client and verify removal from list.

### 3. Client Selection in Invoice
- Start a new **Invoice**.
- Use the "Select Client" button/dropdown.
- Verify that Name, Address, and Tax ID auto-populate upon selection.

### 4. Cloning
- Go to **Invoice History**.
- Select an existing invoice.
- Click **Clone**.
- Verify that a new builder session opens with identical items but a unique ID and "Draft" status.

## Critical Flows
- `Add Client` -> `Select in Invoice` -> `Save Invoice`.
- `History` -> `Clone Invoice` -> `Modify One Item` -> `Save New Invoice`.
