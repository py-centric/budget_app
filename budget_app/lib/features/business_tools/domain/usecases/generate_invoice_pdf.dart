import 'dart:io';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import '../../domain/entities/invoice.dart';
import '../../domain/entities/invoice_item.dart';
import '../../domain/entities/company_profile.dart';
import 'package:intl/intl.dart';
import '../utils/vat_calculator.dart';

class GenerateInvoicePdf {
  Future<pw.Document> execute({
    required Invoice invoice,
    required List<InvoiceItem> items,
    required CompanyProfile profile,
  }) async {
    final primaryColor = profile.primaryColor != null ? PdfColor.fromInt(profile.primaryColor!) : PdfColors.blue600;

    // Load font
    final font = await _getFont(profile.fontFamily);

    final pdf = pw.Document(
      theme: pw.ThemeData.withFont(
        base: font,
        bold: font, // Simplified for now
      ),
    );
    final currencyFormat = NumberFormat.currency(symbol: '\$');
    final dateFormat = DateFormat('yyyy-MM-dd');

    final vatSummary = VatCalculator.calculateSummary(items);

    // Load logo if available
    pw.ImageProvider? logo;
    if (profile.logoPath != null && File(profile.logoPath!).existsSync()) {
      logo = pw.MemoryImage(File(profile.logoPath!).readAsBytesSync());
    }

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        build: (context) => [
          _buildHeader(invoice, profile, logo, dateFormat, primaryColor),
          pw.SizedBox(height: 20),
          _buildClientInfo(invoice),
          pw.SizedBox(height: 20),
          _buildItemsTable(items, currencyFormat, primaryColor),
          pw.SizedBox(height: 20),
          _buildSummary(invoice, currencyFormat, primaryColor),
          if (vatSummary.isNotEmpty) ...[
            pw.SizedBox(height: 20),
            _buildVatSummaryTable(vatSummary, currencyFormat),
          ],
          _buildBankingInfo(invoice, profile),
          if (invoice.notes != null && invoice.notes!.isNotEmpty) ...[
            pw.SizedBox(height: 20),
            _buildNotes(invoice),
          ],
        ],
      ),
    );

    return pdf;
  }

  Future<pw.Font> _getFont(String? family) async {
    switch (family) {
      case 'Courier':
        return pw.Font.courier();
      case 'Times-Roman':
        return pw.Font.times();
      default:
        return pw.Font.helvetica();
    }
  }

  pw.Widget _buildHeader(Invoice invoice, CompanyProfile profile, pw.ImageProvider? logo, DateFormat df, PdfColor primaryColor) {
    final logoWidget = (logo != null) ? pw.Image(logo, width: 60, height: 60) : pw.SizedBox();

    final infoColumn = pw.Column(
      crossAxisAlignment: profile.logoOnRight ? pw.CrossAxisAlignment.start : pw.CrossAxisAlignment.end,
      children: [
        pw.Text('INVOICE', style: pw.TextStyle(fontSize: 30, fontWeight: pw.FontWeight.bold, color: primaryColor)),
        pw.Text('Number: ${invoice.invoiceNumber}'),
        pw.Text('Date: ${df.format(invoice.date)}'),
        pw.Text('Status: ${invoice.status.name.toUpperCase()}'),
      ],
    );

    final profileColumn = pw.Column(
      crossAxisAlignment: profile.logoOnRight ? pw.CrossAxisAlignment.end : pw.CrossAxisAlignment.start,
      children: [
        pw.Text(profile.name, style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold)),
        pw.Text(profile.address),
        if (profile.taxId != null && profile.taxId!.isNotEmpty) pw.Text('Tax ID: ${profile.taxId}'),
      ],
    );

    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        if (profile.logoOnRight) ...[
          profileColumn,
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.end,
            children: [
              logoWidget,
              pw.SizedBox(height: 10),
              infoColumn,
            ],
          ),
        ] else ...[
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              logoWidget,
              pw.SizedBox(height: 10),
              profileColumn,
            ],
          ),
          infoColumn,
        ],
      ],
    );
  }

  pw.Widget _buildClientInfo(Invoice invoice) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text('BILL TO:', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
        pw.Text(invoice.clientName),
        pw.Text(invoice.clientDetails),
      ],
    );
  }

  pw.Widget _buildItemsTable(List<InvoiceItem> items, NumberFormat cf, PdfColor primaryColor) {
    final headers = ['Description', 'Qty', 'Rate', 'Tax %', 'Total'];
    final data = items.map((it) => [
      it.description,
      it.quantity.toString(),
      cf.format(it.rate),
      '${it.taxRate}%',
      cf.format(it.total),
    ]).toList();

    return pw.TableHelper.fromTextArray(
      headers: headers,
      data: data,
      headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: PdfColors.white),
      headerDecoration: pw.BoxDecoration(color: primaryColor),
      cellAlignment: pw.Alignment.centerLeft,
      columnWidths: {
        0: const pw.FlexColumnWidth(3),
        1: const pw.FlexColumnWidth(1),
        2: const pw.FlexColumnWidth(2),
        3: const pw.FlexColumnWidth(1),
        4: const pw.FlexColumnWidth(2),
      },
      cellAlignments: {
        1: pw.Alignment.centerRight,
        2: pw.Alignment.centerRight,
        3: pw.Alignment.centerRight,
        4: pw.Alignment.centerRight,
      },
    );
  }

  pw.Widget _buildSummary(Invoice invoice, NumberFormat cf, PdfColor primaryColor) {
    return pw.Align(
      alignment: pw.Alignment.centerRight,
      child: pw.SizedBox(
        width: 200,
        child: pw.Column(
          children: [
            _summaryRow('Sub-total', cf.format(invoice.subTotal)),
            _summaryRow('Tax Total', cf.format(invoice.taxTotal)),
            pw.Divider(color: primaryColor),
            _summaryRow('Grand Total', cf.format(invoice.grandTotal), isBold: true),
            if (invoice.balanceDue > 0)
              _summaryRow('Balance Due', cf.format(invoice.balanceDue), isBold: true, color: PdfColors.red),
          ],
        ),
      ),
    );
  }

  pw.Widget _summaryRow(String label, String value, {bool isBold = false, PdfColor? color}) {
    final style = pw.TextStyle(fontWeight: isBold ? pw.FontWeight.bold : null, color: color);
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 2),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [pw.Text(label, style: style), pw.Text(value, style: style)],
      ),
    );
  }

  pw.Widget _buildVatSummaryTable(List<VatSummary> summary, NumberFormat cf) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text('VAT SUMMARY:', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
        pw.SizedBox(height: 5),
        pw.TableHelper.fromTextArray(
          headers: ['Rate %', 'Net Amount', 'VAT Amount', 'Gross Amount'],
          data: summary.map((s) => [
            '${s.rate}%',
            cf.format(s.netAmount),
            cf.format(s.vatAmount),
            cf.format(s.grossAmount),
          ]).toList(),
          headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
          headerDecoration: const pw.BoxDecoration(color: PdfColors.grey200),
          cellAlignment: pw.Alignment.centerRight,
          cellAlignments: {0: pw.Alignment.centerLeft},
        ),
      ],
    );
  }

  pw.Widget _buildBankingInfo(Invoice invoice, CompanyProfile profile) {
    final bankName = (invoice.bankName != null && invoice.bankName!.isNotEmpty) ? invoice.bankName : profile.bankName;
    final bankIban = (invoice.bankIban != null && invoice.bankIban!.isNotEmpty) ? invoice.bankIban : profile.bankIban;
    final bankBic = (invoice.bankBic != null && invoice.bankBic!.isNotEmpty) ? invoice.bankBic : profile.bankBic;
    final bankHolder = (invoice.bankHolder != null && invoice.bankHolder!.isNotEmpty) ? invoice.bankHolder : profile.bankHolder;

    if (bankName == null && bankIban == null && bankBic == null && bankHolder == null) {
      if (profile.paymentInfo != null && profile.paymentInfo!.isNotEmpty) {
        return pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.SizedBox(height: 20),
            pw.Text('PAYMENT INFORMATION:', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
            pw.Text(profile.paymentInfo!),
          ],
        );
      }
      return pw.SizedBox();
    }

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.SizedBox(height: 20),
        pw.Text('BANKING DETAILS:', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
        if (bankHolder != null && bankHolder.isNotEmpty) pw.Text('Account Holder: $bankHolder'),
        if (bankName != null && bankName.isNotEmpty) pw.Text('Bank: $bankName'),
        if (bankIban != null && bankIban.isNotEmpty) pw.Text('IBAN: $bankIban'),
        if (bankBic != null && bankBic.isNotEmpty) pw.Text('BIC/SWIFT: $bankBic'),
      ],
    );
  }

  pw.Widget _buildNotes(Invoice invoice) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text('NOTES:', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
        pw.Text(invoice.notes!),
      ],
    );
  }
}
