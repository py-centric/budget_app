enum ReleaseEdition {
  personal('Personal Edition', 'Tailored for personal budgeting and wealth management'),
  business('Business Edition', 'Designed for invoicing, payables, and business accounting'),
  combined('Combined Edition', 'Full suite with all personal and business features enabled');

  final String label;
  final String description;

  const ReleaseEdition(this.label, this.description);

  static ReleaseEdition fromString(String? value) {
    switch (value?.toLowerCase()) {
      case 'personal':
        return ReleaseEdition.personal;
      case 'business':
        return ReleaseEdition.business;
      case 'combined':
      default:
        return ReleaseEdition.combined;
    }
  }
}
