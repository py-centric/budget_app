# Implementation Plan: Business Tools Sidebar & Client CRM

**Branch**: `022-business-tools-sidebar-clients-clone` | **Date**: 2026-03-15 | **Spec**: [specs/022-business-tools-sidebar-clients-clone/spec.md](specs/022-business-tools-sidebar-clients-clone/spec.md)
**Input**: Feature specification from `/specs/022-business-tools-sidebar-clients-clone/spec.md`

## Summary

The goal is to elevate "Business Tools" to a top-level feature in the sidebar using an expandable `ExpansionTile`, implement a comprehensive Client CRM with extended fields, and add deep-copy invoice cloning capabilities. Technical approach involves SQLite schema migrations (v14), adding a `clients` table, extending the `BusinessBloc` for CRM state, and implementing a use case for atomic invoice duplication.

## Technical Context

**Language/Version**: Dart 3.x / Flutter 3.x  
**Primary Dependencies**: `flutter_bloc`, `sqflite`, `uuid`, `intl`  
**Storage**: SQLite (via `sqflite`) for Client data and updated Invoice relationships.  
**Testing**: `flutter_test`, `mocktail`  
**Target Platform**: Android, iOS, Linux, MacOS, Windows  
**Project Type**: mobile-app  
**Performance Goals**: <30s for invoice creation via client selection; smooth list rendering for 500+ clients.  
**Constraints**: Offline-capable; must follow feature-first Clean Architecture.  
**Scale/Scope**: 3 new screens (Client List, Client Edit, Business Hub), 1 refactored navigation drawer, 1 updated builder.

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

1. **Tech Stack Compliance**: Uses standard project stack (Flutter + Bloc + SQLite). (PASS)
2. **Offline-First**: All CRM and Invoice data remains on-device. (PASS)
3. **Local Storage**: Requires new `clients` table and column additions to `invoices`. Migration path needed (v14). (PASS)
4. **Project Structure**: Follows `lib/features/business_tools/` structure. (PASS)
5. **Testing**: Aiming for 80% coverage on new Client domain logic. (PASS)

## Project Structure

### Documentation (this feature)

```text
specs/022-business-tools-sidebar-clients-clone/
├── plan.md              # This file
├── research.md          # Phase 0 output
├── data-model.md        # Phase 1 output
├── quickstart.md        # Phase 1 output
├── contracts/           # Phase 1 output
└── tasks.md             # Phase 2 output (created by /speckit.tasks)
```

### Source Code (repository root)

```text
budget_app/
├── lib/
│   ├── features/
│   │   ├── budget/
│   │   │   └── presentation/
│   │   │       └── widgets/
│   │   │           └── navigation_drawer_widget.dart  # Update for US1
│   │   └── business_tools/
│   │       ├── data/
│   │       │   ├── models/
│   │       │   │   └── client_model.dart              # New for US2
│   │       │   └── repositories/
│   │       │       └── business_repository_impl.dart  # Update for US2/US3
│   │       ├── domain/
│   │       │   ├── entities/
│   │       │   │   └── client.dart                    # New for US2
│   │       │   ├── repositories/
│   │       │   │   └── business_repository.dart       # Update for US2/US3
│   │       │   └── usecases/
│   │       │       ├── manage_clients.dart            # New for US2
│   │       │       └── clone_invoice.dart             # New for US3
│   │       └── presentation/
│   │           ├── bloc/                              # Update for US2/US3
│   │           ├── pages/
│   │           │   ├── clients_page.dart              # New for US2
│   │           │   ├── client_edit_page.dart          # New for US2
│   │           │   ├── business_tools_page.dart       # Refactor for US1
│   │           │   └── invoice_builder_page.dart      # Update for US2/US3
│   │           └── widgets/
│   │               └── client_selector_dialog.dart    # New for US2
```

**Structure Decision**: Single project following feature-first Clean Architecture.

## Complexity Tracking

*None.*
