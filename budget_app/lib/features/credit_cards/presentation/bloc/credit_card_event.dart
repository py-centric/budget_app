import 'package:equatable/equatable.dart';
import '../../domain/entities/credit_card.dart';

abstract class CreditCardEvent extends Equatable {
  const CreditCardEvent();
  @override
  List<Object?> get props => [];
}

class LoadAllCreditCards extends CreditCardEvent {
  const LoadAllCreditCards();
}

class CreateCreditCardEvent extends CreditCardEvent {
  final String name;
  final String? lastFour;
  final double creditLimit;
  final double currentBalance;
  final double apr;
  final int? billingDay;
  final int? paymentDueDay;
  final double minimumPaymentPercent;

  const CreateCreditCardEvent({
    required this.name,
    this.lastFour,
    required this.creditLimit,
    this.currentBalance = 0,
    this.apr = 0,
    this.billingDay,
    this.paymentDueDay,
    this.minimumPaymentPercent = 2.0,
  });

  @override
  List<Object?> get props => [name, lastFour, creditLimit, currentBalance, apr, billingDay, paymentDueDay, minimumPaymentPercent];
}

class UpdateCreditCardEvent extends CreditCardEvent {
  final CreditCard card;
  const UpdateCreditCardEvent(this.card);
  @override
  List<Object?> get props => [card];
}

class DeleteCreditCardEvent extends CreditCardEvent {
  final String cardId;
  const DeleteCreditCardEvent(this.cardId);
  @override
  List<Object?> get props => [cardId];
}
