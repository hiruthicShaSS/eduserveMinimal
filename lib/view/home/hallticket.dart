// 🎯 Dart imports:
import 'dart:developer';

// 🐦 Flutter imports:
import 'package:flutter/material.dart';

// 📦 Package imports:
import 'package:provider/provider.dart';

// 🌎 Project imports:
import 'package:eduserveMinimal/global/constants.dart';
import 'package:eduserveMinimal/global/exceptions.dart';
import 'package:eduserveMinimal/models/hallticket/hallticket.dart';
import 'package:eduserveMinimal/providers/app_state.dart';

class HallTicketView extends StatefulWidget {
  @override
  _HallTicketViewState createState() => _HallTicketViewState();
}

class _HallTicketViewState extends State<HallTicketView> {
  List<String> header = ["Subject Code", "Subject Name", "Eligibility"];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Download Hall Ticket"),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              FutureBuilder(
                  future: Provider.of<AppState>(context).getHallTicketData(),
                  builder: (context, AsyncSnapshot<HallTicket> snapshot) {
                    if (snapshot.hasError) {
                      log("", error: snapshot.error);

                      if (snapshot.error.runtimeType == NetworkException) {
                        return Center(child: Text(kNoInternetText));
                      }
                    }

                    if (snapshot.connectionState == ConnectionState.done) {
                      HallTicket hallTicket = snapshot.data!;

                      return Container(
                        margin: EdgeInsets.only(top: 2, left: 5, right: 5),
                        child: SingleChildScrollView(
                          child: Column(
                            children: [
                              SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: DataTable(
                                  dataRowHeight:
                                      MediaQuery.of(context).size.height / 5,
                                  columnSpacing:
                                      MediaQuery.of(context).size.width / 20,
                                  headingRowColor:
                                      MaterialStateProperty.all(Colors.white70),
                                  dividerThickness: 2,
                                  columns: List.generate(
                                      header.length,
                                      (index) => DataColumn(
                                              label: Text(
                                            header[index].toString(),
                                            style:
                                                TextStyle(color: Colors.black),
                                          ))),
                                  rows: List.generate(
                                    hallTicket.subjects.length,
                                    (index) => DataRow(
                                      color: MaterialStateProperty.resolveWith<
                                          Color>((Set<MaterialState> states) {
                                        return hallTicket
                                                .subjects[index].eligible
                                            ? Colors.transparent
                                            : Colors.orange.withOpacity(0.2);
                                      }),
                                      cells: [
                                        DataCell(
                                          Container(
                                            child: Text(
                                              hallTicket.subjects[index].code,
                                              style: TextStyle(fontSize: 17),
                                            ),
                                          ),
                                        ),
                                        DataCell(
                                          Container(
                                            child: Text(
                                              hallTicket.subjects[index].name,
                                              style: TextStyle(fontSize: 17),
                                            ),
                                          ),
                                        ),
                                        DataCell(
                                          Container(
                                            child: Text(
                                              hallTicket
                                                      .subjects[index].eligible
                                                  ? "✅"
                                                  : "❌",
                                              style: TextStyle(fontSize: 17),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }

                    return const Center(child: LinearProgressIndicator());
                  }),
            ],
          ),
        ),
      ),
    );
  }
}
