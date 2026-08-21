#!/usr/bin/env python3
"""
Diagram and Documentation Generator for Budget App.
Generates Mermaid architecture diagrams, Sphinx structure files, and visual maps.
"""

import os
from pathlib import Path

DOCS_DIR = Path(__file__).parent.resolve()
DIAGRAMS_DIR = DOCS_DIR / "diagrams"

MERMAID_SYSTEM_ARCHITECTURE = """```mermaid
graph TD
    subgraph Build & Automation Layer
        TaskTarget["Taskfile Tasks<br/>(task dev:personal | build:business | build:all)"]
        CompileFlag["Compile Target Flag<br/>(--dart-define=RELEASE_EDITION=...)"]
        TaskTarget --> CompileFlag
    end

    subgraph Feature Gating Engine
        MappingRegistry["DefaultFeatureMapping Registry"]
        BlocState["FeatureFlagsBloc (HydratedBloc)"]
        GateService["FeatureGateService (Sync API)"]

        CompileFlag --> MappingRegistry
        MappingRegistry --> BlocState
        BlocState --> GateService
    end

    subgraph Client Application Layer
        UI["Flutter Presentation Layer<br/>(Material Design 3 Theme)"]
        Nav["Navigation Drawer & Routing"]
        GateWidget["FeatureGate Widget"]
        Guard["FeatureRouteGuard"]

        UI --> GateWidget
        UI --> Guard
        GateWidget --> GateService
        Guard --> GateService
    end

    subgraph Feature Modules (29 Clean Architecture Modules)
        Personal["Personal Domain<br/>(Budgeting, Savings, Loans, Debt Payoff)"]
        Business["Business Domain<br/>(Invoicing, Payables, Reconciliation)"]
        Universal["Universal Domain<br/>(Accounts, Backup, Export, Calculators)"]

        GateService --> Personal
        GateService --> Business
        GateService --> Universal
    end

    subgraph Offline Persistence Layer
        SQLite[("Local SQLite Database<br/>(sqflite / sqflite_ffi)")]
        SecureStore[("Flutter Secure Storage<br/>(Encrypted PIN & Keys)")]
        HydratedStore[("HydratedBloc Cache<br/>(Theme & Edition Overrides)")]

        Personal --> SQLite
        Business --> SQLite
        Universal --> SQLite
        UI --> SecureStore
        BlocState --> HydratedStore
    end
```
"""

MERMAID_FEATURE_GATE_SEQUENCE = """```mermaid
sequenceDiagram
    autonumber
    actor Developer
    participant Task as Taskfile / CLI
    participant View as UI Component / Route
    participant Gate as FeatureGate Widget
    participant Service as FeatureGateService
    participant Bloc as FeatureFlagsBloc
    participant DB as SQLite Local Database

    Developer->>Task: Execute 'task dev:personal' / 'task build:business'
    Task->>Bloc: Passes RELEASE_EDITION flag to App Target
    View->>Gate: Evaluate Feature Flag Check
    Gate->>Service: isFeatureEnabled(flag)
    Service->>Bloc: Read effective state (Build flag + Hydrated override)
    Bloc-->>Service: FeatureFlagsState (activeFlags map)
    Service-->>Gate: boolean (enabled/disabled)

    alt Feature Enabled
        Gate-->>View: Render Feature Widget / Route Content
        View->>DB: Query Local Data Tables
        DB-->>View: Return Records
    else Feature Disabled
        Gate-->>View: Render Fallback / Redirect Guard
    end
```
"""

MERMAID_TASKFILE_WORKFLOW = """```mermaid
flowchart LR
    subgraph Developer Tasks
        T1["task dev:personal"]
        T2["task dev:business"]
        T3["task dev:combined"]
        T4["task build:all"]
        T5["task docs"]
    end

    subgraph Build Actions
        A1["flutter run --dart-define=RELEASE_EDITION=personal"]
        A2["flutter run --dart-define=RELEASE_EDITION=business"]
        A3["flutter run --dart-define=RELEASE_EDITION=combined"]
        A4["flutter build linux (all 3 editions)"]
        A5["python3 generate_diagrams.py + sphinx-build"]
    end

    subgraph Artifact Outputs
        O1["Personal Dev App"]
        O2["Business Dev App"]
        O3["Combined Dev App"]
        O4["Linux Release Bundles"]
        O5["Sphinx HTML Docs"]
    end

    T1 --> A1 --> O1
    T2 --> A2 --> O2
    T3 --> A3 --> O3
    T4 --> A4 --> O4
    T5 --> A5 --> O5
```
"""

