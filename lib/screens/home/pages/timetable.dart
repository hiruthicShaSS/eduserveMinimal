// 🐦 Flutter imports:
import 'package:eduserveMinimal/global/exceptions.dart';
import 'package:flutter/material.dart';

// 🌎 Project imports:
import 'package:eduserveMinimal/service/timetable.dart';
import 'package:lottie/lottie.dart';

class TimeTable extends StatefulWidget {
  @override
  State<TimeTable> createState() => _TimeTableState();
}

class _TimeTableState extends State<TimeTable> {
  final List days = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: RotatedBox(
          quarterTurns: 1,
          child: FutureBuilder(
            future: getTimetable(),
            builder: (context, AsyncSnapshot<Map?> snapshot) {
              if (snapshot.hasError) {
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
                days.addAll(snapshot.data!.keys.toList());

                if (days.contains("__error__"))
                  return Center(
                    child: Container(
                      child: Text(snapshot.data!["__error__"].toString()),
                    ),
                  );

                List dataCell = [];
                snapshot.data!.forEach((key, value) {
                  List<DataCell> temp = [];
                  value.forEach((element) {
                    temp.add(
                      DataCell(
                        Container(
                          width: MediaQuery.of(context).size.width / 3,
                          child: Text(
                            (element.trim() == "") ? "YEET" : element,
                            style: TextStyle(fontSize: 17),
                          ),
                        ),
                      ),
                    );
                  });
                  temp.insert(
                    0,
                    DataCell(
                      Text(
                        key,
                        style: TextStyle(fontSize: 10),
                      ),
                    ),
                  );
                  dataCell.add(temp);
                });

                return buildTimeTable(context, dataCell);
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

  SafeArea buildTimeTable(BuildContext context, List dataCell) {
    String? currentDay;
    switch (DateTime.now().weekday) {
      case 1:
        currentDay = "MON";
        break;
      case 2:
        currentDay = "TUE";
        break;
      case 3:
        currentDay = "WED";
        break;
      case 4:
        currentDay = "THU";
        break;
      case 5:
        currentDay = "FRI";
        break;
    }

    return SafeArea(
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          Container(
            margin: EdgeInsets.only(top: 2, left: 5, right: 5),
            child: SingleChildScrollView(
              child: DataTable(
                dataRowHeight: MediaQuery.of(context).size.height / 5,
                columnSpacing: MediaQuery.of(context).size.width / 30,
                headingRowColor: MaterialStateProperty.all(Colors.white70),
                dividerThickness: 2,
                columns: List.generate(
                    12,
                    (index) => DataColumn(
                        label: (index == 0)
                            ? Text("Day/Hour",
                                style: TextStyle(
                                    fontSize: 12, color: Colors.black))
                            : Text("Hour $index",
                                style: TextStyle(
                                    fontSize: 15, color: Colors.black)))),
                rows: List.generate(
                  days.length,
                  (index) => DataRow(
                    cells: dataCell[index],
                    selected: (currentDay == days[index]) ? true : false,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
