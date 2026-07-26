Project Dependencies & Licensing
==================================

Overview
--------

Budget App is committed to open-source software transparency. This document details every third-party library, framework, and tool integrated into the project, including its license, OSI compliance status, legal implications, usage scope, and functional purpose.

Production Dependencies
-----------------------

.. list-table:: Production Libraries & Frameworks
   :widths: 20 25 15 10 30
   :header-rows: 1

   * - Library / Framework
     - Description
     - License Type
     - OSI Approved
     - Where & How Used
   * - **Flutter SDK**
     - UI toolkit for cross-platform apps by Google
     - BSD 3-Clause
     - [x] Yes
     - **Location**: App-wide (``lib/``)
       **Usage**: Core application rendering engine, Material 3 components, and window management.
   * - **flutter_bloc** (v8.1.6)
     - State management library for BLoC pattern
     - MIT
     - [x] Yes
     - **Location**: ``lib/core/feature_flags/presentation/bloc/``, ``lib/features/*/presentation/bloc/``
       **Usage**: Manages reactive state flow, budget computations, and feature flags without tight UI coupling.
   * - **hydrated_bloc** (v9.1.5)
     - Automatic persistence extension for BLoCs
     - MIT
     - [x] Yes
     - **Location**: ``lib/core/feature_flags/presentation/bloc/feature_flags_bloc.dart``, ``lib/features/settings/presentation/bloc/settings_bloc.dart``
       **Usage**: Persists release edition overrides, user preferences, and theme configuration locally across restarts.
   * - **sqflite / sqflite_ffi** (v2.3.3+1)
     - SQLite database engine for mobile & desktop
     - BSD 2-Clause / MIT
     - [x] Yes
     - **Location**: ``lib/core/database/local_database.dart``, ``lib/features/*/data/datasources/``
       **Usage**: Powers local offline-first relational database storing budgets, transactions, categories, loans, and invoices.
   * - **equatable** (v2.0.5)
     - Value equality comparison utility
     - MIT
     - [x] Yes
     - **Location**: ``lib/features/*/domain/entities/``, ``lib/core/feature_flags/presentation/bloc/``
       **Usage**: Enables value-based object equality across BLoC states and domain entities to optimize UI rebuilds.
   * - **intl** (v0.19.0)
     - Internationalization and date/currency formatting
     - BSD 3-Clause
     - [x] Yes
     - **Location**: ``lib/core/utils/currency_formatter.dart``, ``lib/core/utils/date_formatter.dart``
       **Usage**: Formats financial amounts, currency symbols, and localized date strings across all screens.
   * - **uuid** (v4.5.3)
     - Unique identifier generator (UUID v4)
     - MIT
     - [x] Yes
     - **Location**: ``lib/features/*/data/datasources/``, ``lib/shared/utils/id_generator.dart``
       **Usage**: Generates unique String keys for database entity records (income, expenses, invoices).
   * - **fl_chart** (v1.1.1)
     - Interactive chart and visualization engine
     - BSD 3-Clause
     - [x] Yes
     - **Location**: ``lib/features/projections/presentation/widgets/``, ``lib/features/business_tools/presentation/widgets/``
       **Usage**: Renders financial projection curves, expense distribution pie charts, and category trend bar charts.
   * - **pdf / printing** (v3.11.1 / v5.13.2)
     - PDF document creation and native print integration
     - Apache License 2.0
     - [x] Yes
     - **Location**: ``lib/features/export/data/datasources/pdf_export_datasource.dart``, ``lib/features/business_tools/``
       **Usage**: Generates structured PDF financial reports, printable invoice documents, and launches OS print dialogs.
   * - **csv** (v6.0.0)
     - CSV parsing and serialization library
     - MIT
     - [x] Yes
     - **Location**: ``lib/features/export/data/datasources/csv_export_datasource.dart``
       **Usage**: Exports income, expense, and transaction tables to CSV files for external spreadsheet compatibility.
   * - **excel** (v4.0.0)
     - Pure Dart XLSX spreadsheet generator
     - MIT
     - [x] Yes
     - **Location**: ``lib/features/export/data/datasources/excel_export_datasource.dart``
       **Usage**: Generates multi-sheet formatted Excel workbooks for full data backups and financial reporting.
   * - **share_plus** (v12.0.1)
     - Native system share sheet invocation plugin
     - BSD 3-Clause
     - [x] Yes
     - **Location**: ``lib/features/export/presentation/pages/export_page.dart``, ``lib/features/backup/``
       **Usage**: Triggers native device share dialogs for exported PDFs, CSVs, Excel files, and database backup archives.
   * - **local_auth / flutter_secure_storage**
     - Biometrics (Touch/Face ID) & encrypted keychain storage
     - BSD 3-Clause
     - [x] Yes
     - **Location**: ``lib/features/app_lock/services/auth_service.dart``, ``lib/features/app_lock/data/datasources/``
       **Usage**: Handles biometric PIN authentication and encrypted storage of sensitive user security keys.
   * - **flutter_local_notifications / timezone**
     - Local push notifications & IANA timezone parser
     - BSD 3-Clause
     - [x] Yes
     - **Location**: ``lib/features/reminders/services/notification_service.dart``
       **Usage**: Schedules system notifications for bill due dates, recurring transactions, and spending limit alerts.
   * - **flutter_slidable** (v4.0.3)
     - Actionable slide-to-reveal list tile widget
     - MIT
     - [x] Yes
     - **Location**: ``lib/features/budget/presentation/widgets/expense_list_tile.dart``
       **Usage**: Enables swipe-to-edit and swipe-to-delete contextual list actions.
   * - **table_calendar** (v3.1.0)
     - Month/week grid event calendar widget
     - Apache License 2.0
     - [x] Yes
     - **Location**: ``lib/features/budget/presentation/pages/calendar_view_page.dart``
       **Usage**: Displays month-grid calendars highlighting daily expenses, income events, and bill due dates.
   * - **file_picker** (v8.0.0)
     - Native file selection dialog plugin
     - MIT
     - [x] Yes
     - **Location**: ``lib/features/backup/presentation/pages/restore_page.dart``
       **Usage**: Opens native OS file picker to select database backup files (``.db``) for restoration.
   * - **path_provider / path** (v2.1.5 / v1.9.0)
     - Platform directory resolution & path string tools
     - BSD 3-Clause
     - [x] Yes
     - **Location**: ``lib/core/database/local_database.dart``, ``lib/features/export/``
       **Usage**: Resolves local device document paths for SQLite database storage and exported files.
   * - **crypto** (v3.0.0)
     - Pure Dart SHA-256 and MD5 cryptographic functions
     - BSD 3-Clause
     - [x] Yes
     - **Location**: ``lib/core/utils/hash_util.dart``, ``lib/features/backup/services/``
       **Usage**: Calculates SHA-256 checksums to verify database backup file integrity prior to restore execution.
   * - **cupertino_icons** (v1.0.8)
     - iOS Cupertino iconography font
     - MIT
     - [x] Yes
     - **Location**: App-wide fallback assets
       **Usage**: Renders iOS-styled visual icons.

