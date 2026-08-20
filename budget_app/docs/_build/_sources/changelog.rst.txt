Changelog
=========

All notable changes to the Budget App platform are documented in this file.

Version 1.1.0 (Current)
-----------------------

Added
~~~~~

- Multi-Bank Account Management with Net Worth Aggregator and live balance calculations.
- Account-level transaction association and filtering in the main Filter Bar.
- Anchored Filter Bar layout with right-pinned Clear action to eliminate UI shifts.
- Ergonomic 90% screen-width Floating Action Buttons for Add Income and Add Expense (45% width each).
- Decomposed Data Access Object (DAO) architecture under ``lib/core/database/`` separating Budget, Transaction, Account, Category, CategoryLimit, Loan, Invoice, EmergencyFund, and FinancialTools queries.
- WCAG 2.1 AA compliant High Contrast theme mode in AppTheme and Settings.
- Standardized cross-platform ``Taskfile.yml`` task runner commands.
- Sphinx documentation portal with Mermaid diagram integration and PyCentric attribution.

Changed
~~~~~~~

- Replaced monolithic LocalDatabase queries with specialized domain DAOs.
- Enhanced touch target dimensions across all interactive widgets to satisfy 48x48dp accessibility baselines.
- Unified release edition feature flagging for Personal, Business, and Combined targets.

Fixed
~~~~~

- Resolved filter button shifting on mobile screens when active filters trigger Clear visibility.
- Fixed floating action button hero tag collisions and padding overlaps on long transaction lists.

Version 1.0.0 (Initial Release)
-------------------------------

Added
~~~~~

- Monthly budget creation, period navigation, and multi-period management.
- Income and expense transaction ledger with custom categories.
- Recurring transaction engine with daily, weekly, monthly, and yearly intervals.
- Cash flow projections across 3, 6, and 12-month time horizons.
- Offline currency conversion supporting 20 world currencies.
- Travel budget duplication with automatic exchange rate conversion.
- Loan and debt tracking for money lent and borrowed.
- Emergency fund target calculator and runway estimator.
- Client invoicing and accounts payable tracking.
- Financial calculation tools (loan amortization, tip splitter, savings growth).
- CSV, Excel, and PDF data export and encrypted SQLite database backups.
- Biometric and PIN app lock security.
