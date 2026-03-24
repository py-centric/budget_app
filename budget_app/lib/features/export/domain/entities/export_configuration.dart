import 'package:equatable/equatable.dart';
import 'export_format.dart';
import 'export_period.dart';

class ExportConfiguration extends Equatable {
  final ExportPeriod period;
  final ExportFormat format;
  final DateTime? startDate;
  final DateTime? endDate;

  const ExportConfiguration({
    required this.period,
    required this.format,
    this.startDate,
    this.endDate,
  });

  ExportConfiguration copyWith({
    ExportPeriod? period,
    ExportFormat? format,
    DateTime? startDate,
    DateTime? endDate,
  }) {
    return ExportConfiguration(
      period: period ?? this.period,
      format: format ?? this.format,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
    );
  }

  @override
  List<Object?> get props => [period, format, startDate, endDate];
}
