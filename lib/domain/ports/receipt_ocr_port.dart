/// Hexagonal port for sovereign offline receipt OCR and expense categorization.
class ParsedReceiptDto {
  final String merchant;
  final int totalCents;
  final String category;

  const ParsedReceiptDto({
    required this.merchant,
    required this.totalCents,
    required this.category,
  });
}

abstract interface class ReceiptOcrPort {
  Future<ParsedReceiptDto> extractReceipt(String imagePath);
}
