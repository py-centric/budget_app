import 'dart:convert';
import '../../domain/entities/saved_calculation.dart';

class SavedCalculationModel extends SavedCalculation {
  const SavedCalculationModel({
    required super.id,
    required super.type,
    required super.name,
    required super.data,
    required super.createdAt,
  });

  factory SavedCalculationModel.fromMap(Map<String, dynamic> map) {
    return SavedCalculationModel(
      id: map['id'] as String,
      type: map['type'] as String,
      name: map['name'] as String,
      data: jsonDecode(map['data'] as String) as Map<String, dynamic>,
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'type': type,
      'name': name,
      'data': jsonEncode(data),
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory SavedCalculationModel.fromEntity(SavedCalculation entity) {
    return SavedCalculationModel(
      id: entity.id,
      type: entity.type,
      name: entity.name,
      data: entity.data,
      createdAt: entity.createdAt,
    );
  }
}
