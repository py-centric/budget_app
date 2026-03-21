import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'invoice_builder_page.dart';
import 'outgoing_invoices_tab.dart';
import 'received_invoices_tab.dart';
import 'received_invoice_edit_page.dart';
import '../widgets/invoice_dashboard.dart';
import '../bloc/business_bloc.dart';
import '../bloc/business_event.dart';
import '../bloc/business_state.dart';

class InvoicesPage extends StatefulWidget {
  const InvoicesPage({super.key});

  @override
  State<InvoicesPage> createState() => _InvoicesPageState();
}

class _InvoicesPageState extends State<InvoicesPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Invoices'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Outgoing'),
            Tab(text: 'Received'),
          ],
        ),
      ),
      body: BlocBuilder<BusinessBloc, BusinessState>(
        builder: (context, state) {
          return Column(
            children: [
              if (state.summary != null)
                InvoiceDashboard(
                  summary: state.summary!,
                  filterRange: state.filterRange,
                  onRangeChanged: (range) {
                    context.read<BusinessBloc>().add(FilterInvoices(range));
                  },
                ),
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: const [
                    OutgoingInvoicesTab(),
                    ReceivedInvoicesTab(),
                  ],
                ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          if (_tabController.index == 0) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const InvoiceBuilderPage()),
            );
          } else {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const ReceivedInvoiceEditPage()),
            );
          }
        },
        tooltip: _tabController.index == 0 ? 'Create Invoice' : 'Add Received Invoice',
        child: const Icon(Icons.add),
      ),
    );
  }
}
