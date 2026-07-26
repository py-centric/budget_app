import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mocktail/mocktail.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:budget_app/features/settings/presentation/pages/settings_page.dart';
import 'package:budget_app/features/settings/presentation/bloc/settings_bloc.dart';
import 'package:budget_app/features/app_lock/presentation/bloc/app_lock_bloc.dart';
import 'package:budget_app/features/app_lock/presentation/bloc/app_lock_event.dart';
import 'package:budget_app/features/app_lock/presentation/bloc/app_lock_state.dart';
import 'package:budget_app/features/budget/presentation/bloc/budget_bloc.dart';
import 'package:budget_app/features/budget/presentation/bloc/budget_state.dart';
import 'package:budget_app/core/feature_flags/models/release_edition.dart';
import 'package:budget_app/core/feature_flags/presentation/bloc/feature_flags_bloc.dart';

class MockSettingsBloc extends MockBloc<SettingsEvent, SettingsState>
    implements SettingsBloc {}
class MockAppLockBloc extends MockBloc<AppLockEvent, AppLockState>
    implements AppLockBloc {}
class MockBudgetBloc extends Mock implements BudgetBloc {}
class MockStorage extends Mock implements Storage {}

void main() {
  late MockSettingsBloc mockSettingsBloc;
  late MockAppLockBloc mockAppLockBloc;
  late MockBudgetBloc mockBudgetBloc;

  setUpAll(() {
    final storage = MockStorage();
    when(() => storage.write(any(), any())).thenAnswer((_) async {});
    HydratedBloc.storage = storage;
  });

  setUp(() {
    mockSettingsBloc = MockSettingsBloc();
    mockAppLockBloc = MockAppLockBloc();
    mockBudgetBloc = MockBudgetBloc();

    when(() => mockSettingsBloc.state).thenReturn(const SettingsState());
    when(() => mockAppLockBloc.state).thenReturn(const AppLockState());

    when(() => mockBudgetBloc.state).thenReturn(const BudgetInitial());
    when(() => mockBudgetBloc.stream).thenAnswer((_) => const Stream.empty());
  });

  Widget buildSettingsPage() {
    final featureFlagsBloc = FeatureFlagsBloc(initialDefaultEdition: ReleaseEdition.combined);
    return MaterialApp(
      home: MultiBlocProvider(
        providers: [
          BlocProvider<SettingsBloc>.value(value: mockSettingsBloc),
          BlocProvider<AppLockBloc>.value(value: mockAppLockBloc),
          BlocProvider<BudgetBloc>.value(value: mockBudgetBloc),
          BlocProvider<FeatureFlagsBloc>.value(value: featureFlagsBloc),
        ],
        child: const SettingsPage(),
      ),
    );
  }

  testWidgets('renders Developed by PyCentric footer in SettingsPage', (tester) async {
    tester.view.physicalSize = const Size(800, 1600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() => tester.view.resetPhysicalSize());
    addTearDown(() => tester.view.resetDevicePixelRatio());

    await tester.pumpWidget(buildSettingsPage());
    await tester.pumpAndSettle();

    await tester.drag(find.byType(ListView), const Offset(0, -1000));
    await tester.pumpAndSettle();

    expect(find.text('Developed by PyCentric'), findsOneWidget);
  });
}
