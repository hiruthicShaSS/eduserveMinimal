import 'dart:convert';
import 'dart:developer';

import 'package:eduserveMinimal/models/attendance/semester_attendance.dart';
import 'package:eduserveMinimal/models/fees.dart';
import 'package:eduserveMinimal/models/hallticket/hallticket.dart';
import 'package:eduserveMinimal/models/leave/leave.dart';
import 'package:eduserveMinimal/models/timetable_entry.dart';
import 'package:eduserveMinimal/models/user.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CacheController {
  User? _user;
  SemesterAttendance? _semesterAttendance;
  Fees? _fees;
  List<TimeTableEntry>? _timeTable;
  Leave? _leave;
  HallTicket? _hallTicket;

  static final CacheController _cacheController = CacheController._internal();
  factory CacheController() {
    return _cacheController;
  }

  CacheController._internal();

  void set setUser(User user) => _user = user;
  void set setSemesterAttendance(SemesterAttendance semesterAttendance) =>
      _semesterAttendance = semesterAttendance;
  void set setFees(Fees fees) => _fees = fees;
  void set setTimetable(List<TimeTableEntry> timeTable) =>
      _timeTable = timeTable;
  void set setLeave(Leave leave) => _leave = leave;
  void set setHallTicket(HallTicket hallTicket) => _hallTicket = hallTicket;

  void tim() {
    print(_timeTable);
  }

  User? get user => _user;
  SemesterAttendance? get semesterAttendance => _semesterAttendance;
  Fees? get fees => _fees;
  List<TimeTableEntry>? get timeTable => _timeTable;
  Leave? get leave => _leave;
  HallTicket? get hallTicket => _hallTicket;

  void saveTimetableInStorage() async {
    if (_timeTable == null) {
      log("❌ Timetbale is not yet cached, unable to save!!!");

      return;
    }

    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final FlutterSecureStorage storage = FlutterSecureStorage();

    await storage.write(key: "timetable", value: jsonEncode(_timeTable));
    await prefs.setString("timetable_last_update", DateTime.now().toString());
  }

  Future<List<TimeTableEntry>?> getTimetableFromStorage() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final FlutterSecureStorage storage = FlutterSecureStorage();

    DateTime today = DateTime.now();
    int lastUpdate = 100;

    if (prefs.containsKey("timetable_last_update")) {
      lastUpdate = today
          .difference(DateTime.parse(prefs.getString("timetable_last_update")!))
          .inDays;
    }

    if (await storage.containsKey(key: "timetable") && lastUpdate < 90) {
      String? timetableString = await storage.read(key: "timetable");

      if (timetableString != null) {
        List timetableList = jsonDecode(timetableString);
        timetableList = timetableList.map((e) => jsonDecode(e)).toList();

        List<TimeTableEntry> timetable =
            timetableList.map((e) => TimeTableEntry.fromMap(e)).toList();

        if (timetable.isNotEmpty) return timetable;
      }
    }

    return null;
  }

  void clear() {
    _fees = null;
    _hallTicket = null;
    _leave = null;
    _semesterAttendance = null;
    _timeTable = null;
    _user = null;
  }
}
