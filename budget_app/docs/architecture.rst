Architecture
============

Overview
--------

Budget App follows **Clean Architecture** principles with clear separation between UI, business logic, and data layers. The architecture ensures maintainability, testability, and scalability.

Layer Structure
---------------

.. code-block:: text

   lib/
   ├── core/                  # Shared utilities, feature flags, constants
   │   ├── constants/        # App-wide constants
   │   ├── feature_flags/    # Release editions and feature gating
   │   ├── theme/           # Material Design 3 theming
   │   └── utils/           # Currency, date, and chart utilities
   │
   ├── features/             # Feature modules
   │   ├── budget/          # Core budget functionality
   │   ├── settings/        # App settings
   │   ├── export/           # Data export
   │   ├── backup/          # Backup & restore
   │   ├── loans/           # Loan management
   │   ├── emergency_fund/  # Emergency fund calculator
   │   ├── financial_tools/ # Financial calculators
   │   └── business_tools/  # Invoices, clients, profiles
   │
   └── shared/              # Shared widgets and repositories

Each Feature Follows Clean Architecture
---------------------------------------

.. code-block:: text

   feature/
   ├── domain/                    # Business Logic Layer
   │   ├── entities/             # Business objects
   │   ├── repositories/         # Repository interfaces
   │   └── usecases/            # Business use cases
   │
   ├── data/                     # Data Layer
   │   ├── datasources/          # Local database (SQLite)
   │   ├── models/               # Data models
   │   └── repositories/         # Repository implementations
   │
   └── presentation/             # UI Layer
       ├── bloc/                 # BLoC state management
       ├── pages/               # Screen widgets
       └── widgets/             # Reusable UI components

Key Components
--------------

Domain Layer
~~~~~~~~~~~~

- **Entities**: Pure business objects (Budget, IncomeEntry, ExpenseEntry, Category)
- **Repositories**: Abstract interfaces for data operations
- **Use Cases**: Business logic implementations

Data Layer
~~~~~~~~~~

- **LocalDatabase**: SQLite database via sqflite package
- **Models**: Database-specific data representations
- **Repository Implementations**: Concrete data access implementations

Presentation Layer
~~~~~~~~~~~~~~~~~~

- **BLoC**: State management using flutter_bloc
- **Pages**: Full-screen widgets for each route
- **Widgets**: Reusable UI components

State Management
----------------

The app uses **BLoC (Business Logic Component)** pattern via flutter_bloc:

- **BudgetBloc**: Manages budget CRUD operations
- **NavigationBloc**: Handles period/budget navigation
- **CategoryBloc**: Manages categories
- **ProjectionBloc**: Handles financial projections
- **FeatureFlagsBloc**: Manages release edition targets and feature toggles
- **SettingsBloc**: App configuration state

Architecture Diagrams
---------------------

Decomposed DAO Database Architecture
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

