import 'package:equatable/equatable.dart';

class SavedCalculation extends Equatable {
  final String id;
  final String type;
  final String name;
  final Map<String, dynamic> data;
  final DateTime createdAt;

  const SavedCalculation({
    required this.id,
    required this.type,
    required this.name,
    required this.data,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [id, type, name, data, createdAt];
}
