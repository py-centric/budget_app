import 'package:equatable/equatable.dart';

class FinancialToolEntry extends Equatable {
  final String label;
  final double value;

  const FinancialToolEntry({required this.label, required this.value});

  @override
  List<Object?> get props => [label, value];

  Map<String, dynamic> toMap() {
    return {'label': label, 'value': value};
  }

  factory FinancialToolEntry.fromMap(Map<String, dynamic> map) {
    return FinancialToolEntry(
      label: map['label'] as String,
      value: (map['value'] as num).toDouble(),
    );
  }
}
