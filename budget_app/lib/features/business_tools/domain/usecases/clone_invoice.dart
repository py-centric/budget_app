import 'package:uuid/uuid.dart';
import 'package:budget_app/features/business_tools/domain/entities/invoice.dart';
import 'package:budget_app/features/business_tools/domain/repositories/business_repository.dart';
import 'package:intl/intl.dart';

class CloneInvoice {
  final BusinessRepository _repository;

  CloneInvoice(this._repository);

  Future<void> execute(String sourceInvoiceId) async {
    final sourceInvoice = await _repository.getInvoice(sourceInvoiceId);
    if (sourceInvoice == null) {
      throw Exception('Source invoice not found');
    }

    final sourceItems = await _repository.getInvoiceItems(sourceInvoiceId);

    final newInvoiceId = const Uuid().v4();
    final newDate = DateTime.now();
    final newInvoiceNumber = 'INV-${DateFormat('yyyyMMdd-HHmm').format(newDate)}';

    final clonedInvoice = sourceInvoice.copyWith(
      id: newInvoiceId,
      invoiceNumber: newInvoiceNumber,
      date: newDate,
      status: InvoiceStatus.draft,
      balanceDue: sourceInvoice.grandTotal, // Reset balance due to full amount
    );

    final clonedItems = sourceItems.map((item) => item.copyWith(
      id: const Uuid().v4(),
      invoiceId: newInvoiceId,
    )).toList();

    await _repository.saveInvoice(clonedInvoice, clonedItems);
  }
}
