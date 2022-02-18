// 🐦 Flutter imports:
import 'package:flutter/material.dart';

// 🌎 Project imports:
import 'package:eduserveMinimal/service/download_hallticket.dart';

class HallTicketView extends StatefulWidget {
  @override
  _HallTicketViewState createState() => _HallTicketViewState();
}

class _HallTicketViewState extends State<HallTicketView> {
  List<String> exams = [];
  String? selectedTerm = "Select the Examination";
  Widget table = Container();
  Widget mainDataWidget = Container();
  bool dataLoaded = false;
  String? selectedTermValue = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Download Hall Ticket"),
        centerTitle: true,
        // actions: [
        //   Visibility(
        //       visible: dataLoaded,
        //       child: IconButton(
        //           onPressed: () async {
        //             await Provider.of<AppState>(context, listen: false)
        //                 .scraper
        //                 .downloadHallTicket(
        //                     term: selectedTermValue, download: true);
        //           },
        //           icon: Icon(Icons.save)))
        // ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            dropDown(context),
            Visibility(visible: dataLoaded, child: mainDataWidget),
            Expanded(
              child: table,
            ),
          ],
        ),
      ),
    );
  }

  FutureBuilder<List<dynamic>?> dropDown(BuildContext context) {
    return FutureBuilder(
        future: downloadHallTicket(),
        builder: (context, AsyncSnapshot<List?> snapshot) {
          if (!snapshot.hasData)
            exams = ["Select the Examination"];
          else
            exams = List<String>.from(
                snapshot.data!.map((e) => e.keys.first).toList());

          return Padding(
            padding: const EdgeInsets.all(20.0),
            child: DropdownButton(
              hint: Text("Select the Examination"),
              icon: Icon(Icons.arrow_downward),
              value: selectedTerm,
              iconSize: 24,
              elevation: 16,
              underline: Container(
                height: 2,
                color: Colors.deepPurpleAccent,
              ),
              onChanged: (String? value) async {
                setState(() {
                  selectedTerm = value;
                  table = Center(child: CircularProgressIndicator());
                });
                if (value == "Select the Examination") {
                  setState(() {
                    table = mainDataWidget = Container();
                  });
                  return;
                }

                final terms = snapshot.data!
                    .map((e) => e.containsKey(value) ? e[value] : null)
                    .toList();
                terms.removeWhere((element) => element == null);

                selectedTermValue = terms.first["value"];

                List<dynamic>? data =
                    await downloadHallTicket(term: terms.first["value"]);

                if (data == null) {
                  return;
                }

                List mainData = [];

                for (int i = 0; i < data[0].length; i += 2) {
                  mainData.add(data[0][i] + " " + data[0][i + 1]);
                }
                mainDataWidget = data.contains("No records to display.")
                    ? Container()
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: List.generate(
                            mainData.length,
                            (index) => Text(mainData[index],
                                style: TextStyle(fontSize: 17))),
                      );

                setState(() {
                  table = data.contains("No records to display.")
                      ? Text("No records to display.")
                      : buildTable(data);
                  dataLoaded = true;
                });
              },
              items: exams.map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
            ),
          );
        });
  }

  Widget buildTable(List data) {
    List header = [
      "Subject Code",
      "Subject Name",
      // "Eligibile",
    ];

    List subjectData = data.contains("No records to display.") ? [] : data[1];

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
                rows: List.generate(
                    subjectData.length,
                    (index) => DataRow(
                        color: MaterialStateProperty.resolveWith<Color>(
                            (Set<MaterialState> states) {
                          return subjectData[index].last == 'Y'
                              ? Colors.green.withOpacity(0.2)
                              : Colors.orange.withOpacity(0.2);
                        }),
                        cells: List.generate(
                            subjectData[index].length - 1,
                            (index1) => DataCell(Container(
                                  child: Text(
                                    subjectData[index][index1].trim(),
                                    style: TextStyle(fontSize: 17),
                                  ),
                                ))))),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
