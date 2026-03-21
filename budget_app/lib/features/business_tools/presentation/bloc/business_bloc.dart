import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:budget_app/features/business_tools/domain/repositories/business_repository.dart';
import 'package:budget_app/features/business_tools/domain/usecases/clone_invoice.dart';
import 'package:budget_app/features/business_tools/domain/usecases/calculate_invoice_stats.dart';
import 'business_event.dart';
import 'business_state.dart';

class BusinessBloc extends Bloc<BusinessEvent, BusinessState> {
  final BusinessRepository _repository;

  BusinessBloc(this._repository) : super(const BusinessState()) {
    on<LoadBusinessData>(_onLoadBusinessData);
    on<SaveProfile>(_onSaveProfile);
    on<DeleteProfile>(_onDeleteProfile);
    on<SaveClient>(_onSaveClient);
    on<DeleteClient>(_onDeleteClient);
    on<SaveReceivedInvoice>(_onSaveReceivedInvoice);
    on<DeleteReceivedInvoice>(_onDeleteReceivedInvoice);
    on<FilterInvoices>(_onFilterInvoices);
    on<SaveInvoice>(_onSaveInvoice);
    on<DeleteInvoice>(_onDeleteInvoice);
    on<CloneInvoiceEvent>(_onCloneInvoice);
    on<AddPayment>(_onAddPayment);
    on<ClearLastSavedInvoice>(_onClearLastSavedInvoice);
  }

  Future<void> _onLoadBusinessData(LoadBusinessData event, Emitter<BusinessState> emit) async {
    emit(state.copyWith(status: BusinessStatus.loading));
    try {
      final profiles = await _repository.getProfiles();
      final clients = await _repository.getClients();
      final invoices = await _repository.getInvoices();
      final receivedInvoices = await _repository.getReceivedInvoices();

      final summary = CalculateInvoiceStats.execute(
        outgoingInvoices: invoices,
        receivedInvoices: receivedInvoices,
      );

      emit(state.copyWith(
        status: BusinessStatus.success,
        profiles: profiles,
        clients: clients,
        invoices: invoices,
        receivedInvoices: receivedInvoices,
        summary: summary,
      ));
    } catch (e) {
      emit(state.copyWith(status: BusinessStatus.failure, errorMessage: e.toString()));
    }
  }

  Future<void> _onSaveProfile(SaveProfile event, Emitter<BusinessState> emit) async {
    try {
      await _repository.saveProfile(event.profile);
      add(LoadBusinessData());
    } catch (e) {
      emit(state.copyWith(errorMessage: e.toString()));
    }
  }

  Future<void> _onDeleteProfile(DeleteProfile event, Emitter<BusinessState> emit) async {
    try {
      await _repository.deleteProfile(event.id);
      add(LoadBusinessData());
    } catch (e) {
      emit(state.copyWith(errorMessage: e.toString()));
    }
  }

  Future<void> _onSaveClient(SaveClient event, Emitter<BusinessState> emit) async {
    try {
      await _repository.saveClient(event.client);
      add(LoadBusinessData());
    } catch (e) {
      emit(state.copyWith(errorMessage: e.toString()));
    }
  }

  Future<void> _onDeleteClient(DeleteClient event, Emitter<BusinessState> emit) async {
    try {
      await _repository.deleteClient(event.id);
      add(LoadBusinessData());
    } catch (e) {
      emit(state.copyWith(errorMessage: e.toString()));
    }
  }

  Future<void> _onSaveReceivedInvoice(SaveReceivedInvoice event, Emitter<BusinessState> emit) async {
    try {
      await _repository.saveReceivedInvoice(event.invoice);
      add(LoadBusinessData());
    } catch (e) {
      emit(state.copyWith(errorMessage: e.toString()));
    }
  }

  Future<void> _onDeleteReceivedInvoice(DeleteReceivedInvoice event, Emitter<BusinessState> emit) async {
    try {
      await _repository.deleteReceivedInvoice(event.id);
      add(LoadBusinessData());
    } catch (e) {
      emit(state.copyWith(errorMessage: e.toString()));
    }
  }

  void _onFilterInvoices(FilterInvoices event, Emitter<BusinessState> emit) {
    emit(state.copyWith(filterRange: event.range));
  }

  Future<void> _onSaveInvoice(SaveInvoice event, Emitter<BusinessState> emit) async {
    try {
      await _repository.saveInvoice(event.invoice, event.items);
      final profiles = await _repository.getProfiles();
      final clients = await _repository.getClients();
      final invoices = await _repository.getInvoices();
      final receivedInvoices = await _repository.getReceivedInvoices();

      final summary = CalculateInvoiceStats.execute(
        outgoingInvoices: invoices,
        receivedInvoices: receivedInvoices,
      );

      emit(state.copyWith(
        status: BusinessStatus.success,
        profiles: profiles,
        clients: clients,
        invoices: invoices,
        receivedInvoices: receivedInvoices,
        summary: summary,
        lastSavedInvoice: event.invoice,
        lastSavedItems: event.items,
      ));
    } catch (e) {
      emit(state.copyWith(errorMessage: e.toString()));
    }
  }

  Future<void> _onDeleteInvoice(DeleteInvoice event, Emitter<BusinessState> emit) async {
    try {
      await _repository.deleteInvoice(event.id);
      add(LoadBusinessData());
    } catch (e) {
      emit(state.copyWith(errorMessage: e.toString()));
    }
  }

  Future<void> _onCloneInvoice(CloneInvoiceEvent event, Emitter<BusinessState> emit) async {
    try {
      final cloneUseCase = CloneInvoice(_repository);
      await cloneUseCase.execute(event.id);
      add(LoadBusinessData());
    } catch (e) {
      emit(state.copyWith(errorMessage: e.toString()));
    }
  }

  Future<void> _onAddPayment(AddPayment event, Emitter<BusinessState> emit) async {
    try {
      await _repository.savePayment(event.payment);
      add(LoadBusinessData());
    } catch (e) {
      emit(state.copyWith(errorMessage: e.toString()));
    }
  }

  void _onClearLastSavedInvoice(ClearLastSavedInvoice event, Emitter<BusinessState> emit) {
    emit(state.copyWith(clearLastSavedInvoice: true));
  }
}
