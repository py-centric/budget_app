# Interface Contracts: Budget Export

## ExportBloc

### Events

```dart
abstract class ExportEvent extends Equatable {
  const ExportEvent();
  
  @override
  List<Object?> get props => [];
}

/// Load transactions for selected period
class ExportLoadData extends ExportEvent {
  final ExportPeriod period;
  final DateTime? startDate;
  final DateTime? endDate;
  
  const ExportLoadData({
    required this.period,
    this.startDate,
    this.endDate,
  });
  
  @override
  List<Object?> get props => [period, startDate, endDate];
}

/// Generate export file
class ExportGenerate extends ExportEvent {
  final ExportFormat format;
  
  const ExportGenerate({required this.format});
  
  @override
  List<Object?> get props => [format];
}

/// Share the generated file
class ExportShare extends ExportEvent {}

/// Save file to device storage
class ExportSave extends ExportEvent {}

/// Reset export state
class ExportReset extends ExportEvent {}
```

### States

```dart
abstract class ExportState extends Equatable {
  const ExportState();
  
  @override
  List<Object?> get props => [];
}

/// Initial state - ready to configure
class ExportInitial extends ExportState {}

/// Loading transaction data
class ExportLoading extends ExportState {
  final String message;
  
  const ExportLoading({this.message = 'Loading data...'});
  
  @override
  List<Object?> get props => [message];
}

/// Generating export file
class ExportGenerating extends ExportState {
  final int progress; // 0-100
  final String message;
  
  const ExportGenerating({
    required this.progress,
    this.message = 'Generating file...',
  });
  
  @override
  List<Object?> get props => [progress, message];
}

/// Export completed successfully
class ExportSuccess extends ExportState {
  final String filePath;
  final String fileName;
  final ExportFormat format;
  final int recordCount;
  
  const ExportSuccess({
    required this.filePath,
    required this.fileName,
    required this.format,
    required this.recordCount,
  });
  
  @override
  List<Object?> get props => [filePath, fileName, format, recordCount];
}

/// Export failed
class ExportError extends ExportState {
  final String message;
  
  const ExportError({required this.message});
  
  @override
  List<Object?> get props => [message];
}
```

## ExportService Interface

```dart
abstract class ExportService {
  /// Generate CSV file from transactions
  /// Returns path to generated file
  Future<String> generateCsv(
    List<Transaction> transactions,
    ExportConfiguration config,
  );
  
  /// Generate PDF file from transactions
  /// Returns path to generated file
  Future<String> generatePdf(
    List<Transaction> transactions,
    BudgetSummary summary,
    ExportConfiguration config,
  );
  
  /// Generate Excel file from transactions
  /// Returns path to generated file
  Future<String> generateExcel(
    List<Transaction> transactions,
    BudgetSummary summary,
    ExportConfiguration config,
  );
  
  /// Share file using system share sheet
  Future<void> shareFile(String filePath);
  
  /// Save file to documents directory
  /// Returns final file path
  Future<String> saveFile(String sourcePath, String fileName);
  
  /// Delete temporary export file
  Future<void> deleteFile(String filePath);
}
```

## BudgetRepository Interface (Extensions)

```dart
/// Extension to BudgetRepository for export functionality
extension BudgetRepositoryExport on BudgetRepository {
  /// Get all transactions within a date range
  Future<List<Transaction>> getTransactionsByDateRange(
    DateTime startDate,
    DateTime endDate,
  );
  
  /// Get transactions for current month
  Future<List<Transaction>> getCurrentMonthTransactions();
  
  /// Get all transactions (all time)
  Future<List<Transaction>> getAllTransactions();
}
```

## File Naming Convention

Generated files follow this pattern:

```
budget_export_{format}_{period}_{timestamp}.{ext}

Examples:
- budget_export_csv_march_2026_20260324_143022.csv
- budget_export_pdf_alltime_20260324_143022.pdf
- budget_export_excel_custom_20260301_20260324_20260324_143022.xlsx
```
