import 'package:equatable/equatable.dart';
import '../../domain/entities/tag.dart';

abstract class TagsEvent extends Equatable {
  const TagsEvent();
  @override
  List<Object?> get props => [];
}

class LoadAllTags extends TagsEvent {
  const LoadAllTags();
}

class CreateTagEvent extends TagsEvent {
  final String name;
  final String? color;
  const CreateTagEvent({required this.name, this.color});
  @override
  List<Object?> get props => [name, color];
}

class UpdateTagEvent extends TagsEvent {
  final Tag tag;
  const UpdateTagEvent(this.tag);
  @override
  List<Object?> get props => [tag];
}

class DeleteTagEvent extends TagsEvent {
  final String tagId;
  const DeleteTagEvent(this.tagId);
  @override
  List<Object?> get props => [tagId];
}

class TagTransactionEvent extends TagsEvent {
  final String transactionId;
  final String transactionType;
  final String tagId;
  const TagTransactionEvent({
    required this.transactionId,
    required this.transactionType,
    required this.tagId,
  });
  @override
  List<Object?> get props => [transactionId, transactionType, tagId];
}

class UntagTransactionEvent extends TagsEvent {
  final String transactionId;
  final String transactionType;
  final String tagId;
  const UntagTransactionEvent({
    required this.transactionId,
    required this.transactionType,
    required this.tagId,
  });
  @override
  List<Object?> get props => [transactionId, transactionType, tagId];
}

class LoadTransactionTagsEvent extends TagsEvent {
  final String transactionId;
  final String transactionType;
  const LoadTransactionTagsEvent({
    required this.transactionId,
    required this.transactionType,
  });
  @override
  List<Object?> get props => [transactionId, transactionType];
}
