// 📦 Package imports:
import 'package:awesome_notifications/awesome_notifications.dart';

const String kNoInternetText =
    "There was a problem connecting to the internet!";
const String kPrefs_key_timeTableLastUpdate = "timetable_data_last_update";
const String kPrefs_key_userLastUpdate = "user_data_last_update";
const String kPrefs_BackgroundServiceInterval = "backgroundServiceInterval";
const String kStorage_key_timetableData = "timetable_data";
const String kStorage_key_userData = "user_data";
const String kStorage_key_lastAttendancePercent = "last_attendance_percent";

const String kTimeTableNotificationChannelKey = "timetable";
const String kTimeTableNotificationGroupKey = "timetable-group";
const String kAbsentNotificationChannelKey = "absent";
const String kAttendanceNotificationChannelKey = "attendance";
const String kAttendanceNotificationGroupKey = "attendance-group";

const String kAttachRegisterNumberToCrashLogs =
    "attachRegisterNumberToCrashLogs";
const String kAttachKmailToCrashLogs = "attachKmailToCrashLogs";
const String kAttachNameToCrashLogs = "attachNameToCrashLogs";

const int kAbsentNotificationId = 1;
const int kTimeTableNotificationId = 0;

List<NotificationChannel> notificationChannels = [
  NotificationChannel(
    channelKey: kTimeTableNotificationChannelKey,
    groupKey: kTimeTableNotificationGroupKey,
    criticalAlerts: true,
    enableLights: true,
    defaultPrivacy: NotificationPrivacy.Public,
    channelName: "Upcoming Class Alert",
    channelDescription: "Alert for upcoming classes",
    importance: NotificationImportance.High,
  ),
  NotificationChannel(
    channelKey: kAbsentNotificationChannelKey,
    criticalAlerts: true,
    enableLights: true,
    defaultPrivacy: NotificationPrivacy.Public,
    channelName: "Absent Hours Alert",
    channelDescription: "Alert for classes you've missed",
    importance: NotificationImportance.High,
  ),
  NotificationChannel(
    channelKey: kAttendanceNotificationChannelKey,
    criticalAlerts: true,
    enableLights: true,
    defaultPrivacy: NotificationPrivacy.Public,
    channelName: "Attendance drop alert",
    channelDescription:
        "Alerts regarding the drop in class and attendance percentage",
    importance: NotificationImportance.High,
  ),
];
