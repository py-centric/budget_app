import 'package:flutter_test/flutter_test.dart';
import 'package:budget_app/core/feature_flags/models/release_edition.dart';
import 'package:budget_app/core/feature_flags/models/feature_flag.dart';
import 'package:budget_app/core/feature_flags/config/default_feature_mapping.dart';

void main() {
  group('ReleaseEdition tests', () {
    test('ReleaseEdition.fromString parses values correctly', () {
      expect(ReleaseEdition.fromString('personal'), ReleaseEdition.personal);
      expect(ReleaseEdition.fromString('business'), ReleaseEdition.business);
      expect(ReleaseEdition.fromString('combined'), ReleaseEdition.combined);
      expect(ReleaseEdition.fromString(null), ReleaseEdition.combined);
      expect(ReleaseEdition.fromString('unknown'), ReleaseEdition.combined);
    });

    test('DefaultFeatureMapping resolves personal flags correctly', () {
      final flags = DefaultFeatureMapping.resolveFlags(ReleaseEdition.personal);
      expect(flags[FeatureFlag.personalBudgets], isTrue);
      expect(flags[FeatureFlag.emergencyFund], isTrue);
      expect(flags[FeatureFlag.invoicingPayables], isFalse);
      expect(flags[FeatureFlag.bankReconciliation], isFalse);
      expect(flags[FeatureFlag.multiBankAccounts], isTrue);
    });

    test('DefaultFeatureMapping resolves business flags correctly', () {
      final flags = DefaultFeatureMapping.resolveFlags(ReleaseEdition.business);
      expect(flags[FeatureFlag.personalBudgets], isFalse);
      expect(flags[FeatureFlag.invoicingPayables], isTrue);
      expect(flags[FeatureFlag.bankReconciliation], isTrue);
      expect(flags[FeatureFlag.multiBankAccounts], isTrue);
    });

    test('DefaultFeatureMapping resolves combined flags correctly', () {
      final flags = DefaultFeatureMapping.resolveFlags(ReleaseEdition.combined);
      expect(flags[FeatureFlag.personalBudgets], isTrue);
      expect(flags[FeatureFlag.invoicingPayables], isTrue);
      expect(flags[FeatureFlag.bankReconciliation], isTrue);
      expect(flags[FeatureFlag.multiBankAccounts], isTrue);
    });
  });
}
