// 🎯 Dart imports:
import 'dart:developer';

// 🐦 Flutter imports:
import 'package:flutter/material.dart';

// 📦 Package imports:
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';

// 🌎 Project imports:
import 'package:eduserveMinimal/models/timetable_entry.dart';
import 'package:eduserveMinimal/providers/app_state.dart';

import 'widgets/timetable_widget.dart';

class TimeTableScreen extends StatefulWidget {
  @override
  State<TimeTableScreen> createState() => _TimeTableScreenState();
}

class _TimeTableScreenState extends State<TimeTableScreen> {
  List<String> weekdays = ['mon', 'tue', 'wed', 'thu', 'fri'];
  bool _retry = false;

  GlobalKey _key = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: RotatedBox(
          quarterTurns: 1,
          child: FutureBuilder(
            future: Provider.of<AppState>(context).getTimetableData(),
            builder: (context, AsyncSnapshot<List<TimeTableEntry>> snapshot) {
              if (snapshot.hasError) {
                if (_retry) {
                  WidgetsBinding.instance.addPostFrameCallback(
                      (_) => setState(() => _retry = false));
                }

                log("", error: snapshot.error);

                return Padding(
                  padding: const EdgeInsets.only(top: 20),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(snapshot.error.toString()),
                        TextButton(
                          onPressed: () => setState(() => _retry = true),
                          child: _retry
                              ? CircularProgressIndicator()
                              : const Text("Re try"),
                        ),
                      ],
                    ),
                  ),
                );
              }

              if (snapshot.connectionState == ConnectionState.done) {
                if (_retry) {
                  WidgetsBinding.instance.addPostFrameCallback(
                      (_) => setState(() => _retry = false));
                }

                List<TimeTableEntry> timeTable = snapshot.data!;
                List<List<TimeTableSubject>> data = [];

                for (var day in timeTable) {
                  data.add([
                    day.hour1,
                    day.hour2,
                    day.hour3,
                    day.hour4,
                    day.hour5,
                    day.hour6,
                    day.hour7,
                    day.hour8,
                    day.hour9,
                    day.hour10,
                    day.hour11,
                  ]);
                }

                return TimetableWidget(
                  data: data,
                  timeTable: timeTable,
                  weekdays: weekdays,
                );
              } else {
                return Center(
                    child: Lottie.asset("assets/lottie/timetable.json"));
              }
            },
          ),
        ),
      ),
    );
  }

  String get currentDay {
    switch (DateTime.now().weekday) {
      case 1:
        return "MON";
      case 2:
        return "TUE";
      case 3:
        return "WED";
      case 4:
        return "THU";
      case 5:
        return "FRI";
      default:
        return "";
    }
  }
}