Development & Testing Dependencies
-----------------------------------

.. list-table:: Development & Testing Libraries
   :widths: 20 25 15 10 30
   :header-rows: 1

   * - Library / Framework
     - Description
     - License Type
     - OSI Approved
     - Where & How Used
   * - **bloc_test / mocktail** (v9.1.7 / v1.0.4)
     - BLoC stream testing and type-safe mocking library
     - MIT
     - [x] Yes
     - **Location**: ``test/unit/``, ``test/widget/``, ``test/integration/``
       **Usage**: Mocks repositories, services, and BLoC streams without code generation.
   * - **flutter_test / flutter_lints** (v6.0.0)
     - Testing framework & static analysis rules
     - BSD 3-Clause
     - [x] Yes
     - **Location**: ``test/``, ``analysis_options.yaml``
       **Usage**: Executes unit/widget tests and enforces strict Dart style and quality checks.
   * - **coverage** (v1.11.0)
     - Test coverage reporter for Dart
     - BSD 3-Clause
     - [x] Yes
     - **Location**: ``test/``
       **Usage**: Generates LCOV coverage metrics for continuous integration testing.

Documentation Build Tools
-------------------------

.. list-table:: Sphinx Documentation Dependencies
   :widths: 20 25 15 10 30
   :header-rows: 1

   * - Tool / Library
     - Description
     - License Type
     - OSI Approved
     - Where & How Used
   * - **Sphinx**
     - Python documentation generator
     - BSD 2-Clause
     - [x] Yes
     - **Location**: ``docs/``
       **Usage**: Compiles reStructuredText and Markdown files into HTML documentation.
   * - **myst-parser**
     - Markdown parser extension for Sphinx
     - MIT
     - [x] Yes
     - **Location**: ``docs/conf.py``
       **Usage**: Enables parsing and rendering GitHub Flavored Markdown files within Sphinx.

License Implications & Compliance Summary
-----------------------------------------

All 24 third-party libraries and frameworks integrated into Budget App use OSI-approved, non-copyleft open-source licenses:

1. **Permissive Open-Source Licensing**: All dependencies are licensed under **MIT**, **BSD 2-Clause**, **BSD 3-Clause**, or **Apache License 2.0**.
2. **No Strong Copyleft Constraints**: None of the dependencies use GPL, AGPL, or LGPL licenses, ensuring full freedom for commercial or non-commercial deployment without requiring the host codebase to inherit copyleft constraints.
3. **Attribution Requirement**: MIT, BSD, and Apache 2.0 licenses require maintaining copyright notices and license text in open-source redistributions.
4. **Patent Protections**: Packages under **Apache License 2.0** (such as ``pdf`` and ``table_calendar``) explicitly grant patent licenses from contributors to users.
5. **OSI Compliance**: **100%** of included third-party libraries carry verified Open Source Initiative (OSI) approved licenses.
