import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:budget_app/features/business_tools/domain/usecases/clone_invoice.dart';
import 'package:budget_app/features/business_tools/domain/repositories/business_repository.dart';
import 'package:budget_app/features/business_tools/domain/entities/invoice.dart';
import 'package:budget_app/features/business_tools/domain/entities/invoice_item.dart';

class MockBusinessRepository extends Mock implements BusinessRepository {}
class FakeInvoice extends Fake implements Invoice {}
class FakeInvoiceItem extends Fake implements InvoiceItem {}

void main() {
  late CloneInvoice usecase;
  late MockBusinessRepository mockRepository;

  setUpAll(() {
    registerFallbackValue(FakeInvoice());
    registerFallbackValue(<InvoiceItem>[]);
  });

  setUp(() {
    mockRepository = MockBusinessRepository();
    usecase = CloneInvoice(mockRepository);
  });

  final tSourceInvoice = Invoice(
    id: 'src-123',
    profileId: 'prof-1',
    invoiceNumber: 'INV-SRC',
    date: DateTime(2023, 1, 1),
    clientName: 'Source Client',
    clientDetails: 'Source Details',
    status: InvoiceStatus.paid,
    subTotal: 100,
    taxTotal: 20,
    grandTotal: 120,
    balanceDue: 0,
  );

  final tSourceItems = [
    InvoiceItem(
      id: 'item-1',
      invoiceId: 'src-123',
      description: 'Item 1',
      quantity: 1,
      rate: 100,
      taxRate: 20,
      total: 120,
    ),
  ];

  test('should clone invoice with new ID, Draft status, and reset balance', () async {
    when(() => mockRepository.getInvoice('src-123')).thenAnswer((_) async => tSourceInvoice);
    when(() => mockRepository.getInvoiceItems('src-123')).thenAnswer((_) async => tSourceItems);
    when(() => mockRepository.saveInvoice(any(), any())).thenAnswer((_) async {});

    await usecase.execute('src-123');

    verify(() => mockRepository.saveInvoice(
      any(that: predicate<Invoice>((i) => 
        i.id != 'src-123' &&
        i.status == InvoiceStatus.draft &&
        i.balanceDue == 120 &&
        i.invoiceNumber.startsWith('INV-')
      )),
      any(that: predicate<List<InvoiceItem>>((items) => 
        items.length == 1 &&
        items.first.id != 'item-1' &&
        items.first.invoiceId != 'src-123' &&
        items.first.description == 'Item 1'
      )),
    )).called(1);
  });
}
