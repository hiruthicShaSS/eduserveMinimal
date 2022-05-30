import 'package:awesome_notifications/awesome_notifications.dart';

String timeTableNotificationChannelKey = "timetable";
String timeTableNotificationGroupKey = "timetable-group";

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
];
