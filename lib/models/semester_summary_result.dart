class SemesterSummaryResult {
  String monthAndYear;
  int arrears;
  double sgpa;
  double cgpa;

  SemesterSummaryResult({
    required this.monthAndYear,
    required this.arrears,
    required this.sgpa,
    required this.cgpa,
  });

  @override
  String toString() {
    return 'SemesterSummaryResult(monthAndYear: $monthAndYear, arrears: $arrears, sgpa: $sgpa, cgpa: $cgpa)';
  }
}
