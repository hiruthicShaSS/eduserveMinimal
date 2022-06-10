import 'package:awesome_notifications/awesome_notifications.dart';

String noInternetText = "There was a problem connecting to the internet!";
String timeTableNotificationChannelKey = "timetable";
String timeTableNotificationGroupKey = "timetable-group";
String absentNMotificationChannelKey = "absent";
int absentNMotificationId = 1;

int timeTableNotificationId = 0;

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
    channelKey: absentNMotificationChannelKey,
    criticalAlerts: true,
    enableLights: true,
    defaultPrivacy: NotificationPrivacy.Public,
    channelName: "Absent Hours Alert",
    channelDescription: "Alert for classes you've missed",
    importance: NotificationImportance.High,
  ),
];
