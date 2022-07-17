// 🎯 Dart imports:
import 'dart:async';

// 🐦 Flutter imports:
import 'package:flutter/cupertino.dart';

// 🌎 Project imports:
import 'package:eduserveMinimal/controller/cache_controller.dart';
import 'package:eduserveMinimal/models/attendance/semester_attendance.dart';
import 'package:eduserveMinimal/models/fees.dart';
import 'package:eduserveMinimal/models/hallticket/hallticket.dart';
import 'package:eduserveMinimal/models/leave/leave.dart';
import 'package:eduserveMinimal/models/timetable_entry.dart';
import 'package:eduserveMinimal/models/user.dart';
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

  Future<User> getUser() async {
    if (_cacheController.user != null) return _cacheController.user!;

    User? user = await _cacheController.getUserFromStorage();
    if (user != null) return user;

    _cacheController.setUser = await getStudentInfo();
    _cacheController.saveUserInStorage();

    return _cacheController.user!;
  }

  Future<SemesterAttendance> getAttendance() async {
    if (_cacheController.semesterAttendance != null) {
      return _cacheController.semesterAttendance!;
    }

    _cacheController.setSemesterAttendance = await getAttendanceSummary();
    return _cacheController.semesterAttendance!;
  }

  Future<Fees> getFees() async {
    if (_cacheController.fees != null) return _cacheController.fees!;

    _cacheController.setFees = await getFeesDetails();
    return _cacheController.fees!;
  }

  Future<Leave> getLeaveInformation() async {
    if (_cacheController.leave != null) return _cacheController.leave!;

    _cacheController.setLeave = await getLeaveInfo();
    return _cacheController.leave!;
  }

  Future<List<TimeTableEntry>> getTimetableData() async {
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

  Future<HallTicket> getHallTicketData() async {
    if (_cacheController.hallTicket != null) {
      return _cacheController.hallTicket!;
    }

    _cacheController.setHallTicket = await getHallTicket();
    return _cacheController.hallTicket!;
  }

  void rebuildDecendants() => notifyListeners();

  Future<void> refresh({bool shouldNotifyListeners = true}) async {
    await _cacheController.flush();

    if (shouldNotifyListeners) notifyListeners();
  }

  Future<void> resetTimeTable() async =>
      await _cacheController.resetTimeTable();

  Future<void> resetUser() async => await _cacheController.resetUser();
}
