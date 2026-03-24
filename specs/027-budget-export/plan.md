# Implementation Plan: Budget Export

**Branch**: `027-budget-export` | **Date**: 2026-03-24 | **Spec**: [spec.md](./spec.md)
**Input**: Feature specification from `/specs/027-budget-export/spec.md`

## Summary

**Primary Requirement**: Implement ability to export budgets to Excel, CSV, and PDF formats with period selection and sharing capabilities.

**Technical Approach**: Use existing `pdf` package for PDF generation, add `csv` package for CSV export, add `excel` package for Excel export, and use Flutter's share functionality for sharing. Export data from SQLite via existing budget repository.

## Technical Context

**Language/Version**: Dart 3.x (Flutter 3.x)  
**Primary Dependencies**: csv (new), excel (new), pdf (existing), path_provider (existing), share_plus (new)  
**Storage**: Local file system (export to device storage)  
**Testing**: flutter_test, mocktail (existing)  
**Target Platform**: iOS 15+, Android (latest stable)  
**Project Type**: Mobile-app (Flutter)  
**Performance Goals**: Export completes in under 10 seconds for typical monthly data  
**Constraints**: Offline-only, no cloud sync, export to local storage  
**Scale/Scope**: Single user, local export

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

| Gate | Status | Notes |
|------|--------|-------|
| Use Flutter/Dart | ✅ PASS | Feature uses Dart with Flutter framework per constitution |
| Offline-First Architecture | ✅ PASS | All exports to local storage; no external APIs |
| SQLite Storage | ✅ PASS | Reuses existing SQLite database via budget repository |
| Clean Architecture | ✅ PASS | Feature follows Clean Architecture pattern |
| License Compliance | ✅ PASS | csv (MIT), excel (MIT), pdf (MIT), share_plus (BSD-3-Clause) |

**Constitution Alignment**: All gates pass. No violations detected.

## Project Structure

### Documentation (this feature)

```text
specs/027-budget-export/
├── plan.md              # This file (/speckit.plan command output)
├── research.md          # Phase 0 output (/speckit.plan command)
├── data-model.md        # Phase 1 output (/speckit.plan command)
├── quickstart.md        # Phase 1 output (/speckit.plan command)
├── contracts/           # Phase 1 output (/speckit.plan command)
└── tasks.md             # Phase 2 output (/speckit.tasks command - NOT created by /speckit.plan)
```

### Source Code (repository root)

```text
lib/
├── main.dart
├── app.dart
├── core/
│   └── constants/
├── features/
│   ├── budget/                    # Existing feature
│   │   └── data/repositories/    # BudgetRepository for data access
│   └── export/                   # NEW feature
│       ├── presentation/
│       │   ├── bloc/
│       │   ├── pages/
│       │   └── widgets/
│       └── domain/
│           ├── entities/
│           └── services/
└── shared/
    └── widgets/

test/
├── unit/
└── widget/
```

**Structure Decision**: New feature module `export/` with Clean Architecture (presentation/domain layers). Reuses existing budget data through BudgetRepository.

## Complexity Tracking

No complexity tracking needed - no constitution violations.

---

# Phase 0: Research

## Research Findings

### 1. CSV Export
- **Decision**: Use `csv` package for CSV generation
- **Rationale**: Well-maintained Dart package, MIT licensed, supports UTF-8 encoding
- **Alternatives Considered**: Manual string formatting (error-prone), csv (best fit)

### 2. Excel Export
- **Decision**: Use `excel` package for Excel (.xlsx) generation
- **Rationale**: Creates proper xlsx files, supports formatting and styles, MIT licensed
- **Alternatives Considered**: xlsx (less maintained), xlsx_writer (deprecated)

### 3. PDF Export
- **Decision**: Use existing `pdf` package
- **Rationale**: Already in project dependencies, handles PDF generation well
- **Alternatives Considered**: pdfmake (less flexible), printing (for sharing)

### 4. File Sharing
- **Decision**: Use `share_plus` package for cross-platform sharing
- **Rationale**: Flutter's recommended sharing solution, BSD-3-Clause licensed, works on iOS/Android
- **Alternatives Considered**: Platform channels (overkill), url_launcher (limited)

### 5. Data Access
- **Decision**: Reuse existing BudgetRepository
- **Rationale**: Already has methods to fetch transactions by period, follows Clean Architecture
- **Alternatives Considered**: New repository (duplication), direct DB access (violates architecture)

---

# Phase 1: Design & Contracts

## Data Model

### ExportConfiguration
| Field | Type | Description |
|-------|------|-------------|
| `periodType` | Enum | 'currentMonth', 'customRange', 'allTime' |
| `startDate` | DateTime? | Start date for custom range |
| `endDate` | DateTime? | End date for custom range |
| `format` | Enum | 'csv', 'pdf', 'excel' |

### BudgetExport
| Field | Type | Description |
|-------|------|-------------|
| `format` | ExportFormat | CSV, PDF, or Excel |
| `dateRange` | DateTimeRange | Exported period |
| `filePath` | String | Path to generated file |
| `generatedAt` | DateTime | File generation timestamp |
| `recordCount` | int | Number of transactions exported |

### ExportFormat
| Value | Description |
|-------|-------------|
| `csv` | Comma-separated values |
| `pdf` | PDF document |
| `excel` | Microsoft Excel (.xlsx) |

### ExportPeriod
| Value | Description |
|-------|-------------|
| `currentMonth` | Current calendar month |
| `customRange` | User-specified date range |
| `allTime` | All historical transactions |

## State Transitions

```
User selects export
    │
    ▼
Configure Export (select period, format)
    │
    ▼
Generate File (show progress if >1000 records)
    │
    ├─► Success: Save to storage, show success
    │
    └─► Failure: Show error message
```

## Interface Contracts

### ExportBloc Events
- `ExportLoadData(period)` - Load transactions for period
- `ExportGenerate(format, period)` - Generate export file
- `ExportShare()` - Share generated file
- `ExportSave()` - Save to device storage

### ExportBloc States
- `ExportInitial` - Initial state
- `ExportLoading` - Loading data
- `ExportGenerating(progress)` - Generating file
- `ExportSuccess(file)` - Export complete
- `ExportError(message)` - Export failed

### ExportService Interface
```dart
abstract class ExportService {
  Future<String> generateCsv(List<Transaction> transactions);
  Future<String> generatePdf(List<Transaction> transactions, BudgetSummary summary);
  Future<String> generateExcel(List<Transaction> transactions, BudgetSummary summary);
  Future<void> shareFile(String filePath);
  Future<String> saveFile(String filePath, String fileName);
}
```

## Quickstart

### Developer Setup
1. Add dependencies: `csv`, `excel`, `share_plus`
2. Run `flutter pub get`
3. Implement ExportService in domain layer
4. Create ExportBloc for state management
5. Add export button to budget period view

### Integration Scenarios
1. **Export CSV**: User selects CSV → system generates → user saves/shares
2. **Export PDF**: User selects PDF → system generates report → user views/shares
3. **Export Excel**: User selects Excel → system generates with formatting → user saves/shares

### Test Scenarios
1. Export current month to CSV - verify all transactions included
2. Export custom date range to PDF - verify date range correct
3. Export all time to Excel - verify categories color-coded
4. Share exported file - verify share sheet opens
5. Large dataset export (1000+ transactions) - verify progress shown
