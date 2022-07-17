// 🐦 Flutter imports:
import 'package:eduserveMinimal/global/constants.dart';
import 'package:eduserveMinimal/global/service/notifications.dart';
import 'package:eduserveMinimal/models/user.dart';
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<Map<String, double>?> checkForAttendanceChange(
    {showNotification = false}) async {
  FlutterSecureStorage storage = FlutterSecureStorage();
  SharedPreferences prefs = await SharedPreferences.getInstance();
  prefs.reload();

  String? lastAttendanceString =
      await storage.read(key: storage_key_lastAttendancePercent);
  String? currentAttendanceString =
      await storage.read(key: storage_key_userData);

  if (lastAttendanceString != null) {
    Map<String, double> lastAttendance =
        Map<String, double>.from(jsonDecode(lastAttendanceString));

    if (currentAttendanceString != null) {
      String? userString = await storage.read(key: storage_key_userData);

      if (userString != null) {
        User user = User.fromJson(userString);

        String notification = "";

        if (user.attendance < lastAttendance["att"]!) {
          if (notification.isNotEmpty) notification += "<br />";

          notification +=
              "Your class attendance has been dropped by  ${user.attendance - lastAttendance["att"]!} %";
        }
        if (user.assemblyAttendance < lastAttendance["asm"]!) {
          if (notification.isNotEmpty) notification += "<br />";

          notification +=
              "Your assembly attendance has been dropped by ${user.assemblyAttendance - lastAttendance["asm"]!} %";
        }

        if (notification.isNotEmpty) {
          if (showNotification) {
            if (prefs.getBool("showAttendanceDropNotification") ?? false) {
              createAttendanceNotification(notification);
            }
          }
        }
      }
    }

    return lastAttendance;
  }

  return null;
}
