import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../bloc/business_bloc.dart';
import '../bloc/business_event.dart';
import '../bloc/business_state.dart';
import 'received_invoice_edit_page.dart';
import '../../../../core/utils/currency_formatter.dart';

class ReceivedInvoicesTab extends StatelessWidget {
  const ReceivedInvoicesTab({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<BusinessBloc, BusinessState>(
      builder: (context, state) {
        if (state.status == BusinessStatus.loading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state.receivedInvoices.isEmpty) {
          return const Center(child: Text('No received invoices recorded.'));
        }

        final dateFormat = DateFormat('yyyy-MM-dd');

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: state.receivedInvoices.length,
          itemBuilder: (context, index) {
            final invoice = state.receivedInvoices[index];
            return Card(
              child: ListTile(
                title: Text(invoice.vendorName),
                subtitle: Text(
                  '${invoice.invoiceNumber ?? "No #"} • ${dateFormat.format(invoice.date)} • ${invoice.status.name.toUpperCase()}',
                ),
                trailing: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      CurrencyFormatter.format(invoice.amount),
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    if (invoice.balanceDue > 0)
                      Text(
                        'Due: ${CurrencyFormatter.format(invoice.balanceDue)}',
                        style: const TextStyle(color: Colors.red, fontSize: 12),
                      ),
                  ],
                ),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ReceivedInvoiceEditPage(invoice: invoice),
                  ),
                ),
                onLongPress: () => _confirmDelete(context, invoice.id),
              ),
            );
          },
        );
      },
    );
  }

  void _confirmDelete(BuildContext context, String id) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Received Invoice'),
        content: const Text('Are you sure you want to delete this invoice?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              context.read<BusinessBloc>().add(DeleteReceivedInvoice(id));
              Navigator.pop(ctx);
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
