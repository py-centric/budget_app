import 'package:equatable/equatable.dart';

/// Domain entity for user settings used by budget calculations.
/// Avoids direct dependency on data-layer models from domain use cases.
class UserSettings extends Equatable {
  final int weekStartDay;
  final String defaultProjectionHorizon;
  final String currencyCode;
  final String themeMode;

  const UserSettings({
    this.weekStartDay = 1,
    this.defaultProjectionHorizon = 'MONTH',
    this.currencyCode = 'USD',
    this.themeMode = 'system',
  });

  @override
  List<Object?> get props => [
    weekStartDay,
    defaultProjectionHorizon,
    currencyCode,
    themeMode,
  ];
}
