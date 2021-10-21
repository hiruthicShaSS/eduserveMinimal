// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:provider/provider.dart';

// Project imports:
import 'package:eduserveMinimal/providers/app_state.dart';

class AttendenceSummary extends StatefulWidget {
  const AttendenceSummary({Key? key}) : super(key: key);

  @override
  _AttendenceSummaryState createState() => _AttendenceSummaryState();
}

class _AttendenceSummaryState extends State<AttendenceSummary> {
  List<String> terms = [];
  String? selectedTerm = "Select the Academic Term";
  Widget table = Container();
  Widget mainDataWidget = Container();
  bool dataLoaded = false;
  String? selectedTermValue = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Attendence Summary"),
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

  FutureBuilder<List<dynamic>?> dropDown(BuildContext context) {
    return FutureBuilder(
        future: Provider.of<AppState>(context).scraper.getAttendenceSummary(),
        builder: (context, AsyncSnapshot<List?> snapshot) {
          if (snapshot.hasData)
            terms = List<String>.from(
                snapshot.data!.map((e) => e.keys.first).toSet().toList());

          return Padding(
            padding: const EdgeInsets.all(20.0),
            child: DropdownButton(
              hint: Text("Select the Academic Term"),
              icon: Icon(Icons.arrow_downward),
              iconSize: 24,
              elevation: 16,
              value: selectedTerm,
              underline: Container(
                height: 2,
                color: Colors.deepPurpleAccent,
              ),
              items: terms.map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
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
                    await Provider.of<AppState>(context, listen: false)
                        .scraper
                        .getAttendenceSummary(term: terms.first["value"]);

                if (data == null) {
                  return;
                }

                if (data.length == 0)
                  return setState(() =>
                      table = Center(child: Text("No records to display.")));

                List mainData = [];

                for (int i = 0; i < data[0].length; i += 2) {
                  mainData.add(data[0][i] + " " + data[0][i + 1]);
                }
                mainDataWidget = Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: List.generate(
                      mainData.length,
                      (index) => Text(mainData[index],
                          style: TextStyle(fontSize: 17))),
                );

                // setState(() {
                //   table = buildTable(data);
                //   dataLoaded = true;
                // });
              },
            ),
          );
        });
  }
}
