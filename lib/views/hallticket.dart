import 'package:eduserveMinimal/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class HallTicket extends StatefulWidget {
  @override
  _HallTicketState createState() => _HallTicketState();
}

class _HallTicketState extends State<HallTicket> {
  List<String> exams = new List();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Download Hall Ticket"),
        centerTitle: true,
      ),
      body: SafeArea(
        child: FutureBuilder(
          future: MyHomePage.scraper.downloadHallTicket(),
          builder: (context, AsyncSnapshot<Map> snapshot) {
            if (snapshot.hasData) {
              return ListView(
                children: [
                  Container(
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: Row(
                            children: [
                              Text("Select the Examination"),
                              Spacer(),
                              DropdownButton(
                                hint: Text("Select the Examination"),
                                icon: Icon(Icons.arrow_downward),
                                iconSize: 24,
                                elevation: 16,
                                style: TextStyle(color: Colors.deepPurple),
                                underline: Container(
                                  height: 2,
                                  color: Colors.deepPurpleAccent,
                                ),
                                onChanged: (String value) {
                                  print(value);
                                },
                                items: exams.map<DropdownMenuItem<String>>(
                                    (String value) {
                                  return DropdownMenuItem<String>(
                                    value: value,
                                    child: Text(value),
                                  );
                                }).toList(),
                              )
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            } else {
              return Center(child: SpinKitCubeGrid(color: Colors.white, size: 80));
            }
          },
        ),
      ),
    );
  }
}
