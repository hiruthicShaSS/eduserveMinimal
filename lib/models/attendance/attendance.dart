import 'package:eduserveMinimal/global/enum.dart';
import 'package:eduserveMinimal/models/attendance/attendance_summary.dart';

class Attendance {
  DateTime date;
  AttendanceType assemblyAttended;
  AttendanceType hour0;
  AttendanceType hour1;
  AttendanceType hour2;
  AttendanceType hour3;
  AttendanceType hour4;
  AttendanceType hour5;
  AttendanceType hour6;
  AttendanceType hour7;
  AttendanceType hour8;
  AttendanceType hour9;
  AttendanceType hour10;
  AttendanceType hour11;
  AttendanceSummary summary;

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
    required this.summary,
  });

  List<AttendanceType> toHourList() => [
        hour0,
        hour1,
        hour2,
        hour3,
        hour4,
        hour5,
        hour6,
        hour7,
        hour8,
        hour9,
        hour10,
        hour11,
      ];

  static AttendanceType getAttendanceTypeFromString(String string) {
    switch (string) {
      case "p":
        return AttendanceType.present;
      case "A":
        return AttendanceType.absent;
      case "O":
        return AttendanceType.od;
      case "M":
        return AttendanceType.mediacal;
      case "-":
        return AttendanceType.none;
      case "U":
        return AttendanceType.unattended;
      default:
        return AttendanceType.present;
    }
  }

  static String getStringFromAttendanceType(AttendanceType attendanceType) {
    switch (attendanceType) {
      case AttendanceType.present:
        return "P";
      case AttendanceType.absent:
        return "A";
      case AttendanceType.mediacal:
        return "ML";
      case AttendanceType.od:
        return "OD";
      case AttendanceType.unattended:
        return "U";
      case AttendanceType.none:
        return "-";
    }
  }

  @override
  String toString() {
    return 'Attendance(date: $date, assemblyAttended: $assemblyAttended, hour0: $hour0, hour1: $hour1, hour2: $hour2, hour3: $hour3, hour4: $hour4, hour5: $hour5, hour6: $hour6, hour7: $hour7, hour8: $hour8, hour9: $hour9, hour10: $hour10, hour11: $hour11)';
  }
}
