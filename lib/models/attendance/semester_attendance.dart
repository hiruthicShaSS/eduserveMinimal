// 🌎 Project imports:
import 'package:eduserveMinimal/models/attendance/attendance.dart';

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
