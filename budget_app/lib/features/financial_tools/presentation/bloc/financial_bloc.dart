import 'package:equatable/equatable.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:uuid/uuid.dart';
import '../../domain/entities/financial_tool_entry.dart';
import '../../domain/entities/saved_calculation.dart';
import '../../domain/repositories/financial_repository.dart';
import '../../domain/usecases/calculate_net_worth.dart';
import '../../domain/usecases/calculate_amortization.dart';
import '../../domain/usecases/calculate_compound_interest.dart';

// Events
abstract class FinancialEvent extends Equatable {
  const FinancialEvent();
  @override
  List<Object?> get props => [];
}

class UpdateNetWorthAssetsEvent extends FinancialEvent {
  final List<FinancialToolEntry> assets;
  const UpdateNetWorthAssetsEvent(this.assets);
  @override
  List<Object?> get props => [assets];
}

class UpdateNetWorthLiabilitiesEvent extends FinancialEvent {
  final List<FinancialToolEntry> liabilities;
  const UpdateNetWorthLiabilitiesEvent(this.liabilities);
  @override
  List<Object?> get props => [liabilities];
}

class UpdateLoanParamsEvent extends FinancialEvent {
  final double? principal;
  final double? rate;
  final int? years;
  final InterestType? interestType;
  const UpdateLoanParamsEvent({this.principal, this.rate, this.years, this.interestType});
  @override
  List<Object?> get props => [principal, rate, years, interestType];
}

class UpdateSavingsParamsEvent extends FinancialEvent {
  final double? initial;
  final double? monthly;
  final double? rate;
  final int? years;
  final InterestType? interestType;
  const UpdateSavingsParamsEvent({this.initial, this.monthly, this.rate, this.years, this.interestType});
  @override
  List<Object?> get props => [initial, monthly, rate, years, interestType];
}

class SaveCalculationEvent extends FinancialEvent {
  final String name;
  final String type;
  const SaveCalculationEvent({required this.name, required this.type});
  @override
  List<Object?> get props => [name, type];
}

class LoadSavedCalculationsEvent extends FinancialEvent {
  const LoadSavedCalculationsEvent();
}

class DeleteSavedCalculationEvent extends FinancialEvent {
  final String id;
  const DeleteSavedCalculationEvent(this.id);
  @override
  List<Object?> get props => [id];
}

// States
class FinancialState extends Equatable {
  final List<FinancialToolEntry> netWorthAssets;
  final List<FinancialToolEntry> netWorthLiabilities;
  
  // Loan
  final double loanPrincipal;
  final double loanRate;
  final int loanYears;
  final InterestType loanInterestType;

  // Savings
  final double savingsInitial;
  final double savingsMonthly;
  final double savingsRate;
  final int savingsYears;
  final InterestType savingsInterestType;

  final List<SavedCalculation> savedCalculations;
  final bool isLoading;
  final String? error;

  const FinancialState({
    this.netWorthAssets = const [],
    this.netWorthLiabilities = const [],
    this.loanPrincipal = 10000,
    this.loanRate = 5.0,
    this.loanYears = 5,
    this.loanInterestType = InterestType.compound,
    this.savingsInitial = 1000,
    this.savingsMonthly = 100,
    this.savingsRate = 7.0,
    this.savingsYears = 10,
    this.savingsInterestType = InterestType.compound,
    this.savedCalculations = const [],
    this.isLoading = false,
    this.error,
  });

  double get netWorth {
    final assetsTotal = netWorthAssets.fold<double>(0, (sum, e) => sum + e.value);
    final liabilitiesTotal = netWorthLiabilities.fold<double>(0, (sum, e) => sum + e.value);
    return assetsTotal - liabilitiesTotal;
  }

