import 'package:equatable/equatable.dart';

abstract class AttachmentsEvent extends Equatable {
  const AttachmentsEvent();
  @override
  List<Object?> get props => [];
}

class LoadAttachmentsEvent extends AttachmentsEvent {
  final String transactionId;
  final String transactionType;
  const LoadAttachmentsEvent({required this.transactionId, required this.transactionType});
  @override
  List<Object?> get props => [transactionId, transactionType];
}

class AddAttachmentEvent extends AttachmentsEvent {
  final String transactionId;
  final String transactionType;
  final String filePath;
  final String fileName;
  final int? fileSize;
  final String? mimeType;
  const AddAttachmentEvent({
    required this.transactionId,
    required this.transactionType,
    required this.filePath,
    required this.fileName,
    this.fileSize,
    this.mimeType,
  });
  @override
  List<Object?> get props => [transactionId, transactionType, filePath, fileName, fileSize, mimeType];
}

class DeleteAttachmentEvent extends AttachmentsEvent {
  final String attachmentId;
  const DeleteAttachmentEvent(this.attachmentId);
  @override
  List<Object?> get props => [attachmentId];
}
