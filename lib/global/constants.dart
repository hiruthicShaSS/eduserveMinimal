// 📦 Package imports:
import 'package:awesome_notifications/awesome_notifications.dart';

const String noInternetText = "There was a problem connecting to the internet!";
const String prefs_key_timeTableLastUpdate = "timetable_data_last_update";
const String prefs_key_userLastUpdate = "user_data_last_update";
const String storage_key_timetableData = "timetable_data";
const String storage_key_userData = "user_data";
const String storage_key_lastAttendancePercent = "last_attendance_percent";

const String timeTableNotificationChannelKey = "timetable";
const String timeTableNotificationGroupKey = "timetable-group";
const String absentNotificationChannelKey = "absent";
const String attendanceNotificationChannelKey = "attendance";
const String attendanceNotificationGroupKey = "attendance-group";

const String attachRegisterNumberToCrashLogs =
    "attachRegisterNumberToCrashLogs";
const String attachKmailToCrashLogs = "attachKmailToCrashLogs";
const String attachNameToCrashLogs = "attachNameToCrashLogs";

const int absentNotificationId = 1;
const int timeTableNotificationId = 0;

List<NotificationChannel> notificationChannels = [
  NotificationChannel(
    channelKey: timeTableNotificationChannelKey,
    groupKey: timeTableNotificationGroupKey,
    criticalAlerts: true,
    enableLights: true,
    defaultPrivacy: NotificationPrivacy.Public,
    channelName: "Upcoming Class Alert",
    channelDescription: "Alert for upcoming classes",
    importance: NotificationImportance.High,
  ),
  NotificationChannel(
    channelKey: absentNotificationChannelKey,
    criticalAlerts: true,
    enableLights: true,
    defaultPrivacy: NotificationPrivacy.Public,
    channelName: "Absent Hours Alert",
    channelDescription: "Alert for classes you've missed",
    importance: NotificationImportance.High,
  ),
  NotificationChannel(
    channelKey: attendanceNotificationChannelKey,
    criticalAlerts: true,
    enableLights: true,
    defaultPrivacy: NotificationPrivacy.Public,
    channelName: "Attendance drop alert",
    channelDescription:
        "Alerts regarding the drop in class and attendance percentage",
    importance: NotificationImportance.High,
  ),
];
