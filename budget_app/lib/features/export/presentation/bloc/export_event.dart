import 'package:equatable/equatable.dart';
import '../../domain/entities/export_configuration.dart';

abstract class ExportEvent extends Equatable {
  const ExportEvent();

  @override
  List<Object?> get props => [];
}

class ExportInitialize extends ExportEvent {}

class ExportConfigure extends ExportEvent {
  final ExportConfiguration configuration;

  const ExportConfigure(this.configuration);

  @override
  List<Object?> get props => [configuration];
}

class ExportGenerate extends ExportEvent {}

class ExportShare extends ExportEvent {}

class ExportSave extends ExportEvent {}

class ExportReset extends ExportEvent {}
