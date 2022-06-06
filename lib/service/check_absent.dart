import 'package:eduserveMinimal/global/enum.dart';
import 'package:eduserveMinimal/global/service/notifications.dart';
import 'package:eduserveMinimal/global/utilities/getHourDataByHour.dart';
import 'package:eduserveMinimal/models/attendance/attendance.dart';
import 'package:eduserveMinimal/models/attendance/semester_attendance.dart';
import 'package:eduserveMinimal/models/timetable_entry.dart';
import 'package:eduserveMinimal/providers/app_state.dart';
import 'package:eduserveMinimal/service/attendance_summary.dart';
import 'package:eduserveMinimal/service/timetable.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';

SemesterAttendance? _semesterAttendance;

Future<bool> checkForAbsent({
  SemesterAttendance? semesterAttendance,
  BuildContext? context,
  bool showNotification = true,
}) async {
  List<TimeTableEntry>? timetable;

  try {
    _semesterAttendance = semesterAttendance ?? await getAttendanceSummary();

    if (context != null) {
      timetable = await Provider.of<AppState>(context, listen: false).timetable;
    } else {
      timetable = await getTimetable();
    }
  } catch (_) {
    return false;
  }

  List<Attendance> attendance = _semesterAttendance!.attendance;

  DateTime yesterday = DateTime(2022, 4, 19);

  int yesterdayIndex =
      attendance.map((e) => e.date).toList().indexOf(yesterday);
  // bool yesterdayExists = attendance
  //     .contains(DateTime.now().add(const Duration(days: -1)));

  if (yesterdayIndex != -1) {
    bool hasAbsentHours = attendance[yesterdayIndex].summary.totalAbsent > 0;

    if (hasAbsentHours) {
      List<AttendanceType> hours = attendance[yesterdayIndex].toHourList();

      List<TimeTableSubject> absentClasses = [];
      for (int i = 0; i < hours.length; i++) {
        if ([AttendanceType.none, AttendanceType.unattended]
            .contains(hours[i])) {
          continue;
        }

        TimeTableSubject subject =
            getHourDataByHour(timetable[yesterday.weekday], i);

        if (subject.name.isEmpty) continue;

        absentClasses.add(subject);
      }

      if (absentClasses.isNotEmpty) {
        String data = "";

        for (var absentClass in absentClasses) {
          data += absentClass.name +
              "(${absentClass.code})" +
              " @ " +
              absentClass.venue +
              " , ";
        }

        if (showNotification) {
          // Show notifications only if the app is not foreground
          createAbsentNotification(
            "You have missed these class${absentClasses.length > 1 ? "es" : ""}",
            data,
          );
        }

        return true;
      }
    }
  }

  return false;
}
