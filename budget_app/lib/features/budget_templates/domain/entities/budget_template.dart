import 'package:equatable/equatable.dart';

class BudgetTemplate extends Equatable {
  final String id;
  final String name;
  final String? description;
  final bool isPreset;
  final DateTime createdAt;

  const BudgetTemplate({
    required this.id,
    required this.name,
    this.description,
    this.isPreset = false,
    required this.createdAt,
  });

  factory BudgetTemplate.fromMap(Map<String, dynamic> map) {
    return BudgetTemplate(
      id: map['id'] as String,
      name: map['name'] as String,
      description: map['description'] as String?,
      isPreset: (map['is_preset'] as int? ?? 0) == 1,
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'is_preset': isPreset ? 1 : 0,
      'created_at': createdAt.toIso8601String(),
    };
  }

  BudgetTemplate copyWith({
    String? id,
    String? name,
    String? description,
    bool? isPreset,
    DateTime? createdAt,
  }) {
    return BudgetTemplate(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      isPreset: isPreset ?? this.isPreset,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  List<Object?> get props => [id, name, description, isPreset, createdAt];
}

class TemplateAllocation extends Equatable {
  final String templateId;
  final String categoryId;
  final double percentage;

  const TemplateAllocation({
    required this.templateId,
    required this.categoryId,
    required this.percentage,
  });

  factory TemplateAllocation.fromMap(Map<String, dynamic> map) {
    return TemplateAllocation(
      templateId: map['template_id'] as String,
      categoryId: map['category_id'] as String,
      percentage: (map['percentage'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'template_id': templateId,
      'category_id': categoryId,
      'percentage': percentage,
    };
  }

  @override
  List<Object?> get props => [templateId, categoryId, percentage];
}