MERMAID_BUDGET_USECASE_FLOW = """```mermaid
flowchart TD
    Start([User Action in Drawer]) --> Choice{Select Action}

    Choice -->|Create Budget| Create[Enter Name, Month & Year]
    Choice -->|Navigate Period| Nav[Select Target Month & Year]
    Choice -->|Duplicate Budget| Copy[Select Source & Target Period]

    Create --> SaveDB[Insert Budget into SQLite DB]
    Nav --> FetchDB[Query Active Period in SQLite DB]
    Copy --> CopyDB[Copy Categories & Limits to Target Period]

    SaveDB --> Refresh[Refresh Home UI Dashboard & Navigation State]
    FetchDB --> Refresh
    CopyDB --> Refresh
```
"""

MERMAID_TRANSACTION_USECASE_FLOW = """```mermaid
flowchart TD
    Start([Add Transaction Action]) --> Type{Select Entry Type}

    Type -->|Income / Expense| Form[Input Amount, Category & Date]
    Type -->|Potential Entry| Planned[Input Planned Amount & Date]

    Form --> SaveActual[Save Actual Entry to SQLite DB]
    Planned --> SavePotential[Save Potential Entry with isPotential=true]

    SavePotential --> Confirm{User Confirms Actual Execution?}
    Confirm -->|Yes| UpdatePotential[Set isPotential=false in SQLite DB]

    SaveActual --> Recalc[Recalculate Period Income & Expense Totals]
    UpdatePotential --> Recalc
    Recalc --> UpdateUI[Update Balance Cards & Progress Bars]
```
"""

MERMAID_INVOICE_USECASE_FLOW = """```mermaid
flowchart TD
    Start([Create Invoice]) --> AddDetails[Add Client, Line Items, Tax & Discount]
    AddDetails --> Draft[Status: DRAFT]

    Draft --> Choice{Next Action}
    Choice -->|Export PDF| PDF[Generate Structured PDF Document]
    Choice -->|Send to Client| Sent[Status: SENT / PENDING]

    Sent --> CheckDue{Check Due Date}
    CheckDue -->|Past Due Date| Overdue[Status: OVERDUE]
    CheckDue -->|Payment Received| Paid[Status: PAID]

    Overdue --> Remind[Trigger Payment Notification]
    Paid --> RecordIncome[Automatically Record Income Transaction in DB]
```
"""

MERMAID_DAO_DATABASE_LAYOUT = """```mermaid
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
```
"""

MERMAID_BLOC_STATE_ORCHESTRATION = """```mermaid
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
```
"""

MERMAID_ENTITY_RELATIONSHIPS = """```mermaid
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
```
"""

def generate_diagram_files():
    """Create diagram directory and export Mermaid markdown assets."""
    os.makedirs(DIAGRAMS_DIR, exist_ok=True)

    diagram_mapping = {
        "architecture_system.md": ("# System Architecture & Feature Gating Diagram\n\n", MERMAID_SYSTEM_ARCHITECTURE),
        "feature_gating_sequence.md": ("# Feature Gate Execution Sequence Diagram\n\n", MERMAID_FEATURE_GATE_SEQUENCE),
        "taskfile_workflow.md": ("# Taskfile Build & Execution Workflow Diagram\n\n", MERMAID_TASKFILE_WORKFLOW),
        "budget_usecase_flow.md": ("# Budget Management Use Case Flow Diagram\n\n", MERMAID_BUDGET_USECASE_FLOW),
        "transaction_usecase_flow.md": ("# Transaction Lifecycle Use Case Flow Diagram\n\n", MERMAID_TRANSACTION_USECASE_FLOW),
        "invoice_usecase_flow.md": ("# Invoice Management Use Case Flow Diagram\n\n", MERMAID_INVOICE_USECASE_FLOW),
        "dao_database_layout.md": ("# Refactored DAO Database Architecture Diagram\n\n", MERMAID_DAO_DATABASE_LAYOUT),
        "bloc_state_orchestration.md": ("# BLoC State Orchestration & Data Flow Diagram\n\n", MERMAID_BLOC_STATE_ORCHESTRATION),
        "entity_relationships.md": ("# Complete SQLite Schema v28 Entity Relationship Diagram\n\n", MERMAID_ENTITY_RELATIONSHIPS),
    }

    for filename, (header, content) in diagram_mapping.items():
        filepath = DIAGRAMS_DIR / filename
        with open(filepath, "w", encoding="utf-8") as f:
            f.write(header)
            f.write(content)

    print(f"Successfully generated {len(diagram_mapping)} diagram assets in {DIAGRAMS_DIR}")

if __name__ == "__main__":
    generate_diagram_files()
