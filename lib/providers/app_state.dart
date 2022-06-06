import 'dart:async';

import 'package:eduserveMinimal/controller/cache.dart';
import 'package:eduserveMinimal/models/attendance/semester_attendance.dart';
import 'package:eduserveMinimal/models/fees.dart';
import 'package:eduserveMinimal/models/hallticket/hallticket.dart';
import 'package:eduserveMinimal/models/leave/leave.dart';
import 'package:eduserveMinimal/models/timetable_entry.dart';
import 'package:eduserveMinimal/models/user.dart';
import 'package:flutter/cupertino.dart';

import 'package:eduserveMinimal/service/attendance_summary.dart';
import 'package:eduserveMinimal/service/fees_details.dart';
import 'package:eduserveMinimal/service/get_hallticket.dart';
import 'package:eduserveMinimal/service/leave_info.dart';
import 'package:eduserveMinimal/service/student_info.dart';
import 'package:eduserveMinimal/service/timetable.dart';

class AppState extends ChangeNotifier {
  CacheController _cacheController = CacheController();
  bool checkedForUpdate = false;
  bool _loggedIn = false;

  void set setLoggedIn(bool status) => _loggedIn = status;

  void set setUser(User user) => _cacheController.setUser = user;
  void set setLeave(Leave leave) => _cacheController.setLeave = leave;
  void set setFees(Fees fees) => _cacheController.setFees = fees;
  void set setHallTicket(HallTicket hallTicket) =>
      _cacheController.setHallTicket = hallTicket;

  bool get isTimetableCached => _cacheController.timeTable != null;
  bool get isLoggedIn => _loggedIn;

  Future<User> get user async {
    if (_cacheController.user != null) return _cacheController.user!;

    _cacheController.setUser = await getStudentInfo();
    return _cacheController.user!;
  }

  Future<SemesterAttendance> get attendance async {
    if (_cacheController.semesterAttendance != null) {
      return _cacheController.semesterAttendance!;
    }

    _cacheController.setSemesterAttendance = await getAttendanceSummary();
    return _cacheController.semesterAttendance!;
  }

  Future<Fees> get fees async {
    if (_cacheController.fees != null) return _cacheController.fees!;

    _cacheController.setFees = await getFeesDetails();
    return _cacheController.fees!;
  }

  Future<Leave> get leaveInfo async {
    if (_cacheController.leave != null) return _cacheController.leave!;

    _cacheController.setLeave = await getLeaveInfo();
    return _cacheController.leave!;
  }

  Future<List<TimeTableEntry>> get timetable async {
    if (_cacheController.timeTable != null) return _cacheController.timeTable!;

    List<TimeTableEntry>? timeTableFromStorage =
        await _cacheController.getTimetableFromStorage();

    if (timeTableFromStorage != null) {
      _cacheController.setTimetable = timeTableFromStorage;
      return timeTableFromStorage;
    }

    _cacheController.setTimetable = await getTimetable();
    _cacheController.saveTimetableInStorage();

    return _cacheController.timeTable!;
  }

  Future<HallTicket> get hallTicket async {
    if (_cacheController.hallTicket != null) {
      return _cacheController.hallTicket!;
    }

    _cacheController.setHallTicket = await getHallTicket();
    return _cacheController.hallTicket!;
  }

  void rebuildDecendants() => notifyListeners();

  void refresh() {
    _cacheController.clear();

    notifyListeners();
  }
}
