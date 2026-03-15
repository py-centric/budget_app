class CalculateNetWorth {
  double call(List<double> assets, List<double> liabilities) {
    final totalAssets = assets.fold<double>(0, (sum, val) => sum + val);
    final totalLiabilities = liabilities.fold<double>(0, (sum, val) => sum + val);
    return totalAssets - totalLiabilities;
  }
}
