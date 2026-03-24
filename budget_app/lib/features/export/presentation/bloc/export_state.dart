import 'package:equatable/equatable.dart';
import '../../domain/entities/export_configuration.dart';

enum ExportStatus {
  initial,
  configured,
  loading,
  generating,
  success,
  sharing,
  error,
}

class ExportState extends Equatable {
  final ExportStatus status;
  final ExportConfiguration? configuration;
  final String? filePath;
  final String? errorMessage;
  final int progress;
  final List<Map<String, dynamic>> transactions;
  final Map<String, dynamic>? summary;

  const ExportState({
    this.status = ExportStatus.initial,
    this.configuration,
    this.filePath,
    this.errorMessage,
    this.progress = 0,
    this.transactions = const [],
    this.summary,
  });

  ExportState copyWith({
    ExportStatus? status,
    ExportConfiguration? configuration,
    String? filePath,
    String? errorMessage,
    int? progress,
    List<Map<String, dynamic>>? transactions,
    Map<String, dynamic>? summary,
  }) {
    return ExportState(
      status: status ?? this.status,
      configuration: configuration ?? this.configuration,
      filePath: filePath ?? this.filePath,
      errorMessage: errorMessage,
      progress: progress ?? this.progress,
      transactions: transactions ?? this.transactions,
      summary: summary ?? this.summary,
    );
  }

  bool get isLoading => status == ExportStatus.loading;
  bool get isGenerating => status == ExportStatus.generating;
  bool get hasError => status == ExportStatus.error;
  bool get isSuccess => status == ExportStatus.success;

  @override
  List<Object?> get props => [
    status,
    configuration,
    filePath,
    errorMessage,
    progress,
    transactions,
    summary,
  ];
}
