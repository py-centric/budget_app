import '../entities/credit_card.dart';

abstract class CreditCardRepository {
  Future<List<CreditCard>> getAllCreditCards();
  Future<CreditCard?> getCreditCardById(String id);
  Future<CreditCard> addCreditCard(CreditCard card);
  Future<void> updateCreditCard(CreditCard card);
  Future<void> deleteCreditCard(String id);
}
