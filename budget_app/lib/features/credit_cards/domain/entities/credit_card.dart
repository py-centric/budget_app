import 'package:equatable/equatable.dart';

class CreditCard extends Equatable {
  final String id;
  final String name;
  final String? lastFour;
  final double creditLimit;
  final double currentBalance;
  final double apr;
  final int? billingDay;
  final int? paymentDueDay;
  final double minimumPaymentPercent;
  final DateTime? lastUpdated;

  const CreditCard({
    required this.id,
    required this.name,
    this.lastFour,
    required this.creditLimit,
    this.currentBalance = 0,
    this.apr = 0,
    this.billingDay,
    this.paymentDueDay,
    this.minimumPaymentPercent = 2.0,
    this.lastUpdated,
  });

  double get availableCredit => creditLimit - currentBalance;
  double get utilizationPercent => creditLimit > 0 ? (currentBalance / creditLimit * 100) : 0;
  double get minimumPayment => currentBalance * minimumPaymentPercent / 100;

  factory CreditCard.fromMap(Map<String, dynamic> map) {
    return CreditCard(
      id: map['id'] as String,
      name: map['name'] as String,
      lastFour: map['last_four'] as String?,
      creditLimit: (map['credit_limit'] as num).toDouble(),
      currentBalance: (map['current_balance'] as num? ?? 0).toDouble(),
      apr: (map['apr'] as num? ?? 0).toDouble(),
      billingDay: map['billing_day'] as int?,
      paymentDueDay: map['payment_due_day'] as int?,
      minimumPaymentPercent: (map['minimum_payment_percent'] as num? ?? 2).toDouble(),
      lastUpdated: map['last_updated'] != null ? DateTime.parse(map['last_updated'] as String) : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'last_four': lastFour,
      'credit_limit': creditLimit,
      'current_balance': currentBalance,
      'apr': apr,
      'billing_day': billingDay,
      'payment_due_day': paymentDueDay,
      'minimum_payment_percent': minimumPaymentPercent,
      'last_updated': lastUpdated?.toIso8601String(),
    };
  }

  CreditCard copyWith({
    String? id,
    String? name,
    String? lastFour,
    double? creditLimit,
    double? currentBalance,
    double? apr,
    int? billingDay,
    int? paymentDueDay,
    double? minimumPaymentPercent,
    DateTime? lastUpdated,
  }) {
    return CreditCard(
      id: id ?? this.id,
      name: name ?? this.name,
      lastFour: lastFour ?? this.lastFour,
      creditLimit: creditLimit ?? this.creditLimit,
      currentBalance: currentBalance ?? this.currentBalance,
      apr: apr ?? this.apr,
      billingDay: billingDay ?? this.billingDay,
      paymentDueDay: paymentDueDay ?? this.paymentDueDay,
      minimumPaymentPercent: minimumPaymentPercent ?? this.minimumPaymentPercent,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }

  @override
  List<Object?> get props => [id, name, lastFour, creditLimit, currentBalance, apr, billingDay, paymentDueDay];
}
