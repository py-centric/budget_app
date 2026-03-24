# Contracts: Business Tools Sidebar & Client CRM

## 1. BusinessRepository Updates

### Client Operations
```dart
Future<List<Client>> getClients();
Future<void> saveClient(Client client);
Future<void> deleteClient(String id);
```

### Invoice Extensions
```dart
Future<Invoice> getInvoice(String id); // Already exists, but ensure it returns items
Future<List<InvoiceItem>> getInvoiceItems(String invoiceId); // Ensure accessibility for cloning
```

## 2. BusinessBloc Events

### Client Management
- `LoadClients`: Triggers fetching all clients from SQLite.
- `SaveClient(Client client)`: Saves/Updates a client.
- `DeleteClient(String id)`: Removes a client.

### Invoice Cloning
- `CloneInvoice(String invoiceId)`: Triggers the deep-copy use case and navigates to the builder.

## 3. UI Navigation Contract

### Sidebar Group (Expandable)
- **Label**: "Business Tools"
- **Children**:
  - "Invoices" (Navigates to `InvoiceHistoryPage`)
  - "Clients" (Navigates to `ClientsPage`)
  - "Profiles" (Navigates to `ProfileSettingsPage`)
