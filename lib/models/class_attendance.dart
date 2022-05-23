class SemesterAttendance {
  List<Attendance> attendance;
  double totalHours;
  double presentHours;
  double actual;
  double odCorrected;
  double mlCorrected;
  double leaveHours;
  double absentHours;

  SemesterAttendance({
    required this.attendance,
    required this.totalHours,
    required this.presentHours,
    required this.actual,
    required this.odCorrected,
    required this.mlCorrected,
    required this.leaveHours,
    required this.absentHours,
  });
}

class Attendance {
  DateTime date;
  bool assemblyAttended;
  bool hour0;
  bool hour1;
  bool hour2;
  bool hour3;
  bool hour4;
  bool hour5;
  bool hour6;
  bool hour7;
  bool hour8;
  bool hour9;
  bool hour10;
  bool hour11;
  AttendanceSummary attendanceSummary;

  Attendance({
    required this.date,
    required this.assemblyAttended,
    required this.hour0,
    required this.hour1,
    required this.hour2,
    required this.hour3,
    required this.hour4,
    required this.hour5,
    required this.hour6,
    required this.hour7,
    required this.hour8,
    required this.hour9,
    required this.hour10,
    required this.hour11,
    required this.attendanceSummary,
  });

  @override
  String toString() {
    return 'Attendance(date: $date, assemblyAttended: $assemblyAttended, hour0: $hour0, hour1: $hour1, hour2: $hour2, hour3: $hour3, hour4: $hour4, hour5: $hour5, hour6: $hour6, hour7: $hour7, hour8: $hour8, hour9: $hour9, hour10: $hour10, hour11: $hour11)';
  }
}

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