import 'dart:developer';

import 'package:eduserveMinimal/controller/cache.dart';
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
import 'package:shared_preferences/shared_preferences.dart';

SemesterAttendance? _semesterAttendance;
CacheController _cacheController = CacheController();

Future<bool> checkForAbsent({
  SemesterAttendance? semesterAttendance,
  BuildContext? context,
  bool showNotification = true,
}) async {
  SharedPreferences _prefs = await SharedPreferences.getInstance();

  if (_prefs.containsKey("absentClassShownAt")) {
    String lastAbsentDateString = _prefs.getString("absentClassShownAt")!;

    DateTime lastAbsentDate = DateTime.parse(lastAbsentDateString);

    if (DateTime.now().difference(lastAbsentDate).inHours < 23) return false;
  }

  try {
    _semesterAttendance = semesterAttendance ?? await getAttendanceSummary();

    if (context != null) {
      _cacheController.setTimetable =
          await Provider.of<AppState>(context, listen: false).timetable;
    } else {
      if (_cacheController.timeTable == null) {
        List<TimeTableEntry>? timetable =
            await _cacheController.getTimetableFromStorage();

        if (timetable == null) {
          _cacheController.setTimetable = await getTimetable();
        } else {
          _cacheController.setTimetable = timetable;
        }
      }
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

        TimeTableSubject subject = getHourDataByHour(
            _cacheController.timeTable![yesterday.weekday], i);

        if (subject.name.isEmpty) continue;

        absentClasses.add(subject);
      }

      if (absentClasses.isNotEmpty) {
        String data = "";

        for (var absentClass in absentClasses) {
          data +=
              "👉&nbsp; ${absentClass.name} (${absentClass.code}) @ ${absentClass.venue} <br />";
        }

        if (data.length >= 300) {
          data = data.substring(0, 300) + " ...";
          data += "<br /><br /><b>Tap for more info...<b>";
        }

        if (showNotification) {
          createAbsentNotification(
            "You have missed ${absentClasses.length} class${absentClasses.length > 1 ? "es" : ""}",
            data,
            {"date": yesterday.millisecondsSinceEpoch.toString()},
          );

          await _prefs.setString(
              "absentClassShownAt", DateTime.now().toString());
        }

        return true;
      }
    }
  }

  return false;
}
