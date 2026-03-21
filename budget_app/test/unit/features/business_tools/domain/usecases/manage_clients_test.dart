import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:budget_app/features/business_tools/domain/usecases/manage_clients.dart';
import 'package:budget_app/features/business_tools/domain/repositories/business_repository.dart';
import 'package:budget_app/features/business_tools/domain/entities/client.dart';

class MockBusinessRepository extends Mock implements BusinessRepository {}

void main() {
  late ManageClients usecase;
  late MockBusinessRepository mockRepository;

  setUp(() {
    mockRepository = MockBusinessRepository();
    usecase = ManageClients(mockRepository);
  });

  final tClient = Client(
    id: '1',
    name: 'Test',
    address: '123',
  );

  test('should call saveClient on the repository', () async {
    when(() => mockRepository.saveClient(tClient)).thenAnswer((_) async {});

    await usecase.executeSave(tClient);

    verify(() => mockRepository.saveClient(tClient)).called(1);
    verifyNoMoreInteractions(mockRepository);
  });

  test('should call deleteClient on the repository', () async {
    when(() => mockRepository.deleteClient('1')).thenAnswer((_) async {});

    await usecase.executeDelete('1');

    verify(() => mockRepository.deleteClient('1')).called(1);
    verifyNoMoreInteractions(mockRepository);
  });
}
