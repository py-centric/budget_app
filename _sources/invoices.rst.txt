# Invoices

## Overview

The invoicing system allows you to create, send, and track professional invoices for clients.

## Creating Invoices

### Basic Information

- Invoice number (auto-generated or custom)
- Client name
- Issue date
- Due date

### Line Items

- Description
- Quantity
- Unit price
- Total (calculated)

### Tax and Discounts

- Tax rate (optional)
- Discount percentage (optional)
- Notes/terms

## Invoice Management

### Status Tracking

- Draft: Work in progress
- Sent: Delivered to client
- Paid: Payment received
- Overdue: Past due date

### Actions

- Edit draft invoices
- Mark as sent/paid
- Delete drafts
- View payment history

## Invoice Data Model

```
Invoice {
  id: String
  invoiceNumber: String
  clientName: String
  clientEmail: String?
  items: List<InvoiceItem>
  subtotal: double
  taxRate: double?
  taxAmount: double?
  discount: double?
  total: double
  status: InvoiceStatus
  issueDate: DateTime
  dueDate: DateTime
  paidDate: DateTime?
  notes: String?
}

InvoiceItem {
  id: String
  description: String
  quantity: double
  unitPrice: double
  total: double
}
```

## Related Features

- [Business Tools](business_tools.rst)
- [Export & Backup](export_backup.rst)
