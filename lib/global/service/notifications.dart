import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:eduserveMinimal/global/constants.dart';
import 'package:eduserveMinimal/global/utilities/notification.dart';
import 'package:flutter/material.dart';

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

Future<void> cancelAllUpcomingClassNotification() async {
  await AwesomeNotifications()
      .cancelSchedulesByChannelKey(timeTableNotificationChannelKey);
}
