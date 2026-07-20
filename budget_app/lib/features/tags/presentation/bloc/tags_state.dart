import 'package:equatable/equatable.dart';
import '../../domain/entities/tag.dart';

abstract class TagsState extends Equatable {
  const TagsState();
  @override
  List<Object?> get props => [];
}

class TagsInitial extends TagsState {
  const TagsInitial();
}

class TagsLoading extends TagsState {
  const TagsLoading();
}

class TagsLoaded extends TagsState {
  final List<Tag> tags;
  const TagsLoaded(this.tags);
  @override
  List<Object?> get props => [tags];
}

class TransactionTagsLoaded extends TagsState {
  final List<Tag> tags;
  const TransactionTagsLoaded(this.tags);
  @override
  List<Object?> get props => [tags];
}

class TagsError extends TagsState {
  final String message;
  const TagsError(this.message);
  @override
  List<Object?> get props => [message];
}

class TagOperationSuccess extends TagsState {
  final String? message;
  const TagOperationSuccess({this.message});
  @override
  List<Object?> get props => [message];
}
