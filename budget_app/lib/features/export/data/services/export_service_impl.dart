import 'dart:io';
import 'package:csv/csv.dart';
import 'package:excel/excel.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
// ignore: deprecated_member_use
import 'package:share_plus/share_plus.dart';
import '../../domain/entities/export_configuration.dart';
import '../../domain/entities/export_format.dart';
import '../../domain/entities/export_period.dart';
import '../../domain/services/export_service.dart';

class ExportServiceImpl implements ExportService {
  final Future<List<Map<String, dynamic>>> Function(ExportConfiguration)
  fetchTransactions;
  final Future<Map<String, dynamic>> Function(ExportConfiguration) fetchSummary;

  ExportServiceImpl({
    required this.fetchTransactions,
    required this.fetchSummary,
  });

  @override
  Future<List<Map<String, dynamic>>> getTransactions(
    ExportConfiguration config,
  ) async {
    return await fetchTransactions(config);
  }

  @override
  Future<Map<String, dynamic>> getSummary(ExportConfiguration config) async {
    return await fetchSummary(config);
  }

  @override
  Future<String> generateCsv(List<Map<String, dynamic>> transactions) async {
    final List<List<dynamic>> rows = [
      ['Date', 'Description', 'Category', 'Amount', 'Type'],
    ];

    for (final transaction in transactions) {
      rows.add([
        _formatDate(transaction['date']),
        _escapeCsvField(transaction['description'] ?? ''),
        _escapeCsvField(transaction['category'] ?? ''),
        _formatAmount(transaction['amount'] ?? 0),
        transaction['type'] ?? 'expense',
      ]);
    }

    final csvData = const ListToCsvConverter().convert(rows);
    final fileName = _generateFileName(ExportFormat.csv);
    final filePath = await _saveToFile(fileName, csvData);
    return filePath;
  }

