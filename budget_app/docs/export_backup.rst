Export & Backup
===============

Overview
--------

Export and backup features ensure your financial data is 100% portable, verifiable, and secure under an offline-first architecture.

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

Data Export
-----------

Supported Formats
~~~~~~~~~~~~~~~~~

- **CSV**: Universal tabular format for data science and external spreadsheets.
- **PDF**: Formatted, print-ready financial statements generated on-device.
- **Excel (XLSX)**: Multi-sheet workbooks with styled summary and transaction tabs.

Export Options
~~~~~~~~~~~~~~

- Export entire history or specific monthly budget periods.
- Filter by category or account before exporting.
- Export transaction ledgers with full date, description, and status tags.

Database Backup & Restore
-------------------------

Creating Backups
~~~~~~~~~~~~~~~~

1. Open **Settings** > **Export & Backup**.
2. Tap **Create Database Backup**.
3. The app serializes the entire SQLite database into an integrity-checked backup file.
4. Save locally or share to your preferred secure offline destination.

Restoring from Backup
~~~~~~~~~~~~~~~~~~~~~

1. Select **Restore from Backup**.
2. Choose a valid `.db` backup file from local storage.
3. Confirm replacement of current database records.

Data Security & Privacy
-----------------------

- **100% Local-First**: No remote servers or third-party cloud tracking.
- **Encrypted Keys**: Sensitive credentials and PINs protected in OS secure keychain via `flutter_secure_storage`.

Related Features
----------------

- :doc:`app_settings`
- :doc:`budget_management`
- :doc:`transactions`
