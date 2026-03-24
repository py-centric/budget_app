import '../entities/export_configuration.dart';

abstract class ExportService {
  Future<String> generateCsv(List<Map<String, dynamic>> transactions);
  Future<String> generatePdf(
    List<Map<String, dynamic>> transactions,
    Map<String, dynamic> summary,
    ExportConfiguration config,
  );
  Future<String> generateExcel(
    List<Map<String, dynamic>> transactions,
    Map<String, dynamic> summary,
    ExportConfiguration config,
  );
  Future<void> shareFile(String filePath);
  Future<String> saveFile(String sourcePath, String fileName);
  Future<void> deleteFile(String filePath);
  Future<List<Map<String, dynamic>>> getTransactions(
    ExportConfiguration config,
  );
  Future<Map<String, dynamic>> getSummary(ExportConfiguration config);
}
