import '../models/feature_flag.dart';
import '../models/release_edition.dart';

class DefaultFeatureMapping {
  static const Map<FeatureFlag, Set<ReleaseEdition>> featureEditions = {
    // Personal
    FeatureFlag.personalBudgets: {ReleaseEdition.personal, ReleaseEdition.combined},
    FeatureFlag.emergencyFund: {ReleaseEdition.personal, ReleaseEdition.combined},
    FeatureFlag.debtPayoff: {ReleaseEdition.personal, ReleaseEdition.combined},
    FeatureFlag.personalLoans: {ReleaseEdition.personal, ReleaseEdition.combined},
    FeatureFlag.savingsGoals: {ReleaseEdition.personal, ReleaseEdition.combined},

    // Business
    FeatureFlag.invoicingPayables: {ReleaseEdition.business, ReleaseEdition.combined},
    FeatureFlag.bankReconciliation: {ReleaseEdition.business, ReleaseEdition.combined},
    FeatureFlag.taxEstimation: {ReleaseEdition.business, ReleaseEdition.combined},
    FeatureFlag.billSplitting: {ReleaseEdition.business, ReleaseEdition.combined},

    // Universal
    FeatureFlag.multiBankAccounts: {
      ReleaseEdition.personal,
      ReleaseEdition.business,
      ReleaseEdition.combined,
    },
    FeatureFlag.attachments: {
      ReleaseEdition.personal,
      ReleaseEdition.business,
      ReleaseEdition.combined,
    },
    FeatureFlag.backupRestore: {
      ReleaseEdition.personal,
      ReleaseEdition.business,
      ReleaseEdition.combined,
    },
    FeatureFlag.dataExport: {
      ReleaseEdition.personal,
      ReleaseEdition.business,
      ReleaseEdition.combined,
    },
    FeatureFlag.financialCalculators: {
      ReleaseEdition.personal,
      ReleaseEdition.business,
      ReleaseEdition.combined,
    },
    FeatureFlag.settingsAndTheme: {
      ReleaseEdition.personal,
      ReleaseEdition.business,
      ReleaseEdition.combined,
    },
  };

  static Map<FeatureFlag, bool> resolveFlags(ReleaseEdition edition) {
    final result = <FeatureFlag, bool>{};
    for (final flag in FeatureFlag.values) {
      final allowed = featureEditions[flag] ?? {};
      result[flag] = allowed.contains(edition);
    }
    return result;
  }
}
