// 🐦 Flutter imports:
import 'package:eduserveMinimal/app_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

// 🌎 Project imports:
import 'package:provider/provider.dart';

class TimeTable extends StatelessWidget {
  List days = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder(
        future: Provider.of<AppState>(context).scraper.getTimetable(),
        builder: (context, AsyncSnapshot<Map> snapshot) {
          if (snapshot.hasData) {
            days = snapshot.data.keys.toList();

            List dataCell = [];
            snapshot.data.forEach((key, value) {
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
            return Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }

  SafeArea buildTimeTable(BuildContext context, List dataCell) {
    String currentDay;
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
