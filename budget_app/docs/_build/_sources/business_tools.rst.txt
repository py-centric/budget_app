Business Tools
==============

Overview
--------

Business tools provide specialized capabilities for freelance operators, consultants, and small enterprises, including full invoice generation, client directories, and accounts payable tracking.

Invoice Dashboard
-----------------

Features
~~~~~~~~

- Create, edit, and duplicate professional invoices.
- Track real-time invoice lifecycle status.
- Maintain a local client book and business profiles.
- Generate structured PDF documents with custom branding and tax breakdowns.

Invoice Status Workflow
~~~~~~~~~~~~~~~~~~~~~~~

- **Draft**: In progress, not yet issued to client.
- **Sent**: Issued, awaiting payment.
- **Paid**: Settlement received, recorded in cash flow.
- **Overdue**: Past specified payment terms.

Invoice Data Model
~~~~~~~~~~~~~~~~~~

.. code-block:: text

   Invoice {
     id: String
     invoiceNumber: String
     clientName: String
     items: List<InvoiceItem>
     totalAmount: double
     status: InvoiceStatus (draft / sent / paid / overdue)
     issueDate: DateTime
     dueDate: DateTime
     notes: String?
   }

Accounts Payable Tracking
-------------------------

Features
~~~~~~~~

- Track outstanding liabilities owed to vendors and contractors.
- Payment scheduling and cash flow impact modeling.
- Vendor profiles with historical payment records.

Related Features
----------------

- :doc:`invoices`
- :doc:`financial_tools`
- :doc:`export_backup`
