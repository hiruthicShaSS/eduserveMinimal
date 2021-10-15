// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:auto_size_text/auto_size_text.dart';

class OnDutyList extends StatelessWidget {
  const OnDutyList({Key key, @required this.data}) : super(key: key);
  final List data;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10),
      child: Container(
        child: ListView.builder(
          physics:
              BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
          itemCount: data.length,
          itemBuilder: (BuildContext context, int index) {
            // print(data.length);
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 5),
              child: Container(
                padding: EdgeInsets.all(15),
                decoration: BoxDecoration(
                    border: Border.all(
                      color: Theme.of(context)
                          .textTheme
                          .bodyText1
                          .color
                          .withOpacity(0.2),
                      width: 2,
                    ),
                    borderRadius: BorderRadius.circular(10)),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          AutoSizeText(
                            data[index][4].toString(),
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                                color: Theme.of(context)
                                    .textTheme
                                    .bodyText1
                                    .color
                                    .withOpacity(0.3)),
                          ),
                          Text(
                            "${data[index][0]} - ${data[index][2]}",
                            style: TextStyle(
                                fontSize: 20, fontWeight: FontWeight.bold),
                          ),
                          Text(
                            (data[index][1] == "FULL DAY")
                                ? "FD"
                                : data[index][1],
                            style:
                                TextStyle(color: Theme.of(context).accentColor),
                          ),
                        ],
                      ),
                    ),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Container(
                          padding: EdgeInsets.all(2),
                          decoration: BoxDecoration(
                            color: data[index][5].contains("AVAILED")
                                ? Colors.greenAccent.withOpacity(0.8)
                                : data[index][5].contains("REJECTED")
                                    ? Colors.redAccent.withOpacity(0.8)
                                    : Colors.orangeAccent.withOpacity(0.8),
                            borderRadius: BorderRadius.circular(5),
                          ),
                          child: Text(
                            data[index][5],
                            style: TextStyle(color: Colors.black),
                          ),
                        ),
                        SizedBox(height: 15),
                        InkWell(
                          child: Container(
                            padding: EdgeInsets.all(5),
                            decoration: BoxDecoration(
                              color: Colors.transparent.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(Icons.chevron_right),
                          ),
                          onTap: () {
                            showDialog(
                                context: context,
                                builder: (_) => AlertDialog(
                                      title: Text(data[index][4].toString()),
                                      content: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text(
                                            "Duration: ${data[index][0]} - ${data[index][2]}",
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          SizedBox(height: 10),
                                          Text(
                                              "Created on: ${data[index][8].toString()}"),
                                          Text(
                                              "From Session: ${data[index][1]}"),
                                          Text("Status: ${data[index][5]}"),
                                          SizedBox(height: 10),
                                          Text("Created by: ${data[index][7]}"),
                                          Text(
                                              "Approval by: ${data[index][9]}"),
                                          Text(
                                              "Approval on: ${data[index][10]}"),
                                          Text(
                                              "Availed by: ${data[index][11]}"),
                                          Text(
                                              "Availed on: ${data[index][12]}"),
                                          Center(
                                            child: TextButton(
                                                onPressed: () =>
                                                    Navigator.of(context).pop(),
                                                child: Text("Close")),
                                          ),
                                        ],
                                      ),
                                    ));
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
