import 'package:equatable/equatable.dart';
import '../../domain/entities/credit_card.dart';

abstract class CreditCardState extends Equatable {
  const CreditCardState();
  @override
  List<Object?> get props => [];
}

class CreditCardInitial extends CreditCardState {
  const CreditCardInitial();
}

class CreditCardLoading extends CreditCardState {
  const CreditCardLoading();
}

class CreditCardLoaded extends CreditCardState {
  final List<CreditCard> creditCards;
  const CreditCardLoaded(this.creditCards);
  @override
  List<Object?> get props => [creditCards];
}

class CreditCardError extends CreditCardState {
  final String message;
  const CreditCardError(this.message);
  @override
  List<Object?> get props => [message];
}
