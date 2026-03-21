import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../bloc/business_bloc.dart';
import '../bloc/business_event.dart';
import '../bloc/business_state.dart';
import '../../domain/entities/invoice.dart';
import '../../domain/repositories/business_repository.dart';
import 'pdf_preview_page.dart';
import 'invoice_builder_page.dart';
import '../../../../core/utils/currency_formatter.dart';

class OutgoingInvoicesTab extends StatelessWidget {
  const OutgoingInvoicesTab({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<BusinessBloc, BusinessState>(
      builder: (context, state) {
        if (state.status == BusinessStatus.loading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state.invoices.isEmpty) {
          return const Center(child: Text('No invoices saved yet.'));
        }

        final dateFormat = DateFormat('yyyy-MM-dd');

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: state.invoices.length,
          itemBuilder: (context, index) {
            final invoice = state.invoices[index];
            return Card(
              child: ListTile(
                title: Text('${invoice.invoiceNumber} - ${invoice.clientName}'),
                subtitle: Text('${dateFormat.format(invoice.date)} • ${invoice.status.name.toUpperCase()}'),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          CurrencyFormatter.format(invoice.grandTotal),
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        if (invoice.balanceDue > 0)
                          Text(
                            'Due: ${CurrencyFormatter.format(invoice.balanceDue)}',
                            style: const TextStyle(color: Colors.red, fontSize: 12),
                          ),
                      ],
                    ),
                    PopupMenuButton<String>(
                      onSelected: (value) async {
                        if (value == 'clone') {
                          context.read<BusinessBloc>().add(CloneInvoiceEvent(invoice.id));
                          Future.delayed(const Duration(milliseconds: 300), () {
                            if (context.mounted) {
                              final state = context.read<BusinessBloc>().state;
                              final clonedInvoice = state.invoices.firstWhere(
                                (inv) => inv.status == InvoiceStatus.draft && inv.invoiceNumber != invoice.invoiceNumber,
                                orElse: () => state.invoices.last,
                              );
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => InvoiceBuilderPage(initialInvoice: clonedInvoice),
                                ),
                              );
                            }
                          });
                        } else if (value == 'delete') {
                          _showDeleteConfirm(context, invoice);
                        }
                      },
                      itemBuilder: (BuildContext context) => [
                        const PopupMenuItem(
                          value: 'clone',
                          child: Text('Clone Invoice'),
                        ),
                        const PopupMenuItem(
                          value: 'delete',
                          child: Text('Delete', style: TextStyle(color: Colors.red)),
                        ),
                      ],
                    ),
                  ],
                ),
                onTap: () async {
                  final repository = context.read<BusinessRepository>();
                  final items = await repository.getInvoiceItems(invoice.id);
                  final profiles = context.read<BusinessBloc>().state.profiles;
                  final profile = profiles.firstWhere((p) => p.id == invoice.profileId);
                  
                  if (!context.mounted) return;
                  final navigator = Navigator.of(context);
                  
                  navigator.push(
                    MaterialPageRoute(
                      builder: (context) => PdfPreviewPage(
                        invoice: invoice,
                        items: items,
                        profile: profile,
                      ),
                    ),
                  );
                },
                onLongPress: () {
                  _showDeleteConfirm(context, invoice);
                },
              ),
            );
          },
        );
      },
    );
  }

  void _showDeleteConfirm(BuildContext context, Invoice invoice) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete Invoice'),
        content: Text('Are you sure you want to delete invoice ${invoice.invoiceNumber}?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              context.read<BusinessBloc>().add(DeleteInvoice(invoice.id));
              Navigator.pop(dialogContext);
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
