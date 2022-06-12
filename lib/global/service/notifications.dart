// 🐦 Flutter imports:
import 'package:flutter/material.dart';

// 📦 Package imports:
import 'package:awesome_notifications/awesome_notifications.dart';

// 🌎 Project imports:
import 'package:eduserveMinimal/global/constants.dart';
import 'package:eduserveMinimal/global/utilities/notification.dart';

Future<void> createUpcomingClassNotification(String body, String? venue,
    NotificationWeekAndTime notificationWeekAndTime) async {
  await AwesomeNotifications().createNotification(
    content: NotificationContent(
      id: createUniqueId(),
      channelKey: timeTableNotificationChannelKey,
      groupKey: timeTableNotificationGroupKey,
      title: "Upcoming class @ $venue",
      body: body,
      color: Colors.amberAccent,
      notificationLayout: NotificationLayout.BigText,
      category: NotificationCategory.Reminder,
      wakeUpScreen: true,
    ),
    actionButtons: [
      NotificationActionButton(
        key: "GOT_IT",
        label: "Got It",
        buttonType: ActionButtonType.DisabledAction,
      )
    ],
    schedule: NotificationCalendar(
      repeats: true,
      preciseAlarm: true,
      weekday: notificationWeekAndTime.dayOfTheWeek,
      hour: notificationWeekAndTime.timeOfDay.hour,
      minute: notificationWeekAndTime.timeOfDay.minute,
      second: 0,
      millisecond: 0,
    ),
  );
}

Future<void> createAbsentNotification(
    String title, String body, Map<String, String> payload) async {
  AwesomeNotifications().createNotification(
    content: NotificationContent(
      id: absentNotificationId,
      channelKey: absentNotificationChannelKey,
      title: title,
      body: body,
      color: Colors.red,
      notificationLayout: NotificationLayout.BigText,
      category: NotificationCategory.Reminder,
      fullScreenIntent: true,
      wakeUpScreen: true,
      payload: payload,
    ),
  );
}

Future<void> createAttendanceNotification(String body) async {
  AwesomeNotifications().createNotification(
    content: NotificationContent(
      id: createUniqueId(),
      channelKey: attendanceNotificationChannelKey,
      criticalAlert: true,
      title: "Your attendance percentage has been dropped!",
      body: body,
      color: Colors.amberAccent,
      notificationLayout: NotificationLayout.BigText,
      category: NotificationCategory.Status,
      fullScreenIntent: true,
      wakeUpScreen: true,
    ),
  );
}

Future<void> cancelAllUpcomingClassNotification() async {
  await AwesomeNotifications()
      .cancelSchedulesByChannelKey(timeTableNotificationChannelKey);
}
