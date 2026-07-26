# System Architecture & Feature Gating Diagram

```mermaid
graph TD
    subgraph Build & Automation Layer
        MakeTarget["Makefile Targets<br/>(make run-personal | build-business | build-all)"]
        CompileFlag["Compile Target Flag<br/>(--dart-define=RELEASE_EDITION=...)"]
        MakeTarget --> CompileFlag
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
