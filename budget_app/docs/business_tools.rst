# Business Tools

## Overview

Business tools provide specialized features for managing business finances, including invoicing and tracking payables.

## Invoice Dashboard

### Features

- Create and manage invoices
- Track payment status
- View invoice history
- Client management

### Invoice Status

- **Draft**: Not yet sent
- **Sent**: Awaiting payment
- **Paid**: Payment received
- **Overdue**: Past due date

### Invoice Data

```
Invoice {
  id: String
  invoiceNumber: String
  clientName: String
  items: List<InvoiceItem>
  totalAmount: double
  status: InvoiceStatus
  issueDate: DateTime
  dueDate: DateTime
  notes: String?
}
```

## Payables Tracking

### Features

- Track money owed to vendors
- Due date reminders
- Payment scheduling

### Vendor Management

- Add and manage vendors
- Track payment history
- Categorize by vendor type

## Related Features

- [Invoices](invoices.rst)
- [Financial Tools](financial_tools.rst)
- [Export & Backup](export_backup.rst)
