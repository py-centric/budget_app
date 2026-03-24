class ImportResult {
  final bool success;
  final int tablesImported;
  final int recordsImported;
  final String? errorMessage;

  const ImportResult({
    required this.success,
    this.tablesImported = 0,
    this.recordsImported = 0,
    this.errorMessage,
  });

  factory ImportResult.failure(String error) =>
      ImportResult(success: false, errorMessage: error);
}
