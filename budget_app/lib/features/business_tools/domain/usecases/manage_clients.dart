import 'package:budget_app/features/business_tools/domain/repositories/business_repository.dart';
import 'package:budget_app/features/business_tools/domain/entities/client.dart';

class ManageClients {
  final BusinessRepository _repository;

  ManageClients(this._repository);

  Future<void> executeSave(Client client) async {
    await _repository.saveClient(client);
  }

  Future<void> executeDelete(String id) async {
    await _repository.deleteClient(id);
  }
}
