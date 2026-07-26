import 'package:flutter_test/flutter_test.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:mocktail/mocktail.dart';
import 'package:budget_app/core/feature_flags/models/release_edition.dart';
import 'package:budget_app/core/feature_flags/models/feature_flag.dart';
import 'package:budget_app/core/feature_flags/presentation/bloc/feature_flags_bloc.dart';
import 'package:budget_app/core/feature_flags/presentation/bloc/feature_flags_event.dart';
import 'package:budget_app/core/feature_flags/presentation/bloc/feature_flags_state.dart';

class MockStorage extends Mock implements Storage {}

void main() {
  late Storage storage;

  setUp(() {
    storage = MockStorage();
    when(() => storage.write(any(), any())).thenAnswer((_) async {});
    HydratedBloc.storage = storage;
  });

  group('FeatureFlagsBloc tests', () {
    test('initial state defaults to specified edition or combined', () {
      final bloc = FeatureFlagsBloc(initialDefaultEdition: ReleaseEdition.personal);
      expect(bloc.state.defaultEdition, ReleaseEdition.personal);
      expect(bloc.state.effectiveEdition, ReleaseEdition.personal);
      expect(bloc.state.isFeatureEnabled(FeatureFlag.personalBudgets), isTrue);
      expect(bloc.state.isFeatureEnabled(FeatureFlag.invoicingPayables), isFalse);
    });

    test('SetRuntimeEditionOverrideEvent overrides active features', () async {
      final bloc = FeatureFlagsBloc(initialDefaultEdition: ReleaseEdition.personal);
      expect(bloc.state.isFeatureEnabled(FeatureFlag.invoicingPayables), isFalse);

      bloc.add(const SetRuntimeEditionOverrideEvent(ReleaseEdition.business));
      await expectLater(
        bloc.stream,
        emitsThrough(predicate<FeatureFlagsState>((state) {
          return state.effectiveEdition == ReleaseEdition.business &&
              state.isFeatureEnabled(FeatureFlag.invoicingPayables) == true &&
              state.isFeatureEnabled(FeatureFlag.personalBudgets) == false;
        })),
      );
    });

    test('ClearRuntimeEditionOverrideEvent restores default edition', () async {
      final bloc = FeatureFlagsBloc(initialDefaultEdition: ReleaseEdition.personal);
      bloc.add(const SetRuntimeEditionOverrideEvent(ReleaseEdition.business));
      await bloc.stream.firstWhere((s) => s.effectiveEdition == ReleaseEdition.business);

      bloc.add(const ClearRuntimeEditionOverrideEvent());
      await expectLater(
        bloc.stream,
        emitsThrough(predicate<FeatureFlagsState>((state) {
          return state.effectiveEdition == ReleaseEdition.personal &&
              state.runtimeOverride == null;
        })),
      );
    });
  });
}
