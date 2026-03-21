# Contracts: Invoice Dashboard & Payables

## 1. BusinessRepository Extensions

### Received Invoices (Payables)
```dart
Future<List<ReceivedInvoice>> getReceivedInvoices();
Future<void> saveReceivedInvoice(ReceivedInvoice invoice);
Future<void> deleteReceivedInvoice(String id);
```

## 2. BusinessBloc Updates

### Events
- `LoadReceivedInvoices`: Fetches all payables.
- `SaveReceivedInvoice(ReceivedInvoice invoice)`: Persists a received invoice.
- `DeleteReceivedInvoice(String id)`: Removes a received invoice.
- `FilterInvoices(DateTimeRange range)`: Updates the dashboard and lists based on period.

### State
- `List<ReceivedInvoice> receivedInvoices`: Current list of payables.
- `InvoiceSummary? summary`: Aggregated data for the dashboard.

## 3. UI Component Interface

### `InvoiceDashboard` Widget
- **Input**: `InvoiceSummary` object.
- **Output**: Visual representation of totals and `PieChart`.
- **Interaction**: Period selection dropdown triggers `FilterInvoices`.
