Invoices
========

Overview
--------

The invoicing subsystem allows users to generate, format, export, and track professional client invoices with multi-line items, taxes, discounts, and payment lifecycle tracking.

Use Case Flow Diagram
---------------------

.. code-block:: text

    +-----------------------------------------------------------------------+
    |                        INVOICE MANAGEMENT LIFECYCLE                   |
    +-----------------------------------------------------------------------+
                                        |
                                        v
                          [ Create New Invoice Record ]
                                        |
                                        v
                     Add Client, Line Items, Tax & Discount
                                        |
                                        v
                            Status: [ DRAFT INVOICE ]
                                        |
           +----------------------------+----------------------------+
           |                                                         |
           v                                                         v
    [ Generate PDF Document ]                             [ Mark as Sent ]
           |                                                         |
           v                                                         v
    Preview / Share via Email                             Status: [ SENT / PENDING ]
           |                                                         |
           +----------------------------+----------------------------+
                                        |
                                        v
                         { Check Due Date vs Today }
                                        |
           +----------------------------+----------------------------+
           | (Past Due)                                              | (Payment Received)
           v                                                         v
    Status: [ OVERDUE ]                                   Status: [ PAID INVOICE ]
           |                                                         |
           v                                                         v
    Trigger Payment Reminder                             Record Income Entry in DB

Creating Invoices
-----------------

Basic Information
~~~~~~~~~~~~~~~~~

- Unique invoice number (auto-sequenced or custom alphanumeric code).
- Client name, address, and email coordinates.
- Issue date and net payment due date terms.

Line Items
~~~~~~~~~~

- Description of service rendered or goods sold.
- Quantity / hours billed.
- Unit rate.
- Itemized subtotal calculations.

Taxes, Fees, and Discounts
~~~~~~~~~~~~~~~~~~~~~~~~~~

- Configurable tax percentage (e.g. VAT / Sales Tax).
- Absolute or percentage discount deductions.
- Custom payment instructions and terms of service notes.

Invoice Management
------------------

Status Tracking
~~~~~~~~~~~~~~~

- **Draft**: Working version, editable.
- **Sent**: Delivered to client.
- **Paid**: Completed transaction.
- **Overdue**: Payment past due date.

Actions
~~~~~~~

- Export structured PDF invoice via `pdf` and `printing` packages.
- Share via system share sheet or email client.
- Mark as paid to automatically record matching income entry.

Data Models
-----------

.. code-block:: text

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
     status: InvoiceStatus (draft / sent / paid / overdue)
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

Related Features
----------------

- :doc:`business_tools`
- :doc:`export_backup`
