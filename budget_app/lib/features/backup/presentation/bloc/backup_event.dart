import 'package:equatable/equatable.dart';

abstract class BackupEvent extends Equatable {
  const BackupEvent();

  @override
  List<Object?> get props => [];
}

class BackupExport extends BackupEvent {}

class BackupImport extends BackupEvent {
  final String filePath;

  const BackupImport({required this.filePath});

  @override
  List<Object?> get props => [filePath];
}

class BackupShare extends BackupEvent {
  final String filePath;

  const BackupShare({required this.filePath});

  @override
  List<Object?> get props => [filePath];
}

class BackupReset extends BackupEvent {}
