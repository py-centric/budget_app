class Currency {
  final String code;
  final String name;
  final String symbol;

  const Currency({
    required this.code,
    required this.name,
    required this.symbol,
  });
}

class Currencies {
  static const List<Currency> all = [
    Currency(code: 'USD', name: 'US Dollar', symbol: '\$'),
    Currency(code: 'EUR', name: 'Euro', symbol: '€'),
    Currency(code: 'GBP', name: 'British Pound', symbol: '£'),
    Currency(code: 'JPY', name: 'Japanese Yen', symbol: '¥'),
    Currency(code: 'AUD', name: 'Australian Dollar', symbol: '\$'),
    Currency(code: 'CAD', name: 'Canadian Dollar', symbol: '\$'),
    Currency(code: 'CHF', name: 'Swiss Franc', symbol: 'Fr'),
    Currency(code: 'CNY', name: 'Chinese Yuan', symbol: '¥'),
    Currency(code: 'INR', name: 'Indian Rupee', symbol: '₹'),
    Currency(code: 'MXN', name: 'Mexican Peso', symbol: '\$'),
    Currency(code: 'BRL', name: 'Brazilian Real', symbol: 'R\$'),
    Currency(code: 'KRW', name: 'South Korean Won', symbol: '₩'),
    Currency(code: 'SGD', name: 'Singapore Dollar', symbol: '\$'),
    Currency(code: 'HKD', name: 'Hong Kong Dollar', symbol: '\$'),
    Currency(code: 'NOK', name: 'Norwegian Krone', symbol: 'kr'),
    Currency(code: 'SEK', name: 'Swedish Krona', symbol: 'kr'),
    Currency(code: 'DKK', name: 'Danish Krone', symbol: 'kr'),
    Currency(code: 'NZD', name: 'New Zealand Dollar', symbol: '\$'),
    Currency(code: 'ZAR', name: 'South African Rand', symbol: 'R'),
    Currency(code: 'THB', name: 'Thai Baht', symbol: '฿'),
  ];

  static List<Currency> search(String query) {
    if (query.isEmpty) return all;

    final lowerQuery = query.toLowerCase();
    return all.where((currency) {
      return currency.code.toLowerCase().contains(lowerQuery) ||
          currency.name.toLowerCase().contains(lowerQuery);
    }).toList();
  }
}
