// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:auto_size_text/auto_size_text.dart';

// Project imports:
import 'package:eduserveMinimal/global/enum.dart';
import 'package:eduserveMinimal/screens/home/pages/apply_leave.dart';

class LeaveList extends StatelessWidget {
  const LeaveList({Key? key, required this.data}) : super(key: key);
  final List? data;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10),
      child: Container(
        child: ListView.builder(
          physics:
              BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
          itemCount: data!.length + 1,
          itemBuilder: (BuildContext context, int index) {
            if (index == 0)
              return Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton.icon(
                    icon: Icon(Icons.add),
                    label: Text("Apply leave"),
                    onPressed: () => Navigator.of(context).push(
                        MaterialPageRoute(
                            builder: (_) =>
                                ApplyLeaveView(leaveType: LeaveType.Medical))),
                  ),
                ],
              );

            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 5),
              child: Container(
                padding: EdgeInsets.all(15),
                decoration: BoxDecoration(
                    border: Border.all(
                      color: Theme.of(context)
                          .textTheme
                          .bodyText1!
                          .color!
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
                            data![index - 1][1].toString(),
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                                color: Theme.of(context)
                                    .textTheme
                                    .bodyText1!
                                    .color!
                                    .withOpacity(0.3)),
                          ),
                          Text(
                            "${data![index - 1][2]} - ${data![index - 1][4]}",
                            style: TextStyle(
                                fontSize: 20, fontWeight: FontWeight.bold),
                          ),
                          Text(
                            data![index - 1][3],
                            style: TextStyle(
                                color: Theme.of(context).colorScheme.secondary),
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
                            color: data![index - 1][6].contains("Active")
                                ? Colors.greenAccent.withOpacity(0.8)
                                : data![index - 1][6].contains("Rejected")
                                    ? Colors.redAccent.withOpacity(0.8)
                                    : Colors.orangeAccent.withOpacity(0.8),
                            borderRadius: BorderRadius.circular(5),
                          ),
                          child: Text(
                            data![index - 1][6],
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
                                      title:
                                          Text(data![index - 1][0].toString()),
                                      content: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text(
                                            "Duration: ${data![index - 1][2]} - ${data![index - 1][4]}",
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          SizedBox(height: 10),
                                          Text(
                                              "From Session: ${data![index - 1][5]}"),
                                          Text(
                                              "Status: ${data![index - 1][6]}"),
                                          SizedBox(height: 10),
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