.. mermaid::

   classDiagram
       class LocalDatabase {
           -Database _database
           -Completer~Database~ _databaseCompleter
           +instance LocalDatabase$
           +initialize() Future~void~$
           +database Future~Database~
           +initDatabase() Future~Database~
           -_onCreate(Database, int) Future~void~
           -_onUpgrade(Database, int, int) Future~void~
           +BudgetDao budgetDao
           +TransactionDao transactionDao
           +CategoryDao categoryDao
           +AccountDao accountDao
           +InvoiceDao invoiceDao
           +LoanDao loanDao
           +SavingsDao savingsDao
           +ReminderDao reminderDao
           +NetWorthDao netWorthDao
       }

       class BaseDao {
           <<abstract>>
           #Future~Database~ database
           +BaseDao(Future~Database~ Function() dbProvider)
       }

       class BudgetDao {
           +getBudgets() Future~List~
           +getBudgetById(String id) Future~Map?~
           +insertBudget(Map budget) Future~int~
           +updateBudget(Map budget) Future~int~
           +deleteBudget(String id) Future~int~
           +getCategoryLimits(String budgetId) Future~List~
           +getBudgetTemplates() Future~List~
       }

       class TransactionDao {
           +getIncomeEntries(String budgetId) Future~List~
           +getExpenseEntries(String budgetId) Future~List~
           +insertIncomeEntry(Map entry) Future~int~
           +insertExpenseEntry(Map entry) Future~int~
           +getRecurringTransactions(String budgetId) Future~List~
           +getSplits(String parentId) Future~List~
           +getTagsForTransaction(String id) Future~List~
           +getAttachments(String id) Future~List~
       }

       class CategoryDao {
           +getCategories(String? type) Future~List~
           +insertCategory(Map category) Future~int~
           +updateCategory(Map category) Future~int~
           +deleteCategory(String id) Future~int~
           +seedDefaultCategories() Future~void~
       }

       class AccountDao {
           +getAccounts() Future~List~
           +insertAccount(Map account) Future~int~
           +insertTransfer(Map transfer) Future~int~
           +getAccountTransactions(String accountId) Future~List~
           +getSavingsAccounts() Future~List~
           +getInvestmentPortfolios() Future~List~
       }

       class InvoiceDao {
           +getInvoices(String? status) Future~List~
           +insertInvoice(Map invoice) Future~int~
           +getInvoiceItems(String invoiceId) Future~List~
           +getInvoicePayments(String invoiceId) Future~List~
           +getClients() Future~List~
           +getCompanyProfile() Future~Map?~
           +getReceivedInvoices() Future~List~
       }

       class LoanDao {
           +getLoanAccounts() Future~List~
           +getLoanById(String accountId) Future~Map?~
           +insertLoanAccount(Map loan) Future~int~
           +updateLoanAccount(Map loan) Future~int~
           +getSavedCalculations(String type) Future~List~
       }

       class SavingsDao {
           +getSavingsGoals() Future~List~
           +insertSavingsGoal(Map goal) Future~int~
           +getContributions(String goalId) Future~List~
           +insertContribution(Map contribution) Future~int~
       }

       class ReminderDao {
           +getBillReminders() Future~List~
           +insertBillReminder(Map reminder) Future~int~
           +markReminderNotified(String id) Future~int~
       }

       class NetWorthDao {
           +getSnapshots() Future~List~
           +insertSnapshot(Map snapshot) Future~int~
           +getCreditCards() Future~List~
           +getInvestments() Future~List~
       }

       LocalDatabase --> BaseDao : delegates database provider
       BaseDao <|-- BudgetDao
       BaseDao <|-- TransactionDao
       BaseDao <|-- CategoryDao
       BaseDao <|-- AccountDao
       BaseDao <|-- InvoiceDao
       BaseDao <|-- LoanDao
       BaseDao <|-- SavingsDao
       BaseDao <|-- ReminderDao
       BaseDao <|-- NetWorthDao

       LocalDatabase *-- BudgetDao
       LocalDatabase *-- TransactionDao
       LocalDatabase *-- CategoryDao
       LocalDatabase *-- AccountDao
       LocalDatabase *-- InvoiceDao
       LocalDatabase *-- LoanDao
       LocalDatabase *-- SavingsDao
       LocalDatabase *-- ReminderDao
       LocalDatabase *-- NetWorthDao


BLoC State Orchestration and Data Flow
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

