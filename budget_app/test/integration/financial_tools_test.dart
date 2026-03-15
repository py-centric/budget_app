import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mocktail/mocktail.dart';
import 'package:budget_app/features/financial_tools/presentation/bloc/financial_bloc.dart';
import 'package:budget_app/features/financial_tools/domain/repositories/financial_repository.dart';
import 'package:budget_app/features/financial_tools/domain/usecases/calculate_net_worth.dart';
import 'package:budget_app/features/financial_tools/domain/usecases/calculate_amortization.dart';
import 'package:budget_app/features/financial_tools/domain/usecases/calculate_compound_interest.dart';
import 'package:budget_app/features/financial_tools/presentation/pages/tools_hub_page.dart';
import 'package:budget_app/features/financial_tools/presentation/pages/net_worth_calculator_page.dart';
import 'package:budget_app/features/financial_tools/presentation/pages/loan_calculator_page.dart';
import 'package:budget_app/features/settings/presentation/bloc/settings_bloc.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:bloc_test/bloc_test.dart';

class MockFinancialRepository extends Mock implements FinancialRepository {}
class MockStorage extends Mock implements Storage {}
class MockSettingsBloc extends MockBloc<SettingsEvent, SettingsState> implements SettingsBloc {}

void main() {
  late MockFinancialRepository mockRepository;
  late MockStorage mockStorage;
  late MockSettingsBloc mockSettingsBloc;

  setUp(() {
    mockRepository = MockFinancialRepository();
    mockStorage = MockStorage();
    mockSettingsBloc = MockSettingsBloc();

    when(() => mockStorage.read(any())).thenReturn(null);
    when(() => mockStorage.write(any(), any())).thenAnswer((_) async {});
    HydratedBloc.storage = mockStorage;

    when(() => mockSettingsBloc.state).thenReturn(const SettingsState());
    when(() => mockRepository.getSavedCalculations()).thenAnswer((_) async => []);
  });

  Widget createWidgetUnderTest(Widget page) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<SettingsBloc>.value(value: mockSettingsBloc),
        BlocProvider<FinancialBloc>(
          create: (context) => FinancialBloc(
            repository: mockRepository,
            calculateNetWorth: CalculateNetWorth(),
            calculateAmortization: CalculateAmortization(),
            calculateCompoundInterest: CalculateCompoundInterest(),
          ),
        ),
      ],
      child: MaterialApp(
        home: page,
      ),
    );
  }

  group('Financial Tools Integration', () {
    testWidgets('should navigate from Hub to Net Worth and calculate value', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest(const ToolsHubPage()));
      
      // Tap on Net Worth Tool
      await tester.tap(find.text('Net Worth'));
      await tester.pumpAndSettle();

      expect(find.byType(NetWorthCalculatorPage), findsOneWidget);

      // Add an asset
      await tester.tap(find.byIcon(Icons.add_circle_outline).first);
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField).at(0), 'Cash');
      await tester.enterText(find.byType(TextField).at(1), '5000');
      await tester.tap(find.text('Add'));
      await tester.pumpAndSettle();

      // Verify calculation
      expect(find.text('\$5,000.00'), findsNWidgets(2)); // Total and list item
    });

    testWidgets('should navigate to Loan Calculator and change interest type', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest(const ToolsHubPage()));

      // Tap on Loans Tool
      await tester.tap(find.text('Loans'));
      await tester.pumpAndSettle();

      expect(find.byType(LoanCalculatorPage), findsOneWidget);

      // Verify default is compound (standard payment for 10k, 5%, 5yr is ~$188.71)
      expect(find.text('\$188.71'), findsOneWidget);

      // Switch to Simple
      await tester.tap(find.text('Simple'));
      await tester.pumpAndSettle();

      // Simple payment: ($10,000 + ($10,000 * 0.05 * 5)) / 60 = $12,500 / 60 = $208.33
      expect(find.text('\$208.33'), findsOneWidget);
    });
  });
}
