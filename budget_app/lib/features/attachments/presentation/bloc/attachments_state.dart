import 'package:equatable/equatable.dart';
import '../../domain/entities/attachment.dart';

abstract class AttachmentsState extends Equatable {
  const AttachmentsState();
  @override
  List<Object?> get props => [];
}

class AttachmentsInitial extends AttachmentsState {
  const AttachmentsInitial();
}

class AttachmentsLoading extends AttachmentsState {
  const AttachmentsLoading();
}

class AttachmentsLoaded extends AttachmentsState {
  final List<Attachment> attachments;
  const AttachmentsLoaded(this.attachments);
  @override
  List<Object?> get props => [attachments];
}

class AttachmentsError extends AttachmentsState {
  final String message;
  const AttachmentsError(this.message);
  @override
  List<Object?> get props => [message];
}
