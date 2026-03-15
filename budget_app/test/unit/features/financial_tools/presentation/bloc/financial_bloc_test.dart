import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:budget_app/features/financial_tools/presentation/bloc/financial_bloc.dart';
import 'package:budget_app/features/financial_tools/domain/repositories/financial_repository.dart';
import 'package:budget_app/features/financial_tools/domain/usecases/calculate_net_worth.dart';
import 'package:budget_app/features/financial_tools/domain/usecases/calculate_amortization.dart';
import 'package:budget_app/features/financial_tools/domain/usecases/calculate_compound_interest.dart';
import 'package:budget_app/features/financial_tools/domain/entities/financial_tool_entry.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';

class MockFinancialRepository extends Mock implements FinancialRepository {}
class MockStorage extends Mock implements Storage {}

void main() {
  late FinancialBloc financialBloc;
  late MockFinancialRepository mockRepository;
  late MockStorage mockStorage;

  setUp(() {
    mockRepository = MockFinancialRepository();
    mockStorage = MockStorage();
    
    when(() => mockStorage.read(any())).thenReturn(null);
    when(() => mockStorage.write(any(), any())).thenAnswer((_) async {});
    HydratedBloc.storage = mockStorage;

    financialBloc = FinancialBloc(
      repository: mockRepository,
      calculateNetWorth: CalculateNetWorth(),
      calculateAmortization: CalculateAmortization(),
      calculateCompoundInterest: CalculateCompoundInterest(),
    );
  });

  tearDown(() {
    financialBloc.close();
  });

  group('FinancialBloc', () {
    test('initial state should be default values', () {
      expect(financialBloc.state, const FinancialState());
    });

    blocTest<FinancialBloc, FinancialState>(
      'emits updated state when Net Worth assets are added',
      build: () => financialBloc,
      act: (bloc) => bloc.add(const UpdateNetWorthAssetsEvent([
        FinancialToolEntry(label: 'Cash', value: 1000)
      ])),
      expect: () => [
        const FinancialState(netWorthAssets: [
          FinancialToolEntry(label: 'Cash', value: 1000)
        ])
      ],
    );

    blocTest<FinancialBloc, FinancialState>(
      'emits updated state when Loan params are updated',
      build: () => financialBloc,
      act: (bloc) => bloc.add(const UpdateLoanParamsEvent(
        principal: 5000,
        rate: 10,
        years: 3,
        interestType: InterestType.simple,
      )),
      expect: () => [
        const FinancialState(
          loanPrincipal: 5000,
          loanRate: 10,
          loanYears: 3,
          loanInterestType: InterestType.simple,
        )
      ],
    );
  });
}
