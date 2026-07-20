import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/tags_bloc.dart';
import '../bloc/tags_event.dart';
import '../bloc/tags_state.dart';
import '../../domain/entities/tag.dart';

class TagsPage extends StatelessWidget {
  const TagsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Tags'),
      ),
      body: BlocBuilder<TagsBloc, TagsState>(
        builder: (context, state) {
          if (state is TagsLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is TagsLoaded) {
            if (state.tags.isEmpty) {
              return const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.label_off, size: 64, color: Colors.grey),
                    SizedBox(height: 16),
                    Text('No tags yet', style: TextStyle(fontSize: 18, color: Colors.grey)),
                    SizedBox(height: 8),
                    Text('Tap + to create your first tag'),
                  ],
                ),
              );
            }
            return ListView.builder(
              itemCount: state.tags.length,
              itemBuilder: (context, index) {
                final tag = state.tags[index];
                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor: tag.color != null
                        ? Color(int.parse('0xFF${tag.color!.replaceFirst('#', '')}'))
                        : Theme.of(context).colorScheme.primary,
                    child: Text(
                      tag.name[0].toUpperCase(),
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                  title: Text(tag.name),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: () => _showEditDialog(context, tag),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () => _confirmDelete(context, tag),
                      ),
                    ],
                  ),
                );
              },
            );
          }
          return const SizedBox.shrink();
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showCreateDialog(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showCreateDialog(BuildContext context) {
    final nameController = TextEditingController();
    final colorController = TextEditingController(text: '#6750A4');
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Create Tag'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'Tag Name'),
              autofocus: true,
            ),
            const SizedBox(height: 8),
            TextField(
              controller: colorController,
              decoration: const InputDecoration(labelText: 'Color (hex)'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              if (nameController.text.trim().isNotEmpty) {
                context.read<TagsBloc>().add(CreateTagEvent(
                  name: nameController.text.trim(),
                  color: colorController.text.trim(),
                ));
                Navigator.of(context).pop();
              }
            },
            child: const Text('Create'),
          ),
        ],
      ),
    );
  }

  void _showEditDialog(BuildContext context, Tag tag) {
    final nameController = TextEditingController(text: tag.name);
    final colorController = TextEditingController(text: tag.color ?? '#6750A4');
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Tag'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'Tag Name'),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: colorController,
              decoration: const InputDecoration(labelText: 'Color (hex)'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              if (nameController.text.trim().isNotEmpty) {
                context.read<TagsBloc>().add(UpdateTagEvent(
                  tag.copyWith(
                    name: nameController.text.trim(),
                    color: colorController.text.trim(),
                  ),
                ));
                Navigator.of(context).pop();
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext context, Tag tag) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Tag'),
        content: Text('Delete "${tag.name}"? This will remove it from all transactions.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              context.read<TagsBloc>().add(DeleteTagEvent(tag.id));
              Navigator.of(context).pop();
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
