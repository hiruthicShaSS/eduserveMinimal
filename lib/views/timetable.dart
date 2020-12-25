import 'package:eduserveMinimal/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class TimeTable extends StatelessWidget {
  Future<Map> getTimeTable() async {
    return await MyHomePage.scraper.timetable();
  }

  List days = new List();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Time Table"),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => TimeTable(),
              ));
            },
          ),
        ],
      ),
      body: FutureBuilder(
        future: getTimeTable(),
        builder: (context, AsyncSnapshot<Map> snapshot) {
          if (snapshot.hasData) {
            days = snapshot.data.keys.toList();

            List dataCell = new List();
            snapshot.data.forEach((key, value) {
              List<DataCell> temp = new List();
              value.forEach((element) {
                temp.add(DataCell(Container(
                  width: MediaQuery.of(context).size.width / 3,
                  child: Text((element.trim() == "") ? "YEET" : element,
                      style: TextStyle(fontSize: 17)),
                )));
              });
              temp.insert(
                  0, DataCell(Text(key, style: TextStyle(fontSize: 10))));
              dataCell.add(temp);
            });

            return buildTimeTable(context, dataCell);
          } else {
            return Container(
                alignment: Alignment.center,
                child: SpinKitCubeGrid(
                  size: 80,
                  color: Colors.white,
                ));
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
                columnSpacing: MediaQuery.of(context).size.width / 20,
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
                        selected: (currentDay == days[index]) ? true : false)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
