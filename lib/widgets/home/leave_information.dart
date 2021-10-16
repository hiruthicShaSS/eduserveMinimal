// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:provider/provider.dart';

// Project imports:
import 'package:eduserveMinimal/app_state.dart';
import 'package:eduserveMinimal/widgets/home/leave_list.dart';
import 'package:eduserveMinimal/widgets/home/on_duty_list.dart';

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
            child: FutureBuilder(
              future: Provider.of<AppState>(context, listen: false)
                  .scraper
                  .getLeaveInfo(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.done) {
                  Provider.of<AppState>(context, listen: false).leaveInfo =
                      snapshot.data;

                  List leave = snapshot.data["leave"];
                  List onDuty = snapshot.data["onDuty"];

                  return TabBarView(
                    controller: _tabController,
                    children: [
                      LeaveList(data: leave),
                      OnDutyList(data: onDuty),
                    ],
                  );
                }
                return Center(child: CircularProgressIndicator());
              },
            ),
          ),
        ],
      ),
    );
  }
}
