import 'package:flutter_test/flutter_test.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:mocktail/mocktail.dart';
import 'package:budget_app/core/feature_flags/models/release_edition.dart';
import 'package:budget_app/core/feature_flags/models/feature_flag.dart';
import 'package:budget_app/core/feature_flags/presentation/bloc/feature_flags_bloc.dart';
import 'package:budget_app/core/feature_flags/services/feature_gate_service_impl.dart';

class MockStorage extends Mock implements Storage {}

void main() {
  late Storage storage;

  setUp(() {
    storage = MockStorage();
    when(() => storage.write(any(), any())).thenAnswer((_) async {});
    HydratedBloc.storage = storage;
  });

  group('FeatureGateServiceImpl tests', () {
    test('evaluates flags and editions correctly', () {
      final bloc = FeatureFlagsBloc(initialDefaultEdition: ReleaseEdition.business);
      final service = FeatureGateServiceImpl(bloc);

      expect(service.effectiveEdition, ReleaseEdition.business);
      expect(service.isEditionActive(ReleaseEdition.business), isTrue);
      expect(service.isEditionActive(ReleaseEdition.personal), isFalse);

      expect(service.isFeatureEnabled(FeatureFlag.invoicingPayables), isTrue);
      expect(service.isFeatureEnabled(FeatureFlag.personalBudgets), isFalse);
    });
  });
}