  FinancialState copyWith({
    List<FinancialToolEntry>? netWorthAssets,
    List<FinancialToolEntry>? netWorthLiabilities,
    double? loanPrincipal,
    double? loanRate,
    int? loanYears,
    InterestType? loanInterestType,
    double? savingsInitial,
    double? savingsMonthly,
    double? savingsRate,
    int? savingsYears,
    InterestType? savingsInterestType,
    List<SavedCalculation>? savedCalculations,
    bool? isLoading,
    String? error,
  }) {
    return FinancialState(
      netWorthAssets: netWorthAssets ?? this.netWorthAssets,
      netWorthLiabilities: netWorthLiabilities ?? this.netWorthLiabilities,
      loanPrincipal: loanPrincipal ?? this.loanPrincipal,
      loanRate: loanRate ?? this.loanRate,
      loanYears: loanYears ?? this.loanYears,
      loanInterestType: loanInterestType ?? this.loanInterestType,
      savingsInitial: savingsInitial ?? this.savingsInitial,
      savingsMonthly: savingsMonthly ?? this.savingsMonthly,
      savingsRate: savingsRate ?? this.savingsRate,
      savingsYears: savingsYears ?? this.savingsYears,
      savingsInterestType: savingsInterestType ?? this.savingsInterestType,
      savedCalculations: savedCalculations ?? this.savedCalculations,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }

  @override
  List<Object?> get props => [
    netWorthAssets, netWorthLiabilities, 
    loanPrincipal, loanRate, loanYears, loanInterestType,
    savingsInitial, savingsMonthly, savingsRate, savingsYears, savingsInterestType,
    savedCalculations, isLoading, error
  ];

  Map<String, dynamic> toMap() {
    return {
      'netWorthAssets': netWorthAssets.map((e) => e.toMap()).toList(),
      'netWorthLiabilities': netWorthLiabilities.map((e) => e.toMap()).toList(),
      'loanPrincipal': loanPrincipal,
      'loanRate': loanRate,
      'loanYears': loanYears,
      'loanInterestType': loanInterestType.name,
      'savingsInitial': savingsInitial,
      'savingsMonthly': savingsMonthly,
      'savingsRate': savingsRate,
      'savingsYears': savingsYears,
      'savingsInterestType': savingsInterestType.name,
    };
  }

  factory FinancialState.fromMap(Map<String, dynamic> map) {
    return FinancialState(
      netWorthAssets: (map['netWorthAssets'] as List? ?? [])
          .map((e) => FinancialToolEntry.fromMap(e as Map<String, dynamic>))
          .toList(),
      netWorthLiabilities: (map['netWorthLiabilities'] as List? ?? [])
          .map((e) => FinancialToolEntry.fromMap(e as Map<String, dynamic>))
          .toList(),
      loanPrincipal: (map['loanPrincipal'] as num? ?? 10000).toDouble(),
      loanRate: (map['loanRate'] as num? ?? 5.0).toDouble(),
      loanYears: map['loanYears'] as int? ?? 5,
      loanInterestType: InterestType.values.firstWhere(
        (e) => e.name == (map['loanInterestType'] ?? 'compound'),
        orElse: () => InterestType.compound,
      ),
      savingsInitial: (map['savingsInitial'] as num? ?? 1000).toDouble(),
      savingsMonthly: (map['savingsMonthly'] as num? ?? 100).toDouble(),
      savingsRate: (map['savingsRate'] as num? ?? 7.0).toDouble(),
      savingsYears: map['savingsYears'] as int? ?? 10,
      savingsInterestType: InterestType.values.firstWhere(
        (e) => e.name == (map['savingsInterestType'] ?? 'compound'),
        orElse: () => InterestType.compound,
      ),
    );
  }
}

// Bloc
class FinancialBloc extends HydratedBloc<FinancialEvent, FinancialState> {
  final FinancialRepository repository;
  final CalculateNetWorth calculateNetWorth;
  final CalculateAmortization calculateAmortization;
  final CalculateCompoundInterest calculateCompoundInterest;
  final Uuid _uuid = const Uuid();

