import 'package:eduserveMinimal/app_state.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';

class LeaveInformation extends StatefulWidget {
  const LeaveInformation({Key key}) : super(key: key);

  @override
  _LeaveInformationState createState() => _LeaveInformationState();
}

class _LeaveInformationState extends State<LeaveInformation>
    with SingleTickerProviderStateMixin {
  TabController _tabController;

  @override
  void initState() {
    _tabController = TabController(length: 2, vsync: this);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // Provider.of<AppState>(context, listen: false).scraper.getLeaveInfo();
    // return Container();
    return Expanded(
      child: Column(
        children: [
          TabBar(controller: _tabController, tabs: [
            Tab(
              text: "Leave",
            ),
            Tab(
              text: "On-Duty Details",
            ),
          ]),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                buildLeaveDetails(),
                buildOnDutyDetails(context),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Text buildLeaveDetails() => Text("Leave Details");

  FutureBuilder<List<List<String>>> buildOnDutyDetails(BuildContext context) {
    return FutureBuilder(
      future:
          Provider.of<AppState>(context, listen: false).scraper.getLeaveInfo(),
      builder: (BuildContext context, AsyncSnapshot<List<List>> snapshot) {
        // snapshot.data.forEach((element) => print(element));
        Provider.of<AppState>(context, listen: false).leaveInfo = snapshot.data;

        if (snapshot.connectionState == ConnectionState.done) {
          List data = snapshot.data;

          return Container(
            child: ListView.builder(
              itemCount: data.length,
              itemBuilder: (BuildContext context, int index) {
                // print(data.length);
                return InkWell(
                  child: ListTile(
                    title: Text(data[index][4].toString()),
                    trailing: (data[index][1] == "FULL DAY")
                        ? FaIcon(FontAwesomeIcons.sync)
                        : (data[index][1] == "FN")
                            ? FaIcon(FontAwesomeIcons.sun)
                            : (data[index][1] == "AN")
                                ? FaIcon(FontAwesomeIcons.moon)
                                : Container(),
                  ),
                  onTap: () {
                    showDialog(
                        context: context,
                        builder: (_) => AlertDialog(
                              title: Text(data[index][4].toString()),
                              content: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
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
                                  Text("From Session: ${data[index][1]}"),
                                  Text("Status: ${data[index][5]}"),
                                  SizedBox(height: 10),
                                  Text("Created by: ${data[index][7]}"),
                                  Text("Approval by: ${data[index][9]}"),
                                  Text("Approval on: ${data[index][10]}"),
                                  Text("Availed by: ${data[index][11]}"),
                                  Text("Availed on: ${data[index][12]}"),
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
                );
              },
            ),
          );
        }
        return CircularProgressIndicator();
      },
    );
  }
}
