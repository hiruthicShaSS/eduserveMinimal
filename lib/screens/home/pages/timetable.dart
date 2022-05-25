// 🐦 Flutter imports:
import 'dart:developer';

import 'package:eduserveMinimal/global/exceptions.dart';
import 'package:eduserveMinimal/models/timetable.dart';
import 'package:flutter/material.dart';

// 🌎 Project imports:
import 'package:eduserveMinimal/service/timetable.dart';
import 'package:lottie/lottie.dart';

class TimeTableView extends StatefulWidget {
  @override
  State<TimeTableView> createState() => _TimeTableViewState();
}

class _TimeTableViewState extends State<TimeTableView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: RotatedBox(
          quarterTurns: 1,
          child: FutureBuilder(
            future: getTimetable(),
            builder: (context, AsyncSnapshot<List<TimeTable>> snapshot) {
              if (snapshot.hasError) {
                log("", error: snapshot.error);

                if (snapshot.error.runtimeType == NoRecordsInTimetable) {
                  return Padding(
                    padding: const EdgeInsets.only(top: 20),
                    child: Center(
                      child: Text(
                        snapshot.error.toString(),
                      ),
                    ),
                  );
                }
              }

              if (snapshot.connectionState == ConnectionState.done) {
                List<TimeTable> timeTable = snapshot.data!;

                return SafeArea(
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: [
                      Container(
                        margin: EdgeInsets.only(top: 2, left: 5, right: 5),
                        child: SingleChildScrollView(
                          child: DataTable(
                            dataRowHeight:
                                MediaQuery.of(context).size.height / 5,
                            columnSpacing:
                                MediaQuery.of(context).size.width / 30,
                            headingRowColor:
                                MaterialStateProperty.all(Colors.white70),
                            dividerThickness: 2,
                            columns: List.generate(
                                12,
                                (index) => DataColumn(
                                    label: (index == 0)
                                        ? Text("Day/Hour",
                                            style: TextStyle(
                                                fontSize: 12,
                                                color: Colors.black))
                                        : Text("Hour $index",
                                            style: TextStyle(
                                                fontSize: 15,
                                                color: Colors.black)))),
                            rows: List.generate(
                              timeTable.length,
                              (index) => DataRow(
                                cells: [
                                  _buildDataCell(
                                    timeTable[index].day,
                                    width: 45,
                                  ),
                                  _buildDataCell(timeTable[index].hour1),
                                  _buildDataCell(timeTable[index].hour2),
                                  _buildDataCell(timeTable[index].hour3),
                                  _buildDataCell(timeTable[index].hour4),
                                  _buildDataCell(timeTable[index].hour5),
                                  _buildDataCell(timeTable[index].hour6),
                                  _buildDataCell(timeTable[index].hour7),
                                  _buildDataCell(timeTable[index].hour8),
                                  _buildDataCell(timeTable[index].hour9),
                                  _buildDataCell(timeTable[index].hour10),
                                  _buildDataCell(timeTable[index].hour11),
                                ],
                                selected: (currentDay == timeTable[index].day)
                                    ? true
                                    : false,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
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

  DataCell _buildDataCell(String text, {double? width}) {
    return DataCell(
      Container(
        width: width ?? MediaQuery.of(context).size.width / 3,
        child: text.isEmpty
            ? const Placeholder()
            : Text(text, style: TextStyle(fontSize: 17)),
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
