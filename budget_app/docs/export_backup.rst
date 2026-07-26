Export & Backup
===============

Overview
--------

Export and backup features ensure your financial data is portable and secure.

Use Case Flow Diagram
---------------------

.. code-block:: text

    +-----------------------------------------------------------------------+
    |                    EXPORT & BACKUP DATA FLOW                          |
    +-----------------------------------------------------------------------+
                                        |
                                        v
                            [ Select Data Operation ]
                                        |
           +----------------------------+----------------------------+
           | (Export Financial Data)                                 | (Database Backup / Restore)
           v                                                         v
    Choose Target Scope (Period/All)                         Select: [ Create Backup ] / [ Restore ]
           |                                                         |
    Select Format (CSV / PDF / Excel)                        [ Create ]: Export raw SQLite file
           |                                                         |
    Serialize Database Tables                                [ Restore ]: Select .db backup file
           |                                                         |
    Write to Local Temp Directory                            Verify SHA-256 Checksum Integrity
           |                                                         |
           +----------------------------+----------------------------+
                                        |
                                        v
                          [ Trigger Native Share Sheet ]
                                        |
                                        v
                          [ Save / Send File on Device ]

## Data Export

### Supported Formats

- **CSV**: Spreadsheet-compatible format
- **PDF**: Print-ready documents
- **Excel**: Native Excel files

### Export Options

- Export all data
- Export by date range
- Export by budget
- Export categories
- Export transactions

### Export Content

- Budget summaries
- Transaction lists
- Category breakdowns
- Financial reports

## Database Backup

### Manual Backup

1. Navigate to backup settings
2. Tap "Create Backup"
3. Choose storage location
4. Confirm backup creation

### Backup Contents

- All budgets
- All transactions
- Categories
- Settings
- Recurring transactions
- Loans
- Invoices

### Restore from Backup

1. Navigate to backup settings
2. Select "Restore"
3. Choose backup file
4. Confirm restoration

### Backup Storage

- Local device storage
- Share via other apps

## Data Security

- Local-only storage (privacy-focused)
- Secure storage for sensitive data
- No cloud sync (by design)

## Related Features

- [Budget Management](budget_management.rst)
- [Transactions](transactions.rst)
- [Categories](categories.rst)
