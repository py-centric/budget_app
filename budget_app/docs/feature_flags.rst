Feature Flagging & Release Editions
====================================

Overview
--------

Budget App features a centralized, decoupled **Feature Flagging System** that enables building and deploying three specialized target release editions from a single codebase:

1. **Personal Edition**: Tailored strictly for personal budgeting, income/expense tracking, personal savings goals, debt payoff strategies, and net worth calculations.
2. **Business Edition**: Focused on business financial operations, invoicing, receivables, payables, bank reconciliation, and business tax estimations.
3. **Combined Edition**: Full suite with all personal and business features enabled simultaneously.

Architecture & Feature Flow
----------------------------

The feature flag engine uses compile-time build configuration via ``--dart-define=RELEASE_EDITION=...`` combined with optional runtime overrides stored in ``HydratedStorage`` for QA testing in debug builds.

.. code-block:: text

    Build Target Flag (--dart-define=RELEASE_EDITION=personal|business|combined)
                           │
                           ▼
                 DefaultFeatureMapping Registry
                           │
                           ▼
                  FeatureFlagsBloc (HydratedBloc)
                           │
                           ▼
                   FeatureGateService (Sync API)
                           │
           ┌───────────────┴───────────────┐
           ▼                               ▼
    FeatureGate Widget             FeatureRouteGuard
           │                               │
           ▼                               ▼
    Conditional UI Components      Gated Screen Routes

Feature Flag Mapping Matrix
---------------------------

.. list-table:: Feature Release Matrix
   :widths: 30 15 15 15 25
   :header-rows: 1

   * - Feature Flag
     - Personal Edition
     - Business Edition
     - Combined Edition
     - Domain
   * - ``personalBudgets``
     - Enabled
     - Disabled
     - Enabled
     - Personal Budgeting
   * - ``emergencyFund``
     - Enabled
     - Disabled
     - Enabled
     - Emergency Fund
   * - ``debtPayoff``
     - Enabled
     - Disabled
     - Enabled
     - Debt Payoff
   * - ``invoicingPayables``
     - Disabled
     - Enabled
     - Enabled
     - Invoices & Payables
   * - ``bankReconciliation``
     - Disabled
     - Enabled
     - Enabled
     - Reconciliation
   * - ``taxEstimation``
     - Disabled
     - Enabled
     - Enabled
     - Tax Calculations
   * - ``multiBankAccounts``
     - Enabled
     - Enabled
     - Enabled
     - Universal Banking

Building Target Releases
------------------------

Using `make` (Recommended)
~~~~~~~~~~~~~~~~~~~~~~~~~~

A ``Makefile`` is provided to run, build, and test each target release edition easily:

.. code-block:: bash

    # Development Server / Desktop App
    make run-personal       # Run Personal Edition locally
    make run-business       # Run Business Edition locally
    make run-combined       # Run Combined Edition locally

    # Release Desktop Builds (Linux)
    make build-personal     # Build Linux executable for Personal Edition
    make build-business     # Build Linux executable for Business Edition
    make build-combined     # Build Linux executable for Combined Edition
    make build-all          # Build Linux executables for all 3 editions

    # Release Mobile Builds (Android APK)
    make build-personal-apk # Build Android APK for Personal Edition
    make build-business-apk # Build Android APK for Business Edition
    make build-combined-apk # Build Android APK for Combined Edition

    # Documentation & Testing
    make test               # Run full test suite
    make docs               # Generate diagrams and Sphinx HTML docs

Direct Flutter CLI Commands
~~~~~~~~~~~~~~~~~~~~~~~~~~~

To compile or run a specific release edition directly via Flutter CLI, supply the corresponding ``RELEASE_EDITION`` build parameter:

.. code-block:: bash

    # Personal Edition
    flutter run -d linux --dart-define=RELEASE_EDITION=personal

    # Business Edition
    flutter run -d linux --dart-define=RELEASE_EDITION=business

    # Combined Edition (Default)
    flutter run -d linux --dart-define=RELEASE_EDITION=combined

Data Safety & Schema Integrity
-------------------------------

Underlying SQLite database tables are kept intact across all release editions. Changing editions or restoring a backup file created in a different edition never drops or corrupts database tables, maintaining 100% data integrity.
