import '../entities/invoice_item.dart';

class VatSummary {
  final double rate;
  final double netAmount;
  final double vatAmount;
  final double grossAmount;

  VatSummary({
    required this.rate,
    required this.netAmount,
    required this.vatAmount,
    required this.grossAmount,
  });
}

class VatCalculator {
  VatCalculator._();

  static List<VatSummary> calculateSummary(List<InvoiceItem> items) {
    final Map<double, List<InvoiceItem>> grouped = {};
    for (var item in items) {
      grouped.putIfAbsent(item.taxRate, () => []).add(item);
    }

    return grouped.entries.map((entry) {
      final rate = entry.key;
      final groupItems = entry.value;

      final netAmount = groupItems.fold<double>(0, (sum, it) => sum + (it.quantity * it.rate));
      final vatAmount = groupItems.fold<double>(0, (sum, it) => sum + (it.quantity * it.rate * (it.taxRate / 100)));

      return VatSummary(
        rate: rate,
        netAmount: netAmount,
        vatAmount: vatAmount,
        grossAmount: netAmount + vatAmount,
      );
    }).toList()
      ..sort((a, b) => b.rate.compareTo(a.rate));
  }
}
