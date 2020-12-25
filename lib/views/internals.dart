import 'dart:collection';

import 'package:eduserveMinimal/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class InternalMarks extends StatefulWidget {
  @override
  _InternalMarksState createState() => _InternalMarksState();
}

class _InternalMarksState extends State<InternalMarks> {
  Future<dynamic> getInternals() async {
    return await MyHomePage.scraper.internalMarks();
  }

  String status = "";
  bool _visible = false;
  Widget table = Container();

  @override
  Widget build(BuildContext context) {
    Text dropdownHint = Text("Select the Academic Term");

    return Scaffold(
      appBar: AppBar(
        title: Text("Internal"),
        centerTitle: true,
      ),
      body: FutureBuilder(
        future: getInternals(),
        builder: (context, AsyncSnapshot<dynamic> snapshot) {
          List<String> academicTerms = new List();

          if (snapshot.hasData) {
            academicTerms =
                (snapshot.data.runtimeType == academicTerms.runtimeType)
                    ? snapshot.data
                    : List();
            academicTerms.remove("Select the Academic Term");

            return SafeArea(
              child: ListView(
                children: [
                  Center(
                    child: Column(
                      children: [
                        Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: DropdownButton(
                              hint: dropdownHint,
                              icon: Icon(Icons.arrow_downward),
                              iconSize: 24,
                              elevation: 16,
                              style: TextStyle(color: Colors.white),
                              underline: Container(
                                height: 2,
                                color: Colors.white,
                              ),
                              onChanged: (String value) async {
                                setState(() {
                                  dropdownHint = Text(value);
                                });

                                final data = await MyHomePage.scraper.internalMarks(
                                    academicTerm: (academicTerms.length -
                                            academicTerms.indexOf(value))
                                        .toString());

                                if (data == "No records to display.") {
                                  // If login required
                                  academicTerms.clear();
                                }
                                if (data.runtimeType != String) {
                                  // table data
                                  List dataCell = new List();
                                  // print(data);
                                  data.forEach((key, value) {
                                    List<DataCell> temp = new List();
                                    value.forEach((element) {
                                      temp.add(DataCell(Container(
                                        width:
                                            MediaQuery.of(context).size.width / 3,
                                        child: Text(
                                          element.trim(),
                                          style: TextStyle(fontSize: 17),
                                        ),
                                      )));
                                    });
                                    dataCell.add(temp);
                                  });

                                  setState(() {
                                    table = buildTable(data, dataCell);
                                  });
                                  return;
                                } else {
                                  // No records available
                                  _visible = true;
                                  setState(() => status = data);
                                  Future.delayed(Duration(seconds: 2))
                                      .then((value) {
                                    setState(() => _visible = !_visible);
                                  });
                                }
                              },
                              items: academicTerms
                                  .map<DropdownMenuItem<String>>((String value) {
                                return DropdownMenuItem<String>(
                                  value: value,
                                  child: Text(value),
                                );
                              }).toList(),
                            )),
                        AnimatedOpacity(
                          duration: Duration(seconds: 1),
                          opacity: _visible ? 1.0 : 0.0,
                          child: Text(status.toString()),
                        ),
                        Column(
                          children: [
                            SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: table,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          } else {
            return Center(
              child: SpinKitCubeGrid(size: 80, color: Colors.white),
            );
          }
        },
      ),
    );
  }

  Widget buildTable(Map data, List dataCell) {
    List header = [
      "Subject Code",
      "Subject Name",
      "IA Parameter",
      "Total Marks",
      "Marks Scored",
      "Test Marks",
      "Online Exam Marks",
      "Attendance",
      "Test Date",
      "Entered by",
      "Entered on"
    ];

    return Container(
      margin: EdgeInsets.only(top: 2, left: 5, right: 5),
      child: SingleChildScrollView(
        child: DataTable(
          dataRowHeight: MediaQuery.of(context).size.height / 5,
          columnSpacing: MediaQuery.of(context).size.width / 20,
          headingRowColor: MaterialStateProperty.all(Colors.white70),
          dividerThickness: 2,
          columns: List.generate(
              header.length,
              (index) => DataColumn(
                      label: Text(
                    header[index].toString(),
                    style: TextStyle(color: Colors.black),
                  ))),
          rows: List.generate(
              dataCell.length, (index) => DataRow(cells: dataCell[index])),
        ),
      ),
    );
  }
}