  FinancialBloc({
    required this.repository,
    required this.calculateNetWorth,
    required this.calculateAmortization,
    required this.calculateCompoundInterest,
  }) : super(const FinancialState()) {
    on<UpdateNetWorthAssetsEvent>((event, emit) {
      emit(state.copyWith(netWorthAssets: event.assets));
    });

    on<UpdateNetWorthLiabilitiesEvent>((event, emit) {
      emit(state.copyWith(netWorthLiabilities: event.liabilities));
    });

    on<UpdateLoanParamsEvent>((event, emit) {
      emit(state.copyWith(
        loanPrincipal: event.principal,
        loanRate: event.rate,
        loanYears: event.years,
        loanInterestType: event.interestType,
      ));
    });

    on<UpdateSavingsParamsEvent>((event, emit) {
      emit(state.copyWith(
        savingsInitial: event.initial,
        savingsMonthly: event.monthly,
        savingsRate: event.rate,
        savingsYears: event.years,
        savingsInterestType: event.interestType,
      ));
    });

    on<LoadSavedCalculationsEvent>(_onLoadSavedCalculations);
    on<SaveCalculationEvent>(_onSaveCalculation);
    on<DeleteSavedCalculationEvent>(_onDeleteSavedCalculation);
  }

  Future<void> _onLoadSavedCalculations(LoadSavedCalculationsEvent event, Emitter<FinancialState> emit) async {
    emit(state.copyWith(isLoading: true));
    try {
      final calculations = await repository.getSavedCalculations();
      emit(state.copyWith(savedCalculations: calculations, isLoading: false));
    } catch (e) {
      emit(state.copyWith(error: e.toString(), isLoading: false));
    }
  }

  Future<void> _onSaveCalculation(SaveCalculationEvent event, Emitter<FinancialState> emit) async {
    try {
      Map<String, dynamic> data = {};
      if (event.type == 'NET_WORTH') {
        data = {
          'assets': state.netWorthAssets.map((e) => e.toMap()).toList(),
          'liabilities': state.netWorthLiabilities.map((e) => e.toMap()).toList(),
          'total': state.netWorth,
        };
      } else if (event.type == 'LOAN') {
        data = {
          'principal': state.loanPrincipal,
          'rate': state.loanRate,
          'years': state.loanYears,
          'interestType': state.loanInterestType.name,
          'monthlyPayment': calculateAmortization.calculateMonthlyPayment(
            principal: state.loanPrincipal,
            annualRate: state.loanRate,
            years: state.loanYears,
            type: state.loanInterestType,
          ),
        };
      } else if (event.type == 'SAVINGS') {
        data = {
          'initial': state.savingsInitial,
          'monthly': state.savingsMonthly,
          'rate': state.savingsRate,
          'years': state.savingsYears,
          'interestType': state.savingsInterestType.name,
          'futureValue': calculateCompoundInterest.calculateFutureValue(
            initialDeposit: state.savingsInitial,
            monthlyContribution: state.savingsMonthly,
            annualRate: state.savingsRate,
            years: state.savingsYears,
            type: state.savingsInterestType,
          ),
        };
      }

      final calculation = SavedCalculation(
        id: _uuid.v4(),
        type: event.type,
        name: event.name,
        data: data,
        createdAt: DateTime.now(),
      );

      await repository.saveCalculation(calculation);
      add(const LoadSavedCalculationsEvent());
    } catch (e) {
      emit(state.copyWith(error: e.toString()));
    }
  }

  Future<void> _onDeleteSavedCalculation(DeleteSavedCalculationEvent event, Emitter<FinancialState> emit) async {
    try {
      await repository.deleteCalculation(event.id);
      add(const LoadSavedCalculationsEvent());
    } catch (e) {
      emit(state.copyWith(error: e.toString()));
    }
  }

  @override
  FinancialState? fromJson(Map<String, dynamic> json) {
    return FinancialState.fromMap(json);
  }

  @override
  Map<String, dynamic>? toJson(FinancialState state) {
    return state.toMap();
  }
}
