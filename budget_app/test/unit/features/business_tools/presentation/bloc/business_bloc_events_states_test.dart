import 'package:flutter_test/flutter_test.dart';
import 'package:budget_app/features/business_tools/presentation/bloc/business_event.dart';
import 'package:budget_app/features/business_tools/presentation/bloc/business_state.dart';

void main() {
  group('BusinessEvent', () {
    test('LoadBusinessData props', () {
      expect(LoadBusinessData().props, isEmpty);
    });

    test('ClearLastSavedInvoice props', () {
      expect(ClearLastSavedInvoice().props, isEmpty);
    });

    test('DeleteProfile props', () {
      const event = DeleteProfile('p-1');
      expect(event.props, ['p-1']);
    });

    test('DeleteClient props', () {
      const event = DeleteClient('c-1');
      expect(event.props, ['c-1']);
    });

    test('DeleteReceivedInvoice props', () {
      const event = DeleteReceivedInvoice('ri-1');
      expect(event.props, ['ri-1']);
    });

    test('DeleteInvoice props', () {
      const event = DeleteInvoice('inv-1');
      expect(event.props, ['inv-1']);
    });

    test('CloneInvoiceEvent props', () {
      const event = CloneInvoiceEvent('inv-1');
      expect(event.props, ['inv-1']);
    });
  });

  group('BusinessStatus', () {
    test('has correct values', () {
      expect(BusinessStatus.values.length, 4);
      expect(BusinessStatus.values, contains(BusinessStatus.initial));
      expect(BusinessStatus.values, contains(BusinessStatus.loading));
      expect(BusinessStatus.values, contains(BusinessStatus.success));
      expect(BusinessStatus.values, contains(BusinessStatus.failure));
    });
  });

  group('BusinessState', () {
    test('default state', () {
      const state = BusinessState();
      expect(state.status, BusinessStatus.initial);
      expect(state.profiles, isEmpty);
      expect(state.clients, isEmpty);
      expect(state.invoices, isEmpty);
      expect(state.receivedInvoices, isEmpty);
      expect(state.summary, isNull);
      expect(state.filterRange, isNull);
      expect(state.errorMessage, isNull);
      expect(state.lastSavedInvoice, isNull);
      expect(state.lastSavedItems, isNull);
    });

    test('copyWith status', () {
      const state = BusinessState();
      final updated = state.copyWith(status: BusinessStatus.loading);
      expect(updated.status, BusinessStatus.loading);
      expect(updated.profiles, isEmpty);
    });

    test('copyWith clearLastSavedInvoice', () {
      const state = BusinessState(
        status: BusinessStatus.success,
        lastSavedInvoice: null,
      );
      final cleared = state.copyWith(clearLastSavedInvoice: true);
      expect(cleared.lastSavedInvoice, isNull);
      expect(cleared.lastSavedItems, isNull);
    });

    test('copyWith errorMessage', () {
      const state = BusinessState();
      final withError = state.copyWith(errorMessage: 'Something went wrong');
      expect(withError.errorMessage, 'Something went wrong');
    });

    test('props include all fields', () {
      const state = BusinessState();
      expect(state.props.length, 10);
    });
  });
}
