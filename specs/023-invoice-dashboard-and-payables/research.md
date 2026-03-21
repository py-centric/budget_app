# Research: Invoice Dashboard & Payables

## Decisions & Rationale

### 1. Chart Implementation (`fl_chart`)
- **Decision**: Use `PieChart` from `fl_chart` package.
- **Rationale**: The project already uses `fl_chart` for other features, ensuring consistency. `PieChart` is well-suited for showing the distribution of invoice payment statuses (Paid, Unpaid, Partial).
- **Details**: We will use `PieChartSectionData` to represent each status. Colors will be mapped to project standards (e.g., Green for Paid, Red for Unpaid, Orange for Partial).

### 2. Dashboard Data Aggregation
- **Decision**: Create a dedicated `CalculateInvoiceStats` use case.
- **Rationale**: Keeps the BLoC clean and provides a testable unit for business logic. The use case will take a list of `Invoice` and `ReceivedInvoice` objects and a filter period, then perform the necessary sums and status groupings.
- **Filtering**: Standard `DateTime` ranges will be used to filter both incoming and outgoing invoices before aggregation.

### 3. Unified Invoices UI
- **Decision**: Use `DefaultTabController` with two tabs: "Outgoing" and "Received".
- **Rationale**: Provides a familiar, frictionless way to switch between receivables and payables without cluttering the main navigation. The Dashboard will be placed above the `TabBarView` or as a sticky header.

### 4. Database Schema
- **Decision**: Add a new `received_invoices` table.
- **Rationale**: While `ReceivedInvoice` shares some fields with `Invoice`, they are conceptually different (Payable vs Receivable). A separate table prevents mixing distinct workflows and allows for future schema diverges specific to vendor management.

## Technology Best Practices
- **`fl_chart`**: Use `badgeWidgets` for interactive labels if space permits, or a legend below the chart for clarity.
- **SQLite**: Ensure foreign keys are correctly defined for vendor linking if a vendor CRM is added later (currently uses text for vendor name as per spec).
- **Bloc**: Update `BusinessBloc` to handle `LoadReceivedInvoices`, `SaveReceivedInvoice`, etc.
