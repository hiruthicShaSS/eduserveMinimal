// 🐦 Flutter imports:
import 'dart:async';

import 'package:eduserveMinimal/models/class_attendance.dart';
import 'package:eduserveMinimal/models/fees.dart';
import 'package:eduserveMinimal/models/hallticket/hallticket.dart';
import 'package:eduserveMinimal/models/leave.dart';
import 'package:eduserveMinimal/models/user.dart';
import 'package:eduserveMinimal/service/attendance_summary.dart';
import 'package:eduserveMinimal/service/fees_details.dart';
import 'package:eduserveMinimal/service/get_hallticket.dart';
import 'package:eduserveMinimal/service/leave_info.dart';
import 'package:eduserveMinimal/service/student_info.dart';
import 'package:flutter/cupertino.dart';

// 🌎 Project imports:
import 'package:eduserveMinimal/service/scrap.dart';

class AppState extends ChangeNotifier {
  Scraper scraper = Scraper();
  Map cache = {};

  User? _user;
  Leave? _leave;
  SemesterAttendance? semesterAttendance;
  Fees? _fees;
  HallTicket? _hallTicket;

  bool checkedForUpdate = false;

  void set setUser(User user) => _user = user;
  void set setLeave(Leave leave) => _leave = leave;
  void set setFees(Fees fees) => _fees = fees;
  void set setHallTicket(HallTicket hallTicket) => _hallTicket = hallTicket;

  Future<User> get user async {
    if (_user != null) {
      return _user!;
    }

    _user = await getStudentInfo();
    return _user!;
  }

  Future<SemesterAttendance> get attendance async {
    if (semesterAttendance != null) {
      return semesterAttendance!;
    }

    semesterAttendance = await getAttendanceSummary();
    return semesterAttendance!;
  }

  Future<Leave> get leaveInfo async {
    if (_leave != null) {
      return _leave!;
    }

    _leave = await getLeaveInfo();
    return _leave!;
  }

  Future<Fees> get fees async {
    if (_fees != null) {
      return _fees!;
    }

    _fees = await getFeesDetails();
    return _fees!;
  }

  Future<HallTicket> get hallTicket async {
    if (_hallTicket != null) {
      return _hallTicket!;
    }

    _hallTicket = await getHallTicket();
    return _hallTicket!;
  }

  void refresh() {
    _user = null;
    _leave = null;
    semesterAttendance = null;

    notifyListeners();
  }
}
