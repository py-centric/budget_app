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
"""

MERMAID_FEATURE_GATE_SEQUENCE = """```mermaid
sequenceDiagram
    autonumber
    actor Developer
    participant Make as Makefile / CLI
    participant View as UI Component / Route
    participant Gate as FeatureGate Widget
    participant Service as FeatureGateService
    participant Bloc as FeatureFlagsBloc
    participant DB as SQLite Local Database

    Developer->>Make: Execute 'make run-personal' / 'make build-business'
    Make->>Bloc: Passes RELEASE_EDITION flag to App Target
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

MERMAID_MAKEFILE_WORKFLOW = """```mermaid
flowchart LR
    subgraph Developer Commands
        M1["make run-personal"]
        M2["make run-business"]
        M3["make run-combined"]
        M4["make build-all"]
        M5["make docs"]
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

    M1 --> A1 --> O1
    M2 --> A2 --> O2
    M3 --> A3 --> O3
    M4 --> A4 --> O4
    M5 --> A5 --> O5
```
"""

def generate_diagram_files():
    """Create diagram directory and export Mermaid markdown assets."""
    os.makedirs(DIAGRAMS_DIR, exist_ok=True)

    arch_file = DIAGRAMS_DIR / "architecture_system.md"
    seq_file = DIAGRAMS_DIR / "feature_gating_sequence.md"
    make_file = DIAGRAMS_DIR / "makefile_workflow.md"

    with open(arch_file, "w", encoding="utf-8") as f:
        f.write("# System Architecture & Feature Gating Diagram\n\n")
        f.write(MERMAID_SYSTEM_ARCHITECTURE)

    with open(seq_file, "w", encoding="utf-8") as f:
        f.write("# Feature Gate Execution Sequence Diagram\n\n")
        f.write(MERMAID_FEATURE_GATE_SEQUENCE)

    with open(make_file, "w", encoding="utf-8") as f:
        f.write("# Makefile Build & Execution Workflow Diagram\n\n")
        f.write(MERMAID_MAKEFILE_WORKFLOW)

    print(f"✅ Successfully generated diagrams in {DIAGRAMS_DIR}")

if __name__ == "__main__":
    generate_diagram_files()
