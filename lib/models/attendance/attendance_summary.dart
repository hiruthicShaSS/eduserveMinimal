class AttendanceSummary {
  int totalAttended;
  int totalAbsent;
  int totalUnAttended;

  AttendanceSummary({
    required this.totalAttended,
    required this.totalAbsent,
    required this.totalUnAttended,
  });

  @override
  String toString() {
    return 'totalAttended: $totalAttended, totalAbsent: $totalAbsent, totalUnAttended: $totalUnAttended)';
  }
}
