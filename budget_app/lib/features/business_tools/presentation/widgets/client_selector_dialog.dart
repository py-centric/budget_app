import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/client.dart';
import '../bloc/business_bloc.dart';
import '../bloc/business_state.dart';

class ClientSelectorDialog extends StatelessWidget {
  const ClientSelectorDialog({super.key});

  static Future<Client?> show(BuildContext context) {
    return showDialog<Client>(
      context: context,
      builder: (context) => const ClientSelectorDialog(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Select Client'),
      content: SizedBox(
        width: double.maxFinite,
        height: 400,
        child: BlocBuilder<BusinessBloc, BusinessState>(
          builder: (context, state) {
            if (state.status == BusinessStatus.loading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state.clients.isEmpty) {
              return const Center(child: Text('No clients available.'));
            }

            return ListView.builder(
              itemCount: state.clients.length,
              itemBuilder: (context, index) {
                final client = state.clients[index];
                return ListTile(
                  leading: const Icon(Icons.person),
                  title: Text(client.name),
                  subtitle: Text(client.email ?? client.address),
                  onTap: () => Navigator.pop(context, client),
                );
              },
            );
          },
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
      ],
    );
  }
}
