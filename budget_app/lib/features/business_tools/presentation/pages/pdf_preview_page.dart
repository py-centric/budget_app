import 'package:flutter/material.dart';
import 'package:printing/printing.dart';
import '../../domain/entities/invoice.dart';
import '../../domain/entities/invoice_item.dart';
import '../../domain/entities/company_profile.dart';
import '../../domain/usecases/generate_invoice_pdf.dart';

class PdfPreviewPage extends StatelessWidget {
  final Invoice invoice;
  final List<InvoiceItem> items;
  final CompanyProfile profile;

  const PdfPreviewPage({
    super.key,
    required this.invoice,
    required this.items,
    required this.profile,
  });

  @override
  Widget build(BuildContext context) {
    final generatePdf = GenerateInvoicePdf();

    return Scaffold(
      appBar: AppBar(
        title: Text('Invoice Preview - ${invoice.invoiceNumber}'),
      ),
      body: PdfPreview(
        build: (format) => generatePdf.execute(
          invoice: invoice,
          items: items,
          profile: profile,
        ).then((doc) => doc.save()),
        canDebug: false,
      ),
    );
  }
}
