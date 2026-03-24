import 'package:equatable/equatable.dart';

enum BackupStatus { initial, loading, success, error }

class BackupState extends Equatable {
  final BackupStatus status;
  final String? filePath;
  final String? errorMessage;
  final int? tableCount;
  final int? recordCount;
  final String? successMessage;

  const BackupState({
    this.status = BackupStatus.initial,
    this.filePath,
    this.errorMessage,
    this.tableCount,
    this.recordCount,
    this.successMessage,
  });

  BackupState copyWith({
    BackupStatus? status,
    String? filePath,
    String? errorMessage,
    int? tableCount,
    int? recordCount,
    String? successMessage,
  }) {
    return BackupState(
      status: status ?? this.status,
      filePath: filePath ?? this.filePath,
      errorMessage: errorMessage,
      tableCount: tableCount ?? this.tableCount,
      recordCount: recordCount ?? this.recordCount,
      successMessage: successMessage,
    );
  }

  bool get isLoading => status == BackupStatus.loading;
  bool get hasError => status == BackupStatus.error;
  bool get isSuccess => status == BackupStatus.success;

  @override
  List<Object?> get props => [
    status,
    filePath,
    errorMessage,
    tableCount,
    recordCount,
    successMessage,
  ];
}
