# Data Model: Budget Export

## Export Entities

### ExportConfiguration
| Field | Type | Description |
|-------|------|-------------|
| `periodType` | `ExportPeriod` | Period selection type |
| `startDate` | `DateTime?` | Start date for custom range |
| `endDate` | `DateTime?` | End date for custom range |
| `format` | `ExportFormat` | Output format (CSV/PDF/Excel) |

### BudgetExport
| Field | Type | Description |
|-------|------|-------------|
| `format` | `ExportFormat` | File format |
| `period` | `ExportPeriod` | Selected period |
| `filePath` | `String` | Path to generated file |
| `generatedAt` | `DateTime` | Generation timestamp |
| `recordCount` | `int` | Number of transactions |
| `totalIncome` | `double` | Total income amount |
| `totalExpenses` | `double` | Total expenses amount |
| `balance` | `double` | Net balance |

## Enums

### ExportFormat
```dart
enum ExportFormat {
  csv,   // Comma-separated values
  pdf,   // PDF document
  excel, // Microsoft Excel (.xlsx)
}
```

### ExportPeriod
```dart
enum ExportPeriod {
  currentMonth, // Current calendar month
  customRange,  // User-specified date range
  allTime,      // All historical transactions
}
```

## State Transitions

### Export Flow
```
User selects export
    │
    ▼
Configure Export
  (period + format)
    │
    ▼
Load Transactions
  (from repository)
    │
    ▼
Generate File
  (format-specific)
    │
    ├─► Success
    │     │
    │     ▼
    │   Share/Save
    │     │
    │     ▼
    │   Complete
    │
    └─► Failure
          │
          ▼
        Show Error
```

### Export States
| State | Description |
|-------|-------------|
| `ExportInitial` | Ready to configure |
| `ExportLoading` | Fetching transaction data |
| `ExportGenerating` | Creating export file |
| `ExportSharing` | Opening share sheet |
| `ExportSuccess` | File ready |
| `ExportError` | Failed with message |

## Persistence

- Export files stored in app's documents directory via `path_provider`
- Files can be shared via `share_plus`
- No permanent storage of export metadata needed (stateless)
- Temporary files cleaned up after successful share/save

## Data Source

- Transactions fetched from existing `BudgetRepository`
- Period filtering applied at repository level
- Summary calculations done in domain layer
