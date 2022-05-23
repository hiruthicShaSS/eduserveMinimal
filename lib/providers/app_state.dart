// 🐦 Flutter imports:
import 'dart:async';

import 'package:eduserveMinimal/models/class_attendance.dart';
import 'package:eduserveMinimal/models/leave.dart';
import 'package:eduserveMinimal/models/user.dart';
import 'package:eduserveMinimal/service/attendance_summary.dart';
import 'package:eduserveMinimal/service/student_info.dart';
import 'package:flutter/cupertino.dart';

// 🌎 Project imports:
import 'package:eduserveMinimal/service/scrap.dart';

class AppState extends ChangeNotifier {
  Scraper scraper = Scraper();
  Map cache = {};

  User? _user;
  Leave leave = Leave();
  SemesterAttendance? semesterAttendance;

  bool checkedForUpdate = false;

  void set setUser(User user) => _user = user;

  Future<User> get user async {
    if (_user != null) {
      return _user!;
    }

    _user = await getStudentInfo();
    return _user!;
  }

  Future<SemesterAttendance> get getAttendance async {
    if (semesterAttendance != null) {
      return semesterAttendance!;
    }

    semesterAttendance = await getAttendanceSummary();

    return semesterAttendance!;
  }

  void refresh() => notifyListeners();
}
