import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/tags_bloc.dart';
import '../bloc/tags_event.dart';
import '../bloc/tags_state.dart';
import '../../domain/entities/tag.dart';

class TagChip extends StatelessWidget {
  final Tag tag;
  final bool selected;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;

  const TagChip({
    super.key,
    required this.tag,
    this.selected = false,
    this.onTap,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final color = tag.color != null
        ? Color(int.parse('0xFF${tag.color!.replaceFirst('#', '')}'))
        : Theme.of(context).colorScheme.primary;

    return Semantics(
      button: onTap != null,
      selected: selected,
      label: 'Tag: ${tag.name}',
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: 48),
        child: Center(
          child: GestureDetector(
            onTap: onTap,
            behavior: HitTestBehavior.opaque,
            child: Chip(
              label: Text(tag.name),
              backgroundColor: selected ? color.withValues(alpha: 0.2) : null,
              side: BorderSide(color: color),
              deleteIcon: onDelete != null ? const Icon(Icons.close, size: 16) : null,
              onDeleted: onDelete,
              materialTapTargetSize: MaterialTapTargetSize.padded,
            ),
          ),
        ),
      ),
    );
  }
}

class TagSelector extends StatelessWidget {
  final String transactionId;
  final String transactionType;

  const TagSelector({
    super.key,
    required this.transactionId,
    required this.transactionType,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TagsBloc, TagsState>(
      builder: (context, state) {
        if (state is TagsLoaded) {
          return Wrap(
            spacing: 8,
            runSpacing: 4,
            children: state.tags.map((tag) {
              return TagChip(
                tag: tag,
                onTap: () {
                  context.read<TagsBloc>().add(TagTransactionEvent(
                    transactionId: transactionId,
                    transactionType: transactionType,
                    tagId: tag.id,
                  ));
                },
              );
            }).toList(),
          );
        }
        return const SizedBox.shrink();
      },
    );
  }
}

class TransactionTagChips extends StatelessWidget {
  final String transactionId;
  final String transactionType;

  const TransactionTagChips({
    super.key,
    required this.transactionId,
    required this.transactionType,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TagsBloc, TagsState>(
      builder: (context, state) {
        if (state is TransactionTagsLoaded) {
          if (state.tags.isEmpty) return const SizedBox.shrink();
          return Wrap(
            spacing: 4,
            runSpacing: 2,
            children: state.tags.map((tag) {
              return TagChip(
                tag: tag,
                selected: true,
                onDelete: () {
                  context.read<TagsBloc>().add(UntagTransactionEvent(
                    transactionId: transactionId,
                    transactionType: transactionType,
                    tagId: tag.id,
                  ));
                },
              );
            }).toList(),
          );
        }
        return const SizedBox.shrink();
      },
    );
  }
}
