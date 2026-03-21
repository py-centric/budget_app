# Invoice Dashboard & Payables

Documentation for the Invoice Dashboard and Payables feature.

## Overview

This feature introduces:

- **Dashboard**: Aggregated view of receivables and payables with pie chart visualization
- **Outgoing Invoices**: Existing invoice management (renamed to "Outgoing" tab)
- **Received Invoices**: New payable management for vendor invoices

## Contents

.. toctree::
   :maxdepth: 2

## Modules

### Dashboard
- `CalculateInvoiceStats` use case for data aggregation
- Pie chart visualization using `fl_chart`

### Invoices
- Unified UI with tabs: "Outgoing" and "Received"
- CRUD operations for received invoices
- Status tracking: Unpaid, Partial, Paid

### Data Model
- `ReceivedInvoice` entity
- `InvoiceSummary` transient model for dashboard

## Quick Links

- :doc:`../spec`
- :doc:`../research`
- :doc:`../data-model`
- :doc:`../quickstart`
- :doc:`../checklists/requirements`
