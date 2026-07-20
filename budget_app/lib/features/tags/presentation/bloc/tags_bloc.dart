import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';
import '../../domain/entities/tag.dart';
import '../../domain/repositories/tags_repository.dart';
import 'tags_event.dart';
import 'tags_state.dart';

class TagsBloc extends Bloc<TagsEvent, TagsState> {
  final TagsRepository _repository;
  final _uuid = const Uuid();

  TagsBloc({required TagsRepository repository})
      : _repository = repository,
        super(const TagsInitial()) {
    on<LoadAllTags>(_onLoadAllTags);
    on<CreateTagEvent>(_onCreateTag);
    on<UpdateTagEvent>(_onUpdateTag);
    on<DeleteTagEvent>(_onDeleteTag);
    on<TagTransactionEvent>(_onTagTransaction);
    on<UntagTransactionEvent>(_onUntagTransaction);
    on<LoadTransactionTagsEvent>(_onLoadTransactionTags);
  }

  Future<void> _onLoadAllTags(LoadAllTags event, Emitter<TagsState> emit) async {
    emit(const TagsLoading());
    final tags = await _repository.getAllTags();
    emit(TagsLoaded(tags));
  }

  Future<void> _onCreateTag(CreateTagEvent event, Emitter<TagsState> emit) async {
    final tag = Tag(
      id: _uuid.v4(),
      name: event.name,
      color: event.color,
      createdAt: DateTime.now(),
    );
    await _repository.createTag(tag);
    final tags = await _repository.getAllTags();
    emit(TagsLoaded(tags));
  }

  Future<void> _onUpdateTag(UpdateTagEvent event, Emitter<TagsState> emit) async {
    await _repository.updateTag(event.tag);
    final tags = await _repository.getAllTags();
    emit(TagsLoaded(tags));
  }

  Future<void> _onDeleteTag(DeleteTagEvent event, Emitter<TagsState> emit) async {
    await _repository.deleteTag(event.tagId);
    final tags = await _repository.getAllTags();
    emit(TagsLoaded(tags));
  }

  Future<void> _onTagTransaction(TagTransactionEvent event, Emitter<TagsState> emit) async {
    await _repository.tagTransaction(event.transactionId, event.transactionType, event.tagId);
  }

  Future<void> _onUntagTransaction(UntagTransactionEvent event, Emitter<TagsState> emit) async {
    await _repository.untagTransaction(event.transactionId, event.transactionType, event.tagId);
  }

  Future<void> _onLoadTransactionTags(LoadTransactionTagsEvent event, Emitter<TagsState> emit) async {
    final tagIds = await _repository.getTagIdsForTransaction(event.transactionId, event.transactionType);
    final allTags = await _repository.getAllTags();
    final transactionTags = allTags.where((t) => tagIds.contains(t.id)).toList();
    emit(TransactionTagsLoaded(transactionTags));
  }
}
