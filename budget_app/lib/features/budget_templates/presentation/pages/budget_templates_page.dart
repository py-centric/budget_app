import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/budget_templates_bloc.dart';
import '../bloc/budget_templates_event.dart';
import '../bloc/budget_templates_state.dart';
import '../../domain/entities/budget_template.dart';

class BudgetTemplatesPage extends StatelessWidget {
  const BudgetTemplatesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Budget Templates'),
      ),
      body: BlocBuilder<BudgetTemplatesBloc, BudgetTemplatesState>(
        builder: (context, state) {
          if (state is BudgetTemplatesLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is BudgetTemplatesLoaded) {
            if (state.templates.isEmpty) {
              return const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.dashboard_customize, size: 64, color: Colors.grey),
                    SizedBox(height: 16),
                    Text('No templates yet', style: TextStyle(fontSize: 18, color: Colors.grey)),
                    SizedBox(height: 8),
                    Text('Create a template to reuse budget allocations'),
                  ],
                ),
              );
            }
            return ListView.builder(
              itemCount: state.templates.length,
              itemBuilder: (context, index) {
                final template = state.templates[index];
                return ListTile(
                  leading: Icon(
                    template.isPreset ? Icons.star : Icons.dashboard_customize,
                    color: template.isPreset ? Colors.amber : null,
                  ),
                  title: Text(template.name),
                  subtitle: template.description != null ? Text(template.description!) : null,
                  trailing: template.isPreset
                      ? const Chip(label: Text('Preset', style: TextStyle(fontSize: 10)))
                      : IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () => _confirmDelete(context, template),
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
    final descController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Create Template'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'Template Name'),
              autofocus: true,
            ),
            const SizedBox(height: 8),
            TextField(
              controller: descController,
              decoration: const InputDecoration(labelText: 'Description (optional)'),
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
                context.read<BudgetTemplatesBloc>().add(CreateTemplateEvent(
                  name: nameController.text.trim(),
                  description: descController.text.trim().isEmpty
                      ? null
                      : descController.text.trim(),
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

  void _confirmDelete(BuildContext context, BudgetTemplate template) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Template'),
        content: Text('Delete "${template.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              context.read<BudgetTemplatesBloc>().add(DeleteTemplateEvent(template.id));
              Navigator.of(context).pop();
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
