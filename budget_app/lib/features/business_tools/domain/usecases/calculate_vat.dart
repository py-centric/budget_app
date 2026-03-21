class VatResult {
  final double netAmount;
  final double vatAmount;
  final double grossAmount;
  final double vatRate;

  const VatResult({
    required this.netAmount,
    required this.vatAmount,
    required this.grossAmount,
    required this.vatRate,
  });
}

class CalculateVat {
  VatResult fromNet(double net, double rate) {
    final vat = net * (rate / 100);
    return VatResult(
      netAmount: net,
      vatAmount: vat,
      grossAmount: net + vat,
      vatRate: rate,
    );
  }

  VatResult fromGross(double gross, double rate) {
    final net = gross / (1 + (rate / 100));
    return VatResult(
      netAmount: net,
      vatAmount: gross - net,
      grossAmount: gross,
      vatRate: rate,
    );
  }
}
