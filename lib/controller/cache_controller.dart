// 🎯 Dart imports:
import 'dart:convert';
import 'dart:developer';

// 📦 Package imports:
import 'package:eduserveMinimal/global/constants.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

// 🌎 Project imports:
import 'package:eduserveMinimal/models/attendance/semester_attendance.dart';
import 'package:eduserveMinimal/models/fees.dart';
import 'package:eduserveMinimal/models/hallticket/hallticket.dart';
import 'package:eduserveMinimal/models/leave/leave.dart';
import 'package:eduserveMinimal/models/timetable_entry.dart';
import 'package:eduserveMinimal/models/user.dart';

class CacheController {
  User? _user;
  SemesterAttendance? _semesterAttendance;
  Fees? _fees;
  List<TimeTableEntry>? _timeTable;
  Leave? _leave;
  HallTicket? _hallTicket;

  static late final SharedPreferences _prefs;
  final FlutterSecureStorage _storage = FlutterSecureStorage();

  static final CacheController _cacheController = CacheController._();

  factory CacheController() => _cacheController;

  CacheController._() {
    init();
  }

  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

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

    await storage.write(
        key: kStorage_key_timetableData, value: jsonEncode(_timeTable));
    await prefs.setString(
        kPrefs_key_timeTableLastUpdate, DateTime.now().toString());

    log("✅ Timetable cached to local storage.");
  }

  Future<List<TimeTableEntry>?> getTimetableFromStorage() async {
    DateTime today = DateTime.now();
    int lastUpdate = 100;

    if (_prefs.containsKey(kPrefs_key_timeTableLastUpdate)) {
      lastUpdate = today
          .difference(
              DateTime.parse(_prefs.getString(kPrefs_key_timeTableLastUpdate)!))
          .inDays;
    }

    if (await _storage.containsKey(key: kStorage_key_timetableData) &&
        lastUpdate < 90) {
      String? timetableString =
          await _storage.read(key: kStorage_key_timetableData);

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

  void saveUserInStorage() async {
    if (_user == null) {
      log("❌ User data is not yet cached, unable to save!!!");

      return;
    }

    User? oldUserData = await getUserFromStorage();
    await _storage.write(
      key: kStorage_key_lastAttendancePercent,
      value: jsonEncode(
        {
          "att": oldUserData?.attendance ?? _user!.attendance,
          "asm": oldUserData?.assemblyAttendance ?? _user!.assemblyAttendance
        },
      ),
    );

    await _storage.write(key: kStorage_key_userData, value: _user!.toJson());
    await _prefs.setString(
        kPrefs_key_userLastUpdate, DateTime.now().toString());

    log("✅ User data cached to local storage.");
  }

  Future<User?> getUserFromStorage() async {
    DateTime today = DateTime.now();
    int lastUpdate = 24;

    if (_prefs.containsKey(kPrefs_key_userLastUpdate)) {
      lastUpdate = today
          .difference(
              DateTime.parse(_prefs.getString(kPrefs_key_userLastUpdate)!))
          .inHours;
    }

    if (await _storage.containsKey(key: kStorage_key_userData) &&
        lastUpdate < 23) {
      String? userDataString = await _storage.read(key: kStorage_key_userData);

      if (userDataString != null) {
        return User.fromJson(userDataString);
      }

      return null;
    }

    return null;
  }

  Future<void> resetTimeTable() async {
    _timeTable = null;

    await _prefs.remove(kPrefs_key_timeTableLastUpdate);
    await _storage.delete(key: kStorage_key_timetableData);
  }

  Future<void> resetUser() async {
    _user = null;

    await _prefs.remove(kPrefs_key_userLastUpdate);
    await _storage.delete(key: kStorage_key_userData);
  }

  void clear() {
    _fees = null;
    _hallTicket = null;
    _leave = null;
    _semesterAttendance = null;
    _timeTable = null;
    _user = null;
  }

  Future<void> flush() async {
    clear();

    await _prefs.remove(kPrefs_key_timeTableLastUpdate);
    await _prefs.remove(kPrefs_key_userLastUpdate);
    await _storage.delete(key: kStorage_key_timetableData);
    await _storage.delete(key: kStorage_key_userData);

    log("⚠ Cached data in local storage flushed.");
  }
}
