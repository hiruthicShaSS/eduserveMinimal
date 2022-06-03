import 'package:eduserveMinimal/global/exceptions.dart';
import 'package:eduserveMinimal/global/service/notifications.dart';
import 'package:eduserveMinimal/global/utilities/notification.dart';
import 'package:eduserveMinimal/models/timetable.dart';
import 'package:eduserveMinimal/providers/app_state.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NotificationsView extends StatefulWidget {
  const NotificationsView({Key? key}) : super(key: key);

  @override
  State<NotificationsView> createState() => _NotificationsViewState();
}

class _NotificationsViewState extends State<NotificationsView> {
  bool _timetableDownloading = false;

  bool _notifyUpcomingClass = false;
  int _alertBefore = 15;

  @override
  void didChangeDependencies() {
    SharedPreferences.getInstance().then((prefs) {
      setState(() {
        _notifyUpcomingClass =
            prefs.getBool("upcomingClassesScheduled") ?? false;
        _alertBefore = prefs.getInt("alertBefore") ?? 15;
      });
    });
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Column(
              children: [
                ExpansionTile(
                  title: Text("Upcoming Class"),
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text("Enabled"),
                          _timetableDownloading
                              ? SizedBox(
                                  width: 40, child: LinearProgressIndicator())
                              : Switch(
                                  value: _notifyUpcomingClass,
                                  onChanged: (value) async {
                                    if (value) {
                                      await setupSchedule(context);
                                    } else {
                                      await cancelAllUpcomingClassNotification();

                                      SharedPreferences.getInstance()
                                          .then((prefs) async {
                                        await prefs.setBool(
                                            "upcomingClassesScheduled",
                                            _notifyUpcomingClass);
                                      });
                                    }

                                    SharedPreferences.getInstance().then(
                                        (prefs) => prefs.setBool(
                                            "upcomingClassesScheduled",
                                            _notifyUpcomingClass));

                                    if (mounted) {
                                      setState(
                                          () => _notifyUpcomingClass = value);
                                    }
                                  }),
                        ],
                      ),
                    ),
                    if (_notifyUpcomingClass)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Row(
                          children: [
                            Text("Alert before:"),
                            Expanded(
                              child: Wrap(
                                children: List.generate(
                                  4,
                                  (index) => TextButton(
                                    onPressed: () => setupSchedule(context,
                                        alertBefore: (index + 1) * 5),
                                    child: Text(((index + 1) * 5).toString()),
                                    style: ButtonStyle(
                                      backgroundColor:
                                          _alertBefore == (index + 1) * 5
                                              ? MaterialStateProperty.all(
                                                  Colors.greenAccent
                                                      .withOpacity(0.3),
                                                )
                                              : null,
                                      shape: MaterialStateProperty.all(
                                        CircleBorder(),
                                      ),
                                    ),
                                  ),
                                ).toList(),
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> setupSchedule(BuildContext context,
      {int alertBefore = 15}) async {
    if (!Provider.of<AppState>(context, listen: false).isTimetableCached) {
      setState(() => _timetableDownloading = true);

      Fluttertoast.showToast(
        msg:
            "Downloading timetable... May take a while. We'll continue scheduling once the timetable is downloaded!",
        toastLength: Toast.LENGTH_LONG,
        timeInSecForIosWeb: 5,
      );
    }

    int scheduleCount = 0;
    try {
      List<TimeTableEntry> timeTable =
          await Provider.of<AppState>(context, listen: false).timetable;

      List<String> weekdays = [
        'mon',
        'tue',
        'wed',
        'thu',
        'fri',
      ];

      List<TimeOfDay> classTiming = [
        TimeOfDay(hour: 7, minute: 60 - alertBefore),
        TimeOfDay(hour: 8, minute: 60 - alertBefore),
        TimeOfDay(hour: 9, minute: 60 - alertBefore),
        TimeOfDay(hour: 10, minute: 60 - alertBefore),
        TimeOfDay(hour: 11, minute: 60 - alertBefore),
        TimeOfDay(hour: 1, minute: 60 - alertBefore),
        TimeOfDay(hour: 2, minute: 60 - alertBefore),
        TimeOfDay(hour: 3, minute: 60 - alertBefore),
        TimeOfDay(hour: 4, minute: 60 - alertBefore),
        TimeOfDay(hour: 5, minute: 60 - alertBefore),
        TimeOfDay(hour: 6, minute: 60 - alertBefore),
      ];

      await cancelAllUpcomingClassNotification();

      for (var timeTableEntry in timeTable) {
        List<List<String>> classes =
            timeTableEntry.toList().map((e) => [e.name, e.venue]).toList();

        for (var i = 0; i < classes.length; i++) {
          if (classes[i].first.isEmpty) continue;

          NotificationWeekAndTime notificationWeekAndTime =
              NotificationWeekAndTime(
            dayOfTheWeek:
                weekdays.indexOf(timeTableEntry.day.toLowerCase()) + 1,
            timeOfDay: classTiming[i - 1],
          );

          print(
              "${weekdays[weekdays.indexOf(timeTableEntry.day.toLowerCase())]} ${notificationWeekAndTime.timeOfDay.hour} : ${notificationWeekAndTime.timeOfDay.minute} => ${classes[i]}");

          createUpcomingClassNotification(
            classes[i].first,
            classes[i].last,
            notificationWeekAndTime,
          );

          scheduleCount++;
        }
      }
    } on NoRecordsException catch (e) {
      setState(() => _timetableDownloading = false);
      Fluttertoast.showToast(msg: e.message!);

      return;
    }

    setState(() {
      _timetableDownloading = false;
      _alertBefore = alertBefore;
    });

    Fluttertoast.showToast(msg: "$scheduleCount schedules created!");
    SharedPreferences.getInstance().then((prefs) async {
      await prefs.setBool("upcomingClassesScheduled", _notifyUpcomingClass);
      await prefs.setInt("alertBefore", alertBefore);
    });
  }
}
