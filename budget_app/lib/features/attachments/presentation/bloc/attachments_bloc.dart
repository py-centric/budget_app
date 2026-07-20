import 'dart:io';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';
import '../../domain/entities/attachment.dart';
import '../../domain/repositories/attachments_repository.dart';
import 'attachments_event.dart';
import 'attachments_state.dart';

class AttachmentsBloc extends Bloc<AttachmentsEvent, AttachmentsState> {
  final AttachmentsRepository _repository;
  final _uuid = const Uuid();

  AttachmentsBloc({required AttachmentsRepository repository})
      : _repository = repository,
        super(const AttachmentsInitial()) {
    on<LoadAttachmentsEvent>(_onLoadAttachments);
    on<AddAttachmentEvent>(_onAddAttachment);
    on<DeleteAttachmentEvent>(_onDeleteAttachment);
  }

  Future<void> _onLoadAttachments(LoadAttachmentsEvent event, Emitter<AttachmentsState> emit) async {
    emit(const AttachmentsLoading());
    final attachments = await _repository.getAttachmentsForTransaction(event.transactionId, event.transactionType);
    emit(AttachmentsLoaded(attachments));
  }

  Future<void> _onAddAttachment(AddAttachmentEvent event, Emitter<AttachmentsState> emit) async {
    final file = File(event.filePath);
    final exists = await file.exists();
    final fileSize = exists ? await file.length() : null;

    final attachment = Attachment(
      id: _uuid.v4(),
      transactionId: event.transactionId,
      transactionType: event.transactionType,
      filePath: event.filePath,
      fileName: event.fileName,
      fileSize: fileSize ?? event.fileSize,
      mimeType: event.mimeType,
      createdAt: DateTime.now(),
    );
    await _repository.addAttachment(attachment);
    final attachments = await _repository.getAttachmentsForTransaction(event.transactionId, event.transactionType);
    emit(AttachmentsLoaded(attachments));
  }

  Future<void> _onDeleteAttachment(DeleteAttachmentEvent event, Emitter<AttachmentsState> emit) async {
    await _repository.deleteAttachment(event.attachmentId);
  }
}
