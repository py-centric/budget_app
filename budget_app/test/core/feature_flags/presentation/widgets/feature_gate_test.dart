import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:mocktail/mocktail.dart';
import 'package:budget_app/core/feature_flags/models/release_edition.dart';
import 'package:budget_app/core/feature_flags/models/feature_flag.dart';
import 'package:budget_app/core/feature_flags/presentation/bloc/feature_flags_bloc.dart';
import 'package:budget_app/core/feature_flags/presentation/widgets/feature_gate.dart';

class MockStorage extends Mock implements Storage {}

void main() {
  late Storage storage;

  setUp(() {
    storage = MockStorage();
    when(() => storage.write(any(), any())).thenAnswer((_) async {});
    HydratedBloc.storage = storage;
  });

  Widget makeTestableWidget({
    required FeatureFlagsBloc bloc,
    required Widget child,
  }) {
    return BlocProvider<FeatureFlagsBloc>.value(
      value: bloc,
      child: MaterialApp(
        home: Scaffold(
          body: child,
        ),
      ),
    );
  }

  group('FeatureGate widget tests', () {
    testWidgets('renders child when flag is enabled', (tester) async {
      final bloc = FeatureFlagsBloc(initialDefaultEdition: ReleaseEdition.personal);

      await tester.pumpWidget(
        makeTestableWidget(
          bloc: bloc,
          child: const FeatureGate(
            flag: FeatureFlag.personalBudgets,
            child: Text('Personal Budgets Active'),
          ),
        ),
      );

      expect(find.text('Personal Budgets Active'), findsOneWidget);
    });

    testWidgets('renders fallback when flag is disabled', (tester) async {
      final bloc = FeatureFlagsBloc(initialDefaultEdition: ReleaseEdition.personal);

      await tester.pumpWidget(
        makeTestableWidget(
          bloc: bloc,
          child: const FeatureGate(
            flag: FeatureFlag.invoicingPayables,
            fallback: Text('Invoicing Disabled'),
            child: Text('Invoicing Active'),
          ),
        ),
      );

      expect(find.text('Invoicing Active'), findsNothing);
      expect(find.text('Invoicing Disabled'), findsOneWidget);
    });
  });
}
