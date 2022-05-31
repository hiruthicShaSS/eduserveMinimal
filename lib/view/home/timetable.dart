// 🐦 Flutter imports:
import 'dart:developer';

import 'package:eduserveMinimal/models/timetable.dart';
import 'package:eduserveMinimal/providers/app_state.dart';
import 'package:flutter/material.dart';

// 🌎 Project imports:
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'package:table_sticky_headers/table_sticky_headers.dart';
import 'package:eduserveMinimal/view/misc/widgets/table_cell.dart' as tableCell;

class TimeTableScreen extends StatefulWidget {
  @override
  State<TimeTableScreen> createState() => _TimeTableScreenState();
}

class _TimeTableScreenState extends State<TimeTableScreen> {
  List<String> weekdays = ['mon', 'tue', 'wed', 'thu', 'fri'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: RotatedBox(
          quarterTurns: 1,
          child: FutureBuilder(
            future: Provider.of<AppState>(context).timetable,
            builder: (context, AsyncSnapshot<List<TimeTableEntry>> snapshot) {
              if (snapshot.hasError) {
                log("", error: snapshot.error);

                return Padding(
                  padding: const EdgeInsets.only(top: 20),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(snapshot.error.toString()),
                        TextButton(
                          onPressed: () => setState(() {}),
                          child: Text("Re try"),
                        ),
                      ],
                    ),
                  ),
                );
              }

              if (snapshot.connectionState == ConnectionState.done) {
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

                return StickyHeadersTable(
                  columnsLength: data.first.length,
                  rowsLength: data.length,
                  columnsTitleBuilder: (i) =>
                      tableCell.TableCell.stickyRow("Hour ${i + 1}"),
                  rowsTitleBuilder: (i) => tableCell.TableCell.stickyColumn(
                    timeTable[i].day,
                    colorBg: weekdays.indexOf(timeTable[i].day.toLowerCase()) +
                                1 ==
                            DateTime.now().weekday
                        ? Theme.of(context).colorScheme.primary.withOpacity(0.3)
                        : Colors.transparent,
                  ),
                  contentCellBuilder: (i, j) => data[j][i].name.isEmpty
                      ? const Placeholder()
                      : tableCell.TableCell.content(
                          colorBg:
                              weekdays.indexOf(timeTable[j].day.toLowerCase()) +
                                          1 ==
                                      DateTime.now().weekday
                                  ? Theme.of(context)
                                      .colorScheme
                                      .primary
                                      .withOpacity(0.3)
                                  : Colors.transparent,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 10),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  data[j][i].name,
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  data[j][i].code,
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.white.withOpacity(0.5),
                                  ),
                                ),
                                const Spacer(),
                                Wrap(
                                  alignment: WrapAlignment.spaceBetween,
                                  spacing: 30,
                                  children: [
                                    Text(
                                      "Batch: ${data[j][i].batch}",
                                      style: TextStyle(fontSize: 16),
                                    ),
                                    Text(
                                      data[j][i].venue,
                                      style: TextStyle(
                                          fontSize: 16, color: Colors.green),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                  cellDimensions: CellDimensions.fixed(
                    stickyLegendWidth: 80,
                    stickyLegendHeight: 80,
                    contentCellWidth: 200,
                    contentCellHeight: 170,
                  ),
                  legendCell: tableCell.TableCell.legend("Day / Hour"),
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