.. mermaid::

   flowchart TD
       subgraph UI_Presentation_Layer ["Presentation Layer (Flutter Widgets)"]
           UI_Home["HomeScreen / Dashboard"]
           UI_Nav["Navigation Drawer & Period Selector"]
           UI_Gate["FeatureGate & FeatureRouteGuard"]
           UI_Settings["SettingsPage (Theme & High Contrast)"]
           UI_Forms["Transaction & Invoice Forms"]
       end

       subgraph State_Orchestration_Layer ["State Orchestration Layer (BLoC)"]
           direction TB
           subgraph Global_Blocs ["Global Core BLoCs"]
               FeatureFlagsBloc["FeatureFlagsBloc<br/>(HydratedBloc)"]
               SettingsBloc["SettingsBloc<br/>(Theme, Currency, Contrast)"]
               NavigationBloc["NavigationBloc<br/>(Active Period & Budget ID)"]
               AppLockBloc["AppLockBloc<br/>(Biometric & PIN State)"]
           end

           subgraph Feature_Blocs ["Domain Feature BLoCs"]
               BudgetBloc["BudgetBloc<br/>(Income, Expense, Balance)"]
               CategoryBloc["CategoryBloc<br/>(Category Master Data)"]
               AccountBloc["AccountBloc<br/>(Multi-Bank & Transfers)"]
               BusinessBloc["BusinessBloc<br/>(Invoices & Clients)"]
               LoanBloc["LoanBloc<br/>(Loans & Amortization)"]
               SavingsBloc["SavingsBloc<br/>(Goals & Contributions)"]
           end
       end

       subgraph Domain_Services ["Domain Layer (Repositories & Services)"]
           GateService["FeatureGateService<br/>(Sync Flag Verification)"]
           BudgetRepo["BudgetRepository"]
           AccountRepo["AccountRepository"]
           InvoiceRepo["InvoiceRepository"]
           CategoryRepo["CategoryRepository"]
           LoanRepo["LoanRepository"]
       end

       subgraph Data_Access_Layer ["Data Layer (Decomposed DAOs)"]
           LocalDB["LocalDatabase Orchestrator<br/>(Connection, Migrations, PRAGMAs)"]
           BudgetDao["BudgetDao"]
           TxDao["TransactionDao"]
           AccountDao["AccountDao"]
           InvoiceDao["InvoiceDao"]
           CategoryDao["CategoryDao"]
           LoanDao["LoanDao"]
       end

       subgraph Persistence_Engines ["Persistence Layer"]
           SQLite[("SQLite Database<br/>(sqflite / sqflite_ffi)")]
           HydratedStore[("HydratedStorage<br/>(JSON Preferences Cache)")]
           SecureStore[("FlutterSecureStorage<br/>(Encrypted Keychain / Keystore)")]
       end

       UI_Nav -->|Select Period / Budget| NavigationBloc
       UI_Settings -->|Change Theme / Contrast| SettingsBloc
       UI_Forms -->|Add / Update Event| BudgetBloc
       UI_Forms -->|Invoice Event| BusinessBloc
       UI_Home -->|Render View| UI_Gate

       NavigationBloc -.->|PeriodChanged Notification| BudgetBloc
       FeatureFlagsBloc -->|Publish Active Flags| GateService
       UI_Gate -->|Check isFeatureEnabled| GateService

       BudgetBloc --> BudgetRepo
       CategoryBloc --> CategoryRepo
       AccountBloc --> AccountRepo
       BusinessBloc --> InvoiceRepo
       LoanBloc --> LoanRepo

       BudgetRepo --> BudgetDao
       BudgetRepo --> TxDao
       CategoryRepo --> CategoryDao
       AccountRepo --> AccountDao
       InvoiceRepo --> InvoiceDao
       LoanRepo --> LoanDao

       BudgetDao --> LocalDB
       TxDao --> LocalDB
       AccountDao --> LocalDB
       InvoiceDao --> LocalDB
       CategoryDao --> LocalDB
       LoanDao --> LocalDB
       LocalDB --> SQLite

       FeatureFlagsBloc --> HydratedStore
       SettingsBloc --> HydratedStore
       AppLockBloc --> SecureStore


SQLite Schema v28 Entity Relationships
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

