import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';
import '../../domain/entities/investment.dart';
import '../../domain/repositories/investment_repository.dart';
import 'investment_event.dart';
import 'investment_state.dart';

class InvestmentBloc extends Bloc<InvestmentEvent, InvestmentState> {
  final InvestmentRepository _repository;
  final _uuid = const Uuid();

  InvestmentBloc({required InvestmentRepository repository})
      : _repository = repository,
        super(const InvestmentInitial()) {
    on<LoadAllInvestments>(_onLoadAllInvestments);
    on<AddInvestmentEvent>(_onAddInvestment);
    on<UpdateInvestmentEvent>(_onUpdateInvestment);
    on<DeleteInvestmentEvent>(_onDeleteInvestment);
  }

  Future<void> _onLoadAllInvestments(LoadAllInvestments event, Emitter<InvestmentState> emit) async {
    emit(const InvestmentLoading());
    final investments = await _repository.getAllInvestments();
    emit(InvestmentLoaded(investments));
  }

  Future<void> _onAddInvestment(AddInvestmentEvent event, Emitter<InvestmentState> emit) async {
    final investment = Investment(
      id: _uuid.v4(),
      name: event.name,
      ticker: event.ticker,
      shares: event.shares,
      avgCost: event.avgCost,
      currentPrice: event.currentPrice,
    );
    await _repository.addInvestment(investment);
    final investments = await _repository.getAllInvestments();
    emit(InvestmentLoaded(investments));
  }

  Future<void> _onUpdateInvestment(UpdateInvestmentEvent event, Emitter<InvestmentState> emit) async {
    await _repository.updateInvestment(event.investment);
    final investments = await _repository.getAllInvestments();
    emit(InvestmentLoaded(investments));
  }

  Future<void> _onDeleteInvestment(DeleteInvestmentEvent event, Emitter<InvestmentState> emit) async {
    await _repository.deleteInvestment(event.investmentId);
    final investments = await _repository.getAllInvestments();
    emit(InvestmentLoaded(investments));
  }
}
