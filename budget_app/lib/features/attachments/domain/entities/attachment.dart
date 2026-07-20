import 'package:equatable/equatable.dart';

class Attachment extends Equatable {
  final String id;
  final String transactionId;
  final String transactionType;
  final String filePath;
  final String fileName;
  final int? fileSize;
  final String? mimeType;
  final DateTime createdAt;

  const Attachment({
    required this.id,
    required this.transactionId,
    required this.transactionType,
    required this.filePath,
    required this.fileName,
    this.fileSize,
    this.mimeType,
    required this.createdAt,
  });

  factory Attachment.fromMap(Map<String, dynamic> map) {
    return Attachment(
      id: map['id'] as String,
      transactionId: map['transaction_id'] as String,
      transactionType: map['transaction_type'] as String,
      filePath: map['file_path'] as String,
      fileName: map['file_name'] as String,
      fileSize: map['file_size'] as int?,
      mimeType: map['mime_type'] as String?,
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'transaction_id': transactionId,
      'transaction_type': transactionType,
      'file_path': filePath,
      'file_name': fileName,
      'file_size': fileSize,
      'mime_type': mimeType,
      'created_at': createdAt.toIso8601String(),
    };
  }

  @override
  List<Object?> get props => [id, transactionId, transactionType, filePath, fileName, fileSize, mimeType, createdAt];
}