.. mermaid::

   erDiagram
       BUDGETS ||--o{ INCOME_ENTRIES : "contains"
       BUDGETS ||--o{ EXPENSE_ENTRIES : "contains"
       BUDGETS ||--o{ BUDGET_GOALS : "defines"
       BUDGETS ||--o{ CATEGORY_LIMITS : "sets"
       BUDGETS ||--o{ RECURRING_TRANSACTIONS : "schedules"

       CATEGORIES ||--o{ INCOME_ENTRIES : "categorizes"
       CATEGORIES ||--o{ EXPENSE_ENTRIES : "categorizes"
       CATEGORIES ||--o{ BUDGET_GOALS : "targets"
       CATEGORIES ||--o{ CATEGORY_LIMITS : "restricts"
       CATEGORIES ||--o{ SAVINGS_GOALS : "links"
       CATEGORIES ||--o{ TRANSACTION_SPLITS : "allocates"
       CATEGORIES ||--o{ BUDGET_TEMPLATE_ALLOCATIONS : "allocates"

       RECURRING_TRANSACTIONS ||--o{ RECURRING_OVERRIDES : "overrides"
       RECURRING_TRANSACTIONS ||--o{ BILL_REMINDERS : "notifies"

       SAVINGS_GOALS ||--o{ SAVINGS_CONTRIBUTIONS : "receives"

       BUDGET_TEMPLATES ||--o{ BUDGET_TEMPLATE_ALLOCATIONS : "composes"

       TAGS ||--o{ TRANSACTION_TAGS : "labels"

       COMPANY_PROFILES ||--o{ INVOICES : "issues"
       CLIENTS ||--o{ INVOICES : "billed_to"
       INVOICES ||--o{ INVOICE_ITEMS : "contains"
       INVOICES ||--o{ INVOICE_PAYMENTS : "settles"

       ACCOUNTS ||--o{ TRANSFERS : "source_of"
       ACCOUNTS ||--o{ TRANSFERS : "dest_of"
       ACCOUNTS ||--o{ ACCOUNT_TRANSACTIONS : "logs"
       ACCOUNTS ||--o| LOAN_ACCOUNTS : "specializes"
       ACCOUNTS ||--o| SAVINGS_ACCOUNTS : "specializes"
       ACCOUNTS ||--o| INVESTMENT_PORTFOLIOS : "specializes"

       BUDGETS {
           string id PK
           string name
           int period_month
           int period_year
           int is_active
           string currency_code
           string target_currency_code
           float exchange_rate
           float converted_amount
           string type
           float target_income
           string source_description
           string linked_income_id
       }

       INCOME_ENTRIES {
           string id PK
           string budget_id FK
           float amount
           string description
           string date
           int period_month
           int period_year
           string category_id FK
           int is_potential
       }

       EXPENSE_ENTRIES {
           string id PK
           string budget_id FK
           float amount
           string description
           string date
           int period_month
           int period_year
           string category_id FK
           int is_potential
       }

       CATEGORIES {
           string id PK
           string name
           string icon
           string type
       }

       CATEGORY_LIMITS {
           string id PK
           string budget_id FK
           string category_id FK
           float amount
           string period
           string created_at
           string updated_at
       }

       SAVINGS_GOALS {
           string id PK
           string name
           float target_amount
           float current_amount
           string deadline
           string linked_category_id FK
           string icon
           string color
           int is_completed
           string created_at
           string updated_at
       }

       SAVINGS_CONTRIBUTIONS {
           string id PK
           string goal_id FK
           float amount
           string date
           string note
           string created_at
       }

       RECURRING_TRANSACTIONS {
           string id PK
           string budget_id FK
           string type
           float amount
           string category_id FK
           string description
           string start_date
           string end_date
           int recurrence_interval
           string recurrence_unit
       }

       RECURRING_OVERRIDES {
           string id PK
           string recurring_transaction_id FK
           string target_date
           float new_amount
           string new_date
           int is_deleted
       }

       BILL_REMINDERS {
           string id PK
           string recurring_transaction_id FK
           string due_date
           int days_before_due
           int is_notified
           string notified_at
           string created_at
       }

       INVOICES {
           string id PK
           string profile_id FK
           string client_id FK
           string invoice_number
           string date
           string client_name
           string client_details
           string status
           float sub_total
           float tax_total
           float grand_total
           string notes
           float balance_due
           string bank_name
           string bank_iban
           string bank_bic
           string bank_holder
       }

       INVOICE_ITEMS {
           string id PK
           string invoice_id FK
           string description
           float quantity
           float rate
           float tax_rate
           float total
       }

       INVOICE_PAYMENTS {
           string id PK
           string invoice_id FK
           float amount
           string date
           string method
       }

       CLIENTS {
           string id PK
           string name
           string address
           string tax_id
           string primary_contact
           string email
           string phone
           string website
           string industry
           string notes
       }

       COMPANY_PROFILES {
           string id PK
           string name
           string address
           string tax_id
           string logo_path
           string payment_info
           float default_vat_rate
           string bank_name
           string bank_iban
           string bank_bic
           string bank_holder
           int primary_color
           string font_family
           int logo_on_right
       }

       ACCOUNTS {
           string id PK
           string name
           string type
           float balance
           string currency
           int created_at
           int updated_at
       }

       TRANSFERS {
           string id PK
           string from_account_id FK
           string to_account_id FK
           float amount
           int date
           string note
           int created_at
       }

       LOAN_ACCOUNTS {
           string account_id PK,FK
           float original_principal
           float current_principal
           float interest_rate_apr
           float minimum_monthly_payment
           int origination_date
           int is_paid_off
       }

       SAVINGS_ACCOUNTS {
           string account_id PK,FK
           float interest_rate_apy
           string compounding_frequency
           float target_goal_amount
           float total_contributions
       }

       INVESTMENT_PORTFOLIOS {
           string account_id PK,FK
           float total_market_value
           float total_deposited
           float total_withdrawn
           float target_annual_return_rate
       }

       ACCOUNTS ||--o{ INCOME_ENTRIES : "funds"
       ACCOUNTS ||--o{ EXPENSE_ENTRIES : "charged to"

Transaction Account Filter Data Flow
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

.. mermaid::

   sequenceDiagram
       autonumber
       actor User
       participant FilterBar as FilterBar Widget
       participant FilterSheet as AccountFilterSheet
       participant FilterUtils as FilterUtils

       User->>FilterBar: Tap Account Filter Button
       FilterBar->>FilterSheet: Open modal with accounts list
       User->>FilterSheet: Select Accounts A, B + Tap Apply
       FilterSheet-->>FilterBar: AccountFilter(selectedAccountIds: {A, B})
       FilterBar->>FilterUtils: filterIncomeEntries(entries, filterState)
       FilterBar->>FilterUtils: filterExpenseEntries(entries, filterState)
       FilterUtils-->>FilterBar: Return filtered transaction subsets
       FilterBar->>User: Render filtered lists & updated summary totals

Database Schema
---------------

Main Tables
~~~~~~~~~~~

- **budgets**: Budget periods and metadata
- **income_entries**: Income transactions (with optional account_id FK)
- **expense_entries**: Expense transactions (with optional account_id FK)
- **categories**: Income and expense categories
- **recurring_transactions**: Recurring transaction definitions
- **budget_goals**: Category budget limits
- **invoices**: Business invoices (business tools)
- **clients**: Business clients (business tools)
- **company_profiles**: Business company profiles
- **accounts**: Bank and financial accounts
- **transfers**: Transfers between accounts
- **savings_goals**: Savings targets and progress
- **savings_contributions**: Goal contributions
- **bill_reminders**: Upcoming bill reminder alerts
- **loan_accounts**: Loans and liability tracking

Database Version
~~~~~~~~~~~~~~~~

Current schema version: 29

Migrations are handled in ``LocalDatabase._onUpgrade()`` following constitutional requirements.

Theme
-----

The app uses **Material Design 3** with custom theming:

- Light, Dark, OLED Dark, and High Contrast mode support
- Custom color scheme for income (green), expenses (red), balance (blue)
- Accessible color combinations meeting WCAG 2.1 AA contrast requirements

Security
--------

- **flutter_secure_storage**: Sensitive data encryption
- **local_auth**: Biometric authentication (fingerprint, Face ID)
- **App Lock**: PIN/biometric app protection

Offline-First Architecture
--------------------------

All data is stored locally on the device using SQLite. No cloud sync is implemented, ensuring user privacy and offline functionality.

Backup Strategy
~~~~~~~~~~~~~~~

- Export to local file system (CSV, PDF, Excel)
- Full database backup and restore
- Share functionality via system share sheet