  @override
  Future<String> generatePdf(
    List<Map<String, dynamic>> transactions,
    Map<String, dynamic> summary,
    ExportConfiguration config,
  ) async {
    final pdf = pw.Document();
    final currencyFormat = NumberFormat.currency(symbol: '\$');

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        build: (context) => [
          pw.Header(
            level: 0,
            child: pw.Text(
              'Budget Export',
              style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold),
            ),
          ),
          pw.SizedBox(height: 10),
          pw.Text(
            'Period: ${_getPeriodText(config)}',
            style: const pw.TextStyle(fontSize: 14),
          ),
          pw.Text(
            'Generated: ${DateFormat.yMMMd().add_jm().format(DateTime.now())}',
            style: const pw.TextStyle(fontSize: 12),
          ),
          pw.SizedBox(height: 20),
          pw.Header(level: 1, child: pw.Text('Summary')),
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text('Total Income:'),
              pw.Text(
                currencyFormat.format(summary['totalIncome'] ?? 0),
                style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
              ),
            ],
          ),
          pw.SizedBox(height: 5),
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text('Total Expenses:'),
              pw.Text(
                currencyFormat.format(summary['totalExpenses'] ?? 0),
                style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
              ),
            ],
          ),
          pw.SizedBox(height: 5),
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text('Balance:'),
              pw.Text(
                currencyFormat.format(summary['balance'] ?? 0),
                style: pw.TextStyle(
                  fontWeight: pw.FontWeight.bold,
                  color: (summary['balance'] ?? 0) >= 0
                      ? PdfColors.green
                      : PdfColors.red,
                ),
              ),
            ],
          ),
          pw.SizedBox(height: 20),
          pw.Header(level: 1, child: pw.Text('Transactions')),
          // ignore: deprecated_member_use
          pw.Table.fromTextArray(
            headers: ['Date', 'Description', 'Category', 'Amount'],
            data: transactions
                .map(
                  (t) => [
                    _formatDate(t['date']),
                    t['description'] ?? '',
                    t['category'] ?? '',
                    currencyFormat.format(t['amount'] ?? 0),
                  ],
                )
                .toList(),
          ),
        ],
      ),
    );

    final fileName = _generateFileName(ExportFormat.pdf);
    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/$fileName');
    await file.writeAsBytes(await pdf.save());
    return file.path;
  }

  @override
  Future<String> generateExcel(
    List<Map<String, dynamic>> transactions,
    Map<String, dynamic> summary,
    ExportConfiguration config,
  ) async {
    final excel = Excel.createExcel();
    final currencyFormat = NumberFormat.currency(symbol: '\$');

    final summarySheet = excel['Summary'];
    summarySheet.appendRow([TextCellValue('Budget Export')]);
    summarySheet.appendRow([
      TextCellValue('Period: ${_getPeriodText(config)}'),
    ]);
    summarySheet.appendRow([
      TextCellValue(
        'Generated: ${DateFormat.yMMMd().add_jm().format(DateTime.now())}',
      ),
    ]);
    summarySheet.appendRow([]);
    summarySheet.appendRow([TextCellValue('Summary')]);
    summarySheet.appendRow([
      TextCellValue('Total Income'),
      TextCellValue(currencyFormat.format(summary['totalIncome'] ?? 0)),
    ]);
    summarySheet.appendRow([
      TextCellValue('Total Expenses'),
      TextCellValue(currencyFormat.format(summary['totalExpenses'] ?? 0)),
    ]);
    summarySheet.appendRow([
      TextCellValue('Balance'),
      TextCellValue(currencyFormat.format(summary['balance'] ?? 0)),
    ]);
    summarySheet.appendRow([]);

    final transactionsSheet = excel['Transactions'];
    transactionsSheet.appendRow([
      TextCellValue('Date'),
      TextCellValue('Description'),
      TextCellValue('Category'),
      TextCellValue('Amount'),
      TextCellValue('Type'),
    ]);

    for (final transaction in transactions) {
      transactionsSheet.appendRow([
        TextCellValue(_formatDate(transaction['date'])),
        TextCellValue(transaction['description'] ?? ''),
        TextCellValue(transaction['category'] ?? ''),
        TextCellValue(currencyFormat.format(transaction['amount'] ?? 0)),
        TextCellValue(transaction['type'] ?? 'expense'),
      ]);
    }

    final fileName = _generateFileName(ExportFormat.excel);
    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/$fileName');
    final bytes = excel.encode();
    if (bytes != null) {
      await file.writeAsBytes(bytes);
    }
    return file.path;
  }

  @override
  Future<void> shareFile(String filePath) async {
    // ignore: deprecated_member_use
    await Share.shareXFiles([XFile(filePath)]);
  }

  @override
  Future<String> saveFile(String sourcePath, String fileName) async {
    final sourceFile = File(sourcePath);
    final dir = await getApplicationDocumentsDirectory();
    final destPath = '${dir.path}/$fileName';
    await sourceFile.copy(destPath);
    return destPath;
  }

  @override
  Future<void> deleteFile(String filePath) async {
    final file = File(filePath);
    if (await file.exists()) {
      await file.delete();
    }
  }

  String _generateFileName(ExportFormat format) {
    final timestamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
    return 'budget_export_${format.name}_$timestamp.${format.extension}';
  }

  String _getPeriodText(ExportConfiguration config) {
    switch (config.period) {
      case ExportPeriod.currentMonth:
        return 'Current Month';
      case ExportPeriod.customRange:
        return '${_formatDate(config.startDate)} - ${_formatDate(config.endDate)}';
      case ExportPeriod.allTime:
        return 'All Time';
    }
  }

  String _formatDate(dynamic date) {
    if (date == null) return '';
    if (date is String) {
      try {
        return DateFormat.yMMMd().format(DateTime.parse(date));
      } catch (_) {
        return date;
      }
    }
    if (date is DateTime) {
      return DateFormat.yMMMd().format(date);
    }
    return date.toString();
  }

  String _formatAmount(dynamic amount) {
    if (amount == null) return '0.00';
    final num amountNum = amount is num
        ? amount
        : double.tryParse(amount.toString()) ?? 0;
    return amountNum.toStringAsFixed(2);
  }

  String _escapeCsvField(String field) {
    if (field.contains(',') || field.contains('"') || field.contains('\n')) {
      return '"${field.replaceAll('"', '""')}"';
    }
    return field;
  }

  Future<String> _saveToFile(String fileName, String content) async {
    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/$fileName');
    await file.writeAsString(content);
    return file.path;
  }
}
