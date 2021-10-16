// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:provider/provider.dart';

// Project imports:
import 'package:eduserveMinimal/app_state.dart';

class InternalMarks extends StatefulWidget {
  @override
  _InternalMarksState createState() => _InternalMarksState();
}

class _InternalMarksState extends State<InternalMarks> {
  String status = "";
  bool _visible = false;
  Widget table = Container();
  String dropdownSelection;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Internal"),
        centerTitle: true,
      ),
      body: Column(
        children: [
          dropDown(context),
          Expanded(
            child: table,
          ),
        ],
      ),
    );
  }

  FutureBuilder<dynamic> dropDown(BuildContext context) {
    return FutureBuilder(
      future: Provider.of<AppState>(context).scraper.getInternalMarks(),
      builder: (context, AsyncSnapshot<dynamic> snapshot) {
        List<String> academicTerms = [];

        if (snapshot.hasData) {
          academicTerms =
              (snapshot.data.runtimeType == academicTerms.runtimeType)
                  ? snapshot.data
                  : [];
          academicTerms.remove("Select the Academic Term");

          return Column(
            children: [
              Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: DropdownButton(
                    hint: Text("Select the Academic Term"),
                    icon: Icon(Icons.arrow_downward),
                    iconSize: 24,
                    elevation: 16,
                    style: TextStyle(color: Colors.white),
                    underline: Container(
                      height: 2,
                      color: Colors.white,
                    ),
                    value: dropdownSelection,
                    items: academicTerms
                        .map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                    onChanged: (String value) async {
                      setState(() {
                        dropdownSelection = value.toString();
                        table = Center(child: CircularProgressIndicator());
                      });

                      final data =
                          await Provider.of<AppState>(context, listen: false)
                              .scraper
                              .getInternalMarks(
                                  academicTerm: (academicTerms.length -
                                          academicTerms.indexOf(value))
                                      .toString());

                      if (data == "No records to display.") {
                        // If login required
                        academicTerms = [];
                      }
                      if (data.runtimeType != String) {
                        // table data
                        List dataCell = [];
                        data.forEach((key, value) {
                          List<DataCell> temp = [];
                          value.forEach((element) {
                            temp.add(DataCell(Container(
                              color:
                                  ((double.tryParse(element.trim()) ?? 21) < 20)
                                      ? Colors.red
                                      : Colors.transparent,
                              width: MediaQuery.of(context).size.width / 3,
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
                        setState(() {
                          status = data;
                          table = Container();
                        });
                        Future.delayed(Duration(seconds: 2)).then((value) {
                          setState(() => _visible = !_visible);
                        });
                      }
                    },
                  )),
              AnimatedOpacity(
                duration: Duration(seconds: 1),
                opacity: _visible ? 1.0 : 0.0,
                child: Text(status.toString()),
              ),
            ],
          );
        } else {
          return Center(
            child: CircularProgressIndicator(),
          );
        }
      },
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
        child: Column(
          children: [
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
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
                rows: List.generate(dataCell.length,
                    (index) => DataRow(cells: dataCell[index])),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
