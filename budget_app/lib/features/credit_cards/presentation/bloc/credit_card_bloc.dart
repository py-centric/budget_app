import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';
import '../../domain/entities/credit_card.dart';
import '../../domain/repositories/credit_card_repository.dart';
import 'credit_card_event.dart';
import 'credit_card_state.dart';

class CreditCardBloc extends Bloc<CreditCardEvent, CreditCardState> {
  final CreditCardRepository _repository;
  final _uuid = const Uuid();

  CreditCardBloc({required CreditCardRepository repository})
      : _repository = repository,
        super(const CreditCardInitial()) {
    on<LoadAllCreditCards>(_onLoadAllCreditCards);
    on<CreateCreditCardEvent>(_onCreateCreditCard);
    on<UpdateCreditCardEvent>(_onUpdateCreditCard);
    on<DeleteCreditCardEvent>(_onDeleteCreditCard);
  }

  Future<void> _onLoadAllCreditCards(LoadAllCreditCards event, Emitter<CreditCardState> emit) async {
    emit(const CreditCardLoading());
    final cards = await _repository.getAllCreditCards();
    emit(CreditCardLoaded(cards));
  }

  Future<void> _onCreateCreditCard(CreateCreditCardEvent event, Emitter<CreditCardState> emit) async {
    final card = CreditCard(
      id: _uuid.v4(),
      name: event.name,
      lastFour: event.lastFour,
      creditLimit: event.creditLimit,
      currentBalance: event.currentBalance,
      apr: event.apr,
      billingDay: event.billingDay,
      paymentDueDay: event.paymentDueDay,
      minimumPaymentPercent: event.minimumPaymentPercent,
      lastUpdated: DateTime.now(),
    );
    await _repository.addCreditCard(card);
    final cards = await _repository.getAllCreditCards();
    emit(CreditCardLoaded(cards));
  }

  Future<void> _onUpdateCreditCard(UpdateCreditCardEvent event, Emitter<CreditCardState> emit) async {
    await _repository.updateCreditCard(event.card.copyWith(lastUpdated: DateTime.now()));
    final cards = await _repository.getAllCreditCards();
    emit(CreditCardLoaded(cards));
  }

  Future<void> _onDeleteCreditCard(DeleteCreditCardEvent event, Emitter<CreditCardState> emit) async {
    await _repository.deleteCreditCard(event.cardId);
    final cards = await _repository.getAllCreditCards();
    emit(CreditCardLoaded(cards));
  }
}
