import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mocktail/mocktail.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:budget_app/features/accounts/domain/entities/account.dart';
import 'package:budget_app/features/accounts/domain/entities/loan_account.dart';
import 'package:budget_app/features/accounts/domain/usecases/calculate_net_worth.dart';
import 'package:budget_app/features/accounts/presentation/pages/accounts_page.dart';
import 'package:budget_app/features/accounts/presentation/bloc/account_bloc.dart';
import 'package:budget_app/features/accounts/presentation/bloc/account_event.dart';
import 'package:budget_app/features/accounts/presentation/bloc/account_state.dart';
import 'package:budget_app/features/settings/presentation/bloc/settings_bloc.dart';

class MockAccountBloc extends MockBloc<AccountEvent, AccountState>
    implements AccountBloc {}

class MockSettingsBloc extends MockBloc<SettingsEvent, SettingsState>
    implements SettingsBloc {}

void main() {
  late MockAccountBloc mockAccountBloc;
  late MockSettingsBloc mockSettingsBloc;

  setUp(() {
    mockAccountBloc = MockAccountBloc();
    mockSettingsBloc = MockSettingsBloc();

    when(() => mockSettingsBloc.state).thenReturn(const SettingsState());
  });

  Widget buildWidgetUnderTest() {
    return MaterialApp(
      home: MultiBlocProvider(
        providers: [
          BlocProvider<AccountBloc>.value(value: mockAccountBloc),
          BlocProvider<SettingsBloc>.value(value: mockSettingsBloc),
        ],
        child: const AccountsPage(),
      ),
    );
  }

  testWidgets('renders NetWorthHeader and accounts list in AccountsPage', (tester) async {
    final now = DateTime.now();
    final checkingAcc = Account(
      id: '1',
      name: 'Main Checking',
      type: AccountType.checking,
      balance: 5000.0,
      currency: 'USD',
      createdAt: now,
      updatedAt: now,
    );
    final loanAcc = LoanAccount(
      account: Account(
        id: '2',
        name: 'Car Loan',
        type: AccountType.loan,
        balance: -2000.0,
        currency: 'USD',
        createdAt: now,
        updatedAt: now,
      ),
      originalPrincipal: 2000.0,
      currentPrincipal: 2000.0,
      interestRateApr: 5.0,
      minimumMonthlyPayment: 100.0,
      originationDate: now,
    );

    when(() => mockAccountBloc.state).thenReturn(
      AccountLoaded(
        accounts: [checkingAcc],
        loanAccounts: [loanAcc],
        netWorthSummary: const NetWorthSummary(
          totalAssets: 5000.0,
          totalLiabilities: 2000.0,
          netWorth: 3000.0,
        ),
        totalBalance: 3000.0,
      ),
    );

    await tester.pumpWidget(buildWidgetUnderTest());
    await tester.pumpAndSettle();

    expect(find.text('Net Worth'), findsOneWidget);
    expect(find.text('Main Checking'), findsOneWidget);
    expect(find.text('Car Loan'), findsOneWidget);
  });
}
